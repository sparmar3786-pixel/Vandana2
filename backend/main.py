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
Live orders are OFF by default. Even when ``ENABLE_LIVE_ORDERS=1`` the endpoint
requires a ``confirm`` token echoed from a human-readable summary.
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
from backend.strategies.registry import get_meta, search_meta, all_meta

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


# ----------------------------- REST -----------------------------

@app.get("/health")
async def health() -> Dict[str, Any]:
    return {
        "status": "ok",
        "source": settings.data_source,
        "advanced_engine": settings.advanced_enabled,
        "ai_enabled": settings.ai_on,
        "live_orders": settings.live_orders_on,
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
        "live_orders": settings.live_orders_on,
        "human_confirm_required": settings.human_confirm_required,
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
async def api_strategies(q: str = "", family: str = "", limit: int = 400) -> Dict[str, Any]:
    metas = search_meta(q, family) if (q or family) else all_meta()
    return {"count": len(metas), "strategies": [m.model_dump() for m in metas[:limit]]}


@app.get("/api/strategies/{sid}")
async def api_strategy(sid: str) -> Dict[str, Any]:
    meta = get_meta(sid)
    if meta is None:
        raise HTTPException(404, f"unknown strategy {sid}")
    return meta.model_dump()


# ----------------------------- orders -----------------------------

class OrderRequest(BaseModel):
    index: str
    strike: float
    option_type: str            # CE | PE
    side: str = "BUY"
    quantity: int = 1
    confirm: str = ""


@app.post("/api/orders/paper")
async def paper_order(req: OrderRequest) -> Dict[str, Any]:
    return {
        "mode": "PAPER",
        "accepted": True,
        "order": req.model_dump(),
        "note": "paper fill only — no broker order was placed",
    }


@app.post("/api/orders/live")
async def live_order(req: OrderRequest) -> Dict[str, Any]:
    if not settings.live_orders_on:
        raise HTTPException(403, "live orders are disabled (ENABLE_LIVE_ORDERS=0)")
    if settings.human_confirm_required:
        expected = f"{req.index}-{req.option_type}-{req.strike}-{req.side}"
        if req.confirm != expected:
            raise HTTPException(400, f"human confirmation required; echo confirm={expected!r}")
    if state.engine is None:
        raise HTTPException(503, "engine not ready")
    result = await state.engine.place_live_order(req.model_dump())
    return {"mode": "LIVE", **result}


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
