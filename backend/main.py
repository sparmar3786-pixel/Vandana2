"""FastAPI application: REST + WebSocket hub for the browser terminal.

Endpoints
---------
GET  /health                       liveness probe
GET  /api/config                   safe (non-secret) config subset
GET  /api/indices                  supported indices
GET  /api/snapshot/{index}         latest canonical snapshot
GET  /api/decision/{index}         latest decision + trade plans
GET  /api/strategies              searchable 377-module catalogue
GET  /api/strategies/{sid}         single strategy metadata
POST /api/orders/paper            paper order (always allowed)
POST /api/orders/live             LIVE order (env flag + human confirm gate)
WS   /ws                          live stream: snapshot / decision / logs

SAFETY
------
Market-data, analysis, strategy-search and validation only; order placement and paper trading are not exposed.
"""

from __future__ import annotations

import asyncio
import json
from contextlib import asynccontextmanager
from typing import Any, Dict, Set

from fastapi import FastAPI, HTTPException, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

from backend.config import get_settings
from backend.logging_config import get_logger, setup_logging
from backend.memory.strategy_memory import StrategyMemory
from backend.pipeline.orchestrator import TerminalEngine
from backend.strategies.registry import get_meta
from backend.strategies.catalog import STRATEGY_REGISTRY, strategy_search
from backend.ai.six_layer_ai import LAYERS
from backend.live_api import build_router

log = get_logger("api")


# ----------------------------- WebSocket hub -----------------------------

class ConnectionManager:
    """Tracks connected browser terminals and broadcasts JSON frames."""

    def __init__(self) -> None:
        self._connections: Set[WebSocket] = set()
        self._lock = asyncio.Lock()

    async def connect(self, ws: WebSocket) -> None:
        await ws.accept()
        async with self._lock:
            self._connections.add(ws)

    async def disconnect(self, ws: WebSocket) -> None:
        async with self._lock:
            self._connections.discard(ws)

    async def broadcast(self, channel: str, payload: Any) -> None:
        frame = json.dumps({"channel": channel, "payload": payload}, default=str)
        dead: list[WebSocket] = []
        for ws in list(self._connections):
            try:
                await ws.send_text(frame)
            except Exception:
                dead.append(ws)
        for ws in dead:
            await self.disconnect(ws)

    @property
    def count(self) -> int:
        return len(self._connections)


manager = ConnectionManager()


# ----------------------------- app state -----------------------------

class AppState:
    engine: TerminalEngine | None = None
    memory: StrategyMemory | None = None
    task: asyncio.Task | None = None


state = AppState()


@asynccontextmanager
async def lifespan(app: FastAPI):
    setup_logging()
    settings = get_settings()
    log.info("starting nse-ai-terminal (source={}, advanced={})",
             settings.data_source, settings.advanced_engine)

    state.memory = StrategyMemory(settings.db_path)
    state.engine = TerminalEngine(memory=state.memory, broadcaster=manager.broadcast)

    if state.engine:
        state.task = asyncio.create_task(state.engine.run_forever())
    try:
        yield
    finally:
        if state.engine:
            await state.engine.stop()
        if state.task:
            state.task.cancel()
            try:
                await state.task
            except (asyncio.CancelledError, Exception):
                pass
        log.info("shutdown complete")


app = FastAPI(title="nse-ai-terminal", version="0.1.0", lifespan=lifespan)
settings = get_settings()
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_list or ["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(build_router(lambda: state.engine))


# ----------------------------- REST -----------------------------

@app.get("/health")
async def health() -> Dict[str, Any]:
    return {
        "status": "ok",
        "source": settings.data_source,
        "advanced_engine": settings.advanced_enabled,
        "ai_enabled": settings.ai_on,
        "ws_clients": manager.count,
    }


@app.get("/api/config")
async def api_config() -> Dict[str, Any]:
    """Non-secret configuration surface for the UI."""
    return {
        "indices": settings.index_list,
        "data_source": settings.data_source,
        "advanced_engine": settings.advanced_enabled,
        "ai_enabled": settings.ai_on,
        "ai_transport": settings.ai_transport,
        "ai_models": settings.ai_models,
        "min_trade_plans": settings.min_trade_plans,
        "min_rr": settings.min_rr,
    }


@app.get("/api/indices")
async def api_indices() -> Dict[str, Any]:
    return {"indices": settings.index_list}


@app.get("/api/snapshot/{index}")
async def api_snapshot(index: str) -> Dict[str, Any]:
    if state.engine is None:
        raise HTTPException(503, "engine not ready")
    snap = state.engine.latest_snapshot(index)
    if snap is None:
        raise HTTPException(404, f"no snapshot for {index}")
    return snap.model_dump(mode="json")


@app.get("/api/decision/{index}")
async def api_decision(index: str) -> Dict[str, Any]:
    if state.engine is None:
        raise HTTPException(503, "engine not ready")
    dec = state.engine.latest_decision(index)
    if dec is None:
        raise HTTPException(404, f"no decision yet for {index}")
    return dec.model_dump(mode="json")


@app.get("/api/strategies")
async def api_strategies(q: str = "", family: str = "", limit: int = 377) -> Dict[str, Any]:
    rows = strategy_search(q)
    if family:
        fl=family.strip().lower()
        rows=[x for x in rows if fl in x.section.lower()]
    rows=rows[:max(1,min(limit,377))]
    return {"count":len(rows),"total_catalogue":377,
            "strategies":[{"id":f"S{x.id:03d}","number":x.id,"name":x.name,"family":x.section,"advanced":False} for x in rows]}


@app.get("/api/strategies/{sid}")
async def api_strategy(sid: str) -> Dict[str, Any]:
    meta = get_meta(sid)
    if meta is None:
        raise HTTPException(404, f"unknown strategy {sid}")
    return meta.model_dump()


# ----------------------------- orders -----------------------------

@app.get("/api/ai/layers")
async def api_ai_layers() -> Dict[str, Any]:
    return {"count":len(LAYERS),"layers":[
        {"id":x["id"],"name":x["name"],"role":x["role"],"web_search":x["web"]}
        for x in LAYERS
    ],"validation_only":True}

@app.post("/api/ai/validate/{index}")
async def api_ai_validate(index:str) -> Dict[str,Any]:
    if state.engine is None:
        raise HTTPException(503,"engine not ready")
    try:
        return await state.engine.ai_validate(index)
    except Exception as e:
        raise HTTPException(502,f"AI validation failed: {e}")

@app.get("/api/angel/status")
async def angel_status() -> Dict[str, Any]:
    source = getattr(state.engine, "_source", None) if state.engine else None
    return {"broker":"Angel One SmartAPI","connected":bool(source and getattr(source,"connected",False)),"source":getattr(source,"name","none"),"live_data_only":True}


@app.post("/api/angel/connect")
async def angel_connect() -> Dict[str, Any]:
    if state.engine is None:
        raise HTTPException(503,"engine not ready")
    try:
        await state.engine.connect_source()
    except Exception as e:
        raise HTTPException(502,f"Angel One connection failed: {e}")
    source=getattr(state.engine,"_source",None)
    return {"broker":"Angel One SmartAPI","connected":bool(source and getattr(source,"connected",False)),
            "source":getattr(source,"name","angel_one"),"live_data_only":True}


@app.get("/api/candles/{index}")
async def api_candles(index:str, interval:str="FIVE_MINUTE", days:int=5) -> Dict[str,Any]:
    source = getattr(state.engine, "_source", None) if state.engine else None
    if source is None or not getattr(source,"connected",False): raise HTTPException(503,"Angel One live data is not connected")
    if not hasattr(source,"get_index_token"): raise HTTPException(503,"selected live source does not expose index candles")
    token=await source.get_index_token(index)
    if not token: raise HTTPException(404,f"index token not found for {index}")
    from datetime import datetime,timedelta,timezone
    import pandas as pd
    requested=interval.upper()
    native={"ONE_MINUTE":"ONE_MINUTE","THREE_MINUTE":"THREE_MINUTE","FIVE_MINUTE":"FIVE_MINUTE",
            "TEN_MINUTE":"TEN_MINUTE","FIFTEEN_MINUTE":"FIFTEEN_MINUTE","THIRTY_MINUTE":"THIRTY_MINUTE",
            "ONE_HOUR":"ONE_HOUR","ONE_DAY":"ONE_DAY"}
    resample={"TWO_MINUTE":("ONE_MINUTE","2min"),"TWO_HOUR":("ONE_HOUR","2h"),"FOUR_HOUR":("ONE_HOUR","4h")}
    source_interval,rule=resample.get(requested,(native.get(requested,"FIVE_MINUTE"),None))
    now=datetime.now(timezone.utc).astimezone(); frm=now-timedelta(days=max(1,min(days,30)))
    exchange="BSE" if index.upper().replace(" ","") in {"SENSEX","BANKEX"} else "NSE"
    df=await source.get_historical(token,exchange,source_interval,frm,now)
    if rule and not df.empty:
        df=df.copy()
        df["timestamp"]=pd.to_datetime(df["timestamp"],errors="coerce")
        df=df.dropna(subset=["timestamp"]).set_index("timestamp")
        for col in ("open","high","low","close","volume"):
            if col in df: df[col]=pd.to_numeric(df[col],errors="coerce")
        agg={"open":"first","high":"max","low":"min","close":"last","volume":"sum"}
        df=df.resample(rule).agg({k:v for k,v in agg.items() if k in df.columns}).dropna(subset=["close"]).reset_index()
    rows=[] if df.empty else df.where(df.notna(),None).to_dict(orient="records")
    return {"index":index.upper(),"interval":requested,"rows":rows,"source":getattr(source,"name","angel_one"),"live_data_only":True}

# ----------------------------- WS -----------------------------

@app.websocket("/ws")
async def ws_endpoint(ws: WebSocket) -> None:
    await manager.connect(ws)
    try:
        # initial handshake frame with config
        await ws.send_text(json.dumps({"channel": "config", "payload": {
            "indices": settings.index_list,
            "advanced_engine": settings.advanced_enabled,
        }}, default=str))
        while True:
            if state.engine is not None:
                # push a periodic full state frame
                frame = state.engine.state_frame()
                await ws.send_text(json.dumps({"channel": "state", "payload": frame}, default=str))
            # also drain any client messages (e.g. subscribe/ping)
            try:
                msg = await asyncio.wait_for(ws.receive_text(), timeout=2.0)
                await ws.send_text(json.dumps({"channel": "ack", "payload": msg}))
            except asyncio.TimeoutError:
                pass
    except WebSocketDisconnect:
        pass
    finally:
        await manager.disconnect(ws)
