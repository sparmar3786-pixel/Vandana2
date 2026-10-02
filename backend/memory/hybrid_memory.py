from __future__ import annotations
from typing import Any, Dict, Optional
import httpx
from backend.memory.strategy_memory import StrategyMemory

class HybridMemory:
    """Write-through local memory plus best-effort Supabase durable memory."""

    def __init__(self, local: StrategyMemory, url: str = "", service_key: str = ""):
        self.local = local
        self.url = url.rstrip("/")
        self.service_key = service_key
        self.enabled = bool(self.url and self.service_key)

    def _headers(self) -> Dict[str, str]:
        return {
            "apikey": self.service_key,
            "Authorization": f"Bearer {self.service_key}",
            "Content-Type": "application/json",
            "Prefer": "return=minimal",
        }

    async def _insert(self, table: str, row: Dict[str, Any]) -> None:
        if not self.enabled:
            return
        try:
            async with httpx.AsyncClient(timeout=4.0) as client:
                r = await client.post(f"{self.url}/rest/v1/{table}", headers=self._headers(), json=row)
                r.raise_for_status()
        except Exception:
            return

    async def record_observation(self, rec: Dict[str, Any]) -> None:
        self.local.record_observation(rec)
        await self._insert("strategy_memory", {
            "index_name": rec.get("index"), "regime": rec.get("regime"),
            "strategy": rec.get("strategy"), "strike": rec.get("strike"),
            "side": rec.get("side"), "entry": rec.get("entry"),
            "oi": rec.get("oi"), "premium": rec.get("premium"),
            "volume": rec.get("volume"), "iv": rec.get("iv"),
            "greeks": rec.get("greeks"), "expiry": rec.get("expiry"),
            "day_time": rec.get("time"), "result": rec.get("result"),
            "confidence": rec.get("confidence"), "extra": rec.get("extra"),
        })

    async def record_trade(self, rec: Dict[str, Any]) -> None:
        self.local.record_trade(rec)
        await self._insert("trade_memory", {
            "strategy": rec.get("strategy_id"), "index_name": rec.get("index"),
            "side": rec.get("side"), "strike": rec.get("strike"),
            "entry": rec.get("entry"), "exit": rec.get("exit"), "r": rec.get("r"),
            "result": rec.get("result"), "regime": rec.get("regime"),
            "expiry": rec.get("expiry"), "strike_distance": rec.get("strike_distance"),
            "day_time": rec.get("time"), "is_expiry": bool(rec.get("is_expiry")),
            "extra": rec.get("extra"),
        })

    def strategy_summary(self, index: str): return self.local.strategy_summary(index)
    def regime_behaviour(self, regime: Optional[str], index: str): return self.local.regime_behaviour(regime, index)
    def failure_patterns(self, limit: int = 20): return self.local.failure_patterns(limit)
    def trades_for_backtest(self, index: Optional[str] = None): return self.local.trades_for_backtest(index)
