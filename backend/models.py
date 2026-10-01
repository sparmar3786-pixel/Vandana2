from dataclasses import dataclass,field,asdict
@dataclass
class Tick:
 symbol:str; strike:float; side:str; ltp:float; oi:float; oi_change:float; volume:float; iv:float|None=None; bid:float|None=None; ask:float|None=None; timestamp:str=""
@dataclass
class Snapshot:
 symbol:str; underlying:float; atm_strike:float; timestamp:str; calls:list[Tick]=field(default_factory=list); puts:list[Tick]=field(default_factory=list); source:str="unknown"; quality:str="OK"
@dataclass
class TradePlan:
 side:str; strike:float; entry:float; stop_loss:float; targets:list[float]; trailing_sl:str; time_exit:str; rr:float; position_size:int; confidence:float; strategy_ids:list[int]
def to_dict(x): return asdict(x) if hasattr(x,"__dataclass_fields__") else x
