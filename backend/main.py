from fastapi import FastAPI,WebSocket
from fastapi.middleware.cors import CORSMiddleware
from .config import settings
from .models import Snapshot,Tick,to_dict
from .pipeline.orchestrator import run_pipeline
from .ai.six_layer_ai import validate,MODELS
app=FastAPI(title=settings.app_name,version="1.0.0")
app.add_middleware(CORSMiddleware,allow_origins=["*"],allow_methods=["*"],allow_headers=["*"])
@app.get("/api/health")
def health(): return {"app":settings.app_name,"status":"ok","mode":"PAPER","data_source":settings.data_source,"live_orders":settings.enable_live_orders}
@app.get("/api/strategies")
def strategies(q:str=""):
 from .strategies.catalog import strategy_search
 xs=strategy_search(q); return {"count":len(xs),"strategies":[to_dict(x) for x in xs]}
@app.post("/api/evaluate")
def evaluate(p:dict):
 try:
  calls=[Tick(**x) for x in p.get("calls",[])]; puts=[Tick(**x) for x in p.get("puts",[])]
  s=Snapshot(p.get("symbol",""),float(p["underlying"]),float(p["atm_strike"]),p["timestamp"],calls,puts,p.get("source","user"))
  r=run_pipeline(s); return validate(r)
 except Exception as e:return {"quality":"DATA_GAP","verdict":"WAIT","error":str(e)}
@app.websocket("/ws")
async def ws(w:WebSocket):
 await w.accept(); await w.send_json({"type":"ready","app":settings.app_name,"mode":"PAPER","ai_layers":MODELS})
 while True:
  msg=await w.receive_json(); await w.send_json({"type":"ack","received":bool(msg)})
