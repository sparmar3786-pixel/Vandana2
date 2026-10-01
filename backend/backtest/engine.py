from dataclasses import dataclass
@dataclass
class BacktestSummary:
 trades:int; wins:int; losses:int; net_r:float
 @property
 def win_rate(self):return self.wins/self.trades if self.trades else None
def summarize(results):
 return BacktestSummary(len(results),sum(r>0 for r in results),sum(r<0 for r in results),sum(results))
