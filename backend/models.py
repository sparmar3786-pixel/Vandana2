from dataclasses import dataclass, field
from typing import Optional

@dataclass
class OptionLeg:
    strike: float
    side: str
    ltp: Optional[float]
    oi: Optional[float]
    volume: Optional[float]
    iv: Optional[float] = None
    delta: Optional[float] = None
    gamma: Optional[float] = None
    theta: Optional[float] = None
    vega: Optional[float] = None
    bid: Optional[float] = None
    ask: Optional[float] = None
    oi_change: Optional[float] = None
    timestamp: Optional[float] = None

@dataclass
class Snapshot:
    index: str
    spot: Optional[float]
    timestamp: float
    options: list[OptionLeg] = field(default_factory=list)
    exchange: str = "NSE"
    source: str = "unknown"

@dataclass
class ValidationResult:
    ok: bool
    reasons: list[str] = field(default_factory=list)

@dataclass
class TradePlan:
    side: str
    strike: float
    entry: float
    stop_loss: float
    targets: list[float]
    rr: Optional[float] = None
    confidence: Optional[float] = None
    strategy_ids: list[int] = field(default_factory=list)
