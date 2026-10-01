import sqlite3
from pathlib import Path

class StrategyMemory:
    def __init__(self, path="strategy_memory.sqlite3"):
        self.path=Path(path)
        with sqlite3.connect(self.path) as db:
            db.execute("CREATE TABLE IF NOT EXISTS observations (id INTEGER PRIMARY KEY, strategy_id INTEGER, ts REAL, payload TEXT)")
    def add(self, strategy_id:int, ts:float, payload:str):
        with sqlite3.connect(self.path) as db:
            db.execute("INSERT INTO observations(strategy_id,ts,payload) VALUES(?,?,?)",(strategy_id,ts,payload))
    def count(self, strategy_id=None):
        with sqlite3.connect(self.path) as db:
            if strategy_id is None:
                return db.execute("SELECT COUNT(*) FROM observations").fetchone()[0]
            return db.execute("SELECT COUNT(*) FROM observations WHERE strategy_id=?",(strategy_id,)).fetchone()[0]
