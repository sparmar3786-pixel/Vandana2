from fastapi import FastAPI, WebSocket
from fastapi.middleware.cors import CORSMiddleware
from .config import DATA_SOURCE, ADVANCED_ENGINE, ENABLE_LIVE_ORDERS
from .decision import final_decision
from .pipeline.orchestrator import run_pipeline
from .models import Snapshot, OptionLeg
from .strategies.catalog import STRATEGY_REGISTRY, strategy_search

app = FastAPI(title="NSE AI Terminal", version="1.0.0", docs_url="/docs")
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])

@app.get("/api/health")
def health():
    return {
        "status": "ok",
        "service": "nse-ai-terminal",
        "data_source": DATA_SOURCE,
        "advanced_engine": ADVANCED_ENGINE,
        "live_orders_enabled": ENABLE_LIVE_ORDERS,
        "strategy_count": len(STRATEGY_REGISTRY),
        "mode": "PAPER",
    }

@app.get("/api/strategies")
def strategies(q: str = ""):
    rows = strategy_search(q)
    return {"count": len(rows), "strategies": [s.__dict__ for s in rows]}

@app.post("/api/decision")
def decision(payload: dict):
    return final_decision(payload.get("plans", []))

@app.post("/api/pipeline")
def pipeline(payload: dict):
    options = [OptionLeg(**row) for row in payload.get("options", [])]
    snapshot = Snapshot(
        index=payload.get("index","NIFTY"),
        spot=payload.get("spot"),
        timestamp=float(payload.get("timestamp", 0)),
        options=options,
        exchange=payload.get("exchange","NSE"),
        source=payload.get("source", DATA_SOURCE),
    )
    return run_pipeline(snapshot, float(payload.get("now", snapshot.timestamp))).__dict__

@app.post("/api/validate")
def validate(payload: dict):
    # Transport-level endpoint; full broker normalization is intentionally separate.
    return {"status": "accepted", "source": payload.get("source", DATA_SOURCE), "validated": False,
            "reason": "snapshot validation requires canonical Snapshot input"}

@app.websocket("/ws")
async def websocket_terminal(ws: WebSocket):
    await ws.accept()
    await ws.send_json({"type":"hello","service":"nse-ai-terminal","mode":"PAPER","strategy_count":len(STRATEGY_REGISTRY)})
    try:
        while True:
            message = await ws.receive_json()
            action = message.get("action")
            if action == "health":
                await ws.send_json({"type":"health","status":"ok"})
            elif action == "strategies":
                rows = strategy_search(message.get("q",""))
                await ws.send_json({"type":"strategies","count":len(rows),"strategies":[s.__dict__ for s in rows]})
            elif action == "decision":
                await ws.send_json({"type":"decision","data":final_decision(message.get("plans",[]))})
            else:
                await ws.send_json({"type":"error","code":"UNKNOWN_ACTION"})
    except Exception:
        await ws.close()

