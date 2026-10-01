import sqlite3
class StrategyMemory:
 def __init__(self,path="strategy_memory.sqlite3"):
  self.db=sqlite3.connect(path,check_same_thread=False); self.db.execute("create table if not exists outcomes(strategy_id integer,result real,ts text default current_timestamp)"); self.db.commit()
 def record(self,strategy_id,result):self.db.execute("insert into outcomes(strategy_id,result) values(?,?)",(strategy_id,result));self.db.commit()
 def recent(self,limit=100):return self.db.execute("select strategy_id,result,ts from outcomes order by rowid desc limit ?",(limit,)).fetchall()
