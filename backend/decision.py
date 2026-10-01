ALLOWED_VERDICTS = {"CALL BUY", "PUT BUY", "WAIT", "NO QUALIFYING TRADE"}

def final_decision(plans: list[dict]) -> dict:
    # Never pad the result to five. Five is a display target, not a fabrication rule.
    clean = []
    for plan in plans:
        side = plan.get("side")
        if side not in ("CALL BUY", "PUT BUY"):
            continue
        required = ("strike", "entry", "sl", "target")
        if any(plan.get(k) is None for k in required):
            continue
        clean.append(plan)
    if not clean:
        return {"verdict": "NO QUALIFYING TRADE", "trade_count": 0, "plans": []}
    return {"verdict": clean[0]["side"], "trade_count": len(clean), "plans": clean}
