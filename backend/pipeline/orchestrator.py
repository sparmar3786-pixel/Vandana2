from dataclasses import dataclass
from ..models import Snapshot
from ..quality import validate_snapshot

PARTS = [
"data_ingestion","normalization","timestamp_chronology","freshness","duplicate_gap_check",
"market_status","exchange_validation","spot_validation","option_validation","oi_classification",
"premium_analysis","volume_analysis","ce_engine","pe_engine","strike_selection","support_resistance",
"trend_price_action","indicator_context","greeks_iv","expiry_context","liquidity_gate",
"microstructure","trap_reversal","market_regime","quant_context","cross_index",
"entry_filter","opposite_side_control","risk_rr_gate","signal_intelligence",
"backtest_context","final_decision",
]

@dataclass
class PipelineResult:
    ok: bool
    reasons: list[str]
    context: dict

def run_pipeline(snapshot: Snapshot, now: float) -> PipelineResult:
    quality = validate_snapshot(snapshot, now)
    if not quality.ok:
        return PipelineResult(False, quality.reasons, {"verdict":"NO QUALIFYING TRADE","parts":len(PARTS)})
    # Run60/Run93 deterministic core stays the single source of truth.
    return PipelineResult(True, [], {"verdict":"WAIT","parts":len(PARTS),"engine":"RUN60+RUN93"})
