from .guard import validate_ai_output

DEFAULT_LAYERS = (
    "GPT-5.6 Luna",
    "Claude Sonnet 4.6",
    "GPT-5.6 Sol",
    "DeepSeek Chat",
    "Gemini 2.5 Flash",
    "Grok 4",
)

def validate_six_layers(engine_output: dict, responses: dict[str,str]) -> dict:
    results = {}
    for name in DEFAULT_LAYERS:
        results[name] = validate_ai_output(responses.get(name,""), engine_output)
    return {"layers": results, "final_override_allowed": False}
