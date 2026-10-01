from .guard import guard
MODELS=["GPT-5.6 Luna","Claude Sonnet 4.6","GPT-5.6 Sol","DeepSeek Chat","Gemini 2.5 Flash","Grok 4"]
def validate(result):
 plans=result.plans
 verdict="CALL BUY" if plans and plans[0].side=="CE" else "PUT BUY" if plans else "NO QUALIFYING TRADE"
 ok,msg=guard(verdict,plans,result.quality)
 if not ok: verdict="WAIT"
 return {"quality":result.quality,"verdict":verdict,"plans":[p.__dict__ for p in plans],"suppressed":result.suppressed,"ai":{"layers":MODELS,"status":"VALIDATION_ONLY" if ok else "WAIT_OVERRIDE","message":msg}}
