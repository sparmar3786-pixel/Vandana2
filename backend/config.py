import os
from dataclasses import dataclass
@dataclass(frozen=True)
class Settings:
 app_name:str=os.getenv("APP_NAME","VandanaSachin"); data_source:str=os.getenv("DATA_SOURCE","demo"); advanced_engine:bool=os.getenv("ADVANCED_ENGINE","off").lower()=="on"; min_trade_plans:int=int(os.getenv("MIN_TRADE_PLANS","5")); enable_live_orders:bool=os.getenv("ENABLE_LIVE_ORDERS","0")=="1"; require_human_confirm:bool=os.getenv("REQUIRE_HUMAN_CONFIRM","1")=="1"; min_rr:float=float(os.getenv("MIN_RR","1.5")); max_risk_per_trade:float=float(os.getenv("MAX_RISK_PER_TRADE","0.01")); max_total_risk:float=float(os.getenv("MAX_TOTAL_RISK","0.05")); max_tick_age_sec:int=int(os.getenv("MAX_TICK_AGE_SEC","5")); max_snapshot_age_sec:int=int(os.getenv("MAX_SNAPSHOT_AGE_SEC","15")); rate_limit_rps:float=float(os.getenv("RATE_LIMIT_RPS","1")); ai_enabled:bool=os.getenv("AI_ENABLED","0")=="1"; mcp_enabled:bool=os.getenv("MCP_ENABLED","0")=="1"; mcp_config_path:str=os.getenv("MCP_CONFIG_PATH","config/mcp_servers.json")
settings=Settings()
