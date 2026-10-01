# VandanaSachin — NSE AI Terminal

Research-grade, paper-first NSE/BSE index-options terminal in Python 3.11+, FastAPI + WebSocket, vanilla-JS terminal, Angel One server-side data boundary, deterministic 32-part pipeline, canonical 377-strategy registry, six-layer AI validation boundary, backtest/SQLite memory and MCP boundary.

Safety: confidence is not probability/win rate; observable data only; missing/stale/duplicate/incomplete data => DATA_GAP/NO SIGNAL; AI cannot invent strike/entry/SL/target; one final R:R gate; closed verdicts are CALL BUY / PUT BUY / WAIT / NO QUALIFYING TRADE; credentials remain server-side; live orders default OFF.

Run: `pip install -r requirements.txt` then `uvicorn backend.main:app --reload --port 8000`. Serve `frontend/` separately on port 5173.
