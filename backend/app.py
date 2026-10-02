"""Vandana2 application wrapper.

Keeps backend.main unchanged while adding the authenticated live terminal routes
and serving the standalone terminal UI.
"""

from __future__ import annotations

import asyncio
import hmac
import os
from pathlib import Path

from fastapi import Header, HTTPException
from fastapi.responses import FileResponse

from backend.main import app
from backend.live_api import recorder

ROOT = Path(__file__).resolve().parent.parent
_frontend = ROOT / "frontend"

_recorder_task: asyncio.Task | None = None


@app.on_event("startup")
async def _start_live_recorder() -> None:
    global _recorder_task
    from backend.main import state
    _recorder_task = asyncio.create_task(recorder(lambda: state.engine), name="live-setup-recorder")


@app.on_event("shutdown")
async def _stop_live_recorder() -> None:
    global _recorder_task
    if _recorder_task:
        _recorder_task.cancel()
        try:
            await _recorder_task
        except asyncio.CancelledError:
            pass
        _recorder_task = None


def _vm_guard(x_key: str) -> None:
    expected = os.getenv("VM_SECRET", "")
    if not expected or not hmac.compare_digest(x_key or "", expected):
        raise HTTPException(403, "bad key")


@app.get("/optionchain")
async def vm_optionchain(symbol: str = "NIFTY", n: int = 8, x_key: str = Header(default="")) -> dict:
    """Compatibility bridge for the Cloudflare/VM NSE MCP edge worker."""
    _vm_guard(x_key)
    eng = getattr(__import__("backend.main", fromlist=["state"]), "state").engine
    if eng is None:
        raise HTTPException(503, "engine not ready")
    source = getattr(eng, "_source", None)
    if source is None or not getattr(source, "connected", False):
        try:
            await eng.connect_source()
            source = eng._source
        except Exception as e:
            raise HTTPException(503, f"live source unavailable: {type(e).__name__}")
    try:
        snap = await source.get_option_chain(symbol.upper())
    except Exception as e:
        raise HTTPException(502, f"option chain failed: {type(e).__name__}")
    rows = []
    for x in snap.strikes:
        for typ, ltp, oi in (
            ("CE", x.ce_ltp, x.ce_oi),
            ("PE", x.pe_ltp, x.pe_oi),
        ):
            if ltp is not None or oi is not None:
                rows.append({"strike": x.strike, "type": typ, "ltp": ltp or 0, "oi": oi or 0})
    rows.sort(key=lambda r: (r["strike"], r["type"]))
    return {"symbol": snap.index, "spot": snap.spot, "expiry": snap.expiry, "atm": snap.atm_strike, "rows": rows}


@app.get("/terminal.html", include_in_schema=False)
async def terminal_page() -> FileResponse:
    return FileResponse(_frontend / "terminal.html", media_type="text/html")


@app.get("/", include_in_schema=False)
async def root_page() -> FileResponse:
    return FileResponse(_frontend / "terminal.html", media_type="text/html")
