ALLOWED_VERDICTS = {"CALL BUY","PUT BUY","WAIT","NO QUALIFYING TRADE"}

def validate_ai_output(ai_text: str, engine_output: dict) -> dict:
    text = (ai_text or "").strip()
    # AI may validate or reject engine evidence, never manufacture levels.
    forbidden_invention = any(token in text.lower() for token in ("guaranteed profit","sure shot","100% profit"))
    return {
        "accepted": bool(text) and not forbidden_invention,
        "hallucination_guard": not forbidden_invention,
        "engine_verdict": engine_output.get("verdict","NO QUALIFYING TRADE"),
        "ai_can_override_levels": False,
    }
