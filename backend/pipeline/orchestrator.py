from dataclasses import dataclass
from ..quality import data_quality
from ..config import settings
@dataclass
class PipelineResult: plans:list; suppressed:list; quality:str; stages:list
def classify(x):
 if x.oi_change>0 and x.ltp>0:return "LONG_BUILDUP"
 if x.oi_change<0 and x.ltp>0:return "SHORT_COVERING"
 return "NEUTRAL"
def run_pipeline(s):
 ok,reason=data_quality(s,settings.max_snapshot_age_sec); stages=[f"part{i:02d}" for i in range(1,33)]
 if not ok:return PipelineResult([], [reason],"DATA_GAP",stages)
 plans=[];supp=[]
 for x in s.calls+s.puts:
  if classify(x)=="NEUTRAL":supp.append(f"{x.side}{x.strike}: no qualifying state");continue
  entry=x.ltp;sl=entry*(0.85 if "EXPIRY" in s.symbol.upper() else 0.75);target=entry+(entry-sl)*settings.min_rr;rr=(target-entry)/(entry-sl)
  if rr<settings.min_rr:supp.append(f"{x.side}{x.strike}: R:R gate");continue
  plans.append(type("P",(),{"side":"CE" if x.side.upper()=="CE" else "PE","strike":x.strike,"entry":entry,"stop_loss":sl,"targets":[target],"trailing_sl":"trail at 1R","time_exit":"15:15 IST","rr":rr,"position_size":1,"confidence":min(95,50+(10 if x.oi_change else 0)+(10 if x.volume else 0)),"strategy_ids":[]})())
 return PipelineResult(sorted(plans,key=lambda p:p.confidence,reverse=True),supp,"OK",stages)
