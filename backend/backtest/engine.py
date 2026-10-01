def summarize(trades: list[dict]) -> dict:
    if not trades:
        return {"trades":0,"expectancy":None,"profit_factor":None}
    pnl=[float(t.get("pnl",0)) for t in trades]
    wins=sum(x for x in pnl if x>0)
    losses=-sum(x for x in pnl if x<0)
    expectancy=sum(pnl)/len(pnl)
    return {"trades":len(pnl),"expectancy":expectancy,
            "profit_factor":(wins/losses if losses else None)}
