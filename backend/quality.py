from .models import Snapshot, ValidationResult

def validate_snapshot(snapshot: Snapshot, now: float, max_age: float = 60.0) -> ValidationResult:
    reasons = []
    if snapshot.spot is None or snapshot.spot <= 0:
        reasons.append("MISSING_SPOT")
    if now - snapshot.timestamp > max_age:
        reasons.append("STALE_SNAPSHOT")
    if not snapshot.options:
        reasons.append("DATA_GAP")
    for leg in snapshot.options:
        if leg.ltp is None:
            reasons.append("MISSING_LTP")
        if leg.oi is None:
            reasons.append("MISSING_OI")
        if leg.volume is None:
            reasons.append("MISSING_VOLUME")
        if leg.strike <= 0:
            reasons.append("INVALID_STRIKE")
        if leg.side not in ("CE", "PE"):
            reasons.append("INVALID_SIDE")
    return ValidationResult(not reasons, sorted(set(reasons)))
