import os

DATA_SOURCE = os.getenv("DATA_SOURCE", "angel_one")
ADVANCED_ENGINE = os.getenv("ADVANCED_ENGINE", "off").lower() in {"1","true","on"}
MIN_TRADE_PLANS = int(os.getenv("MIN_TRADE_PLANS", "5"))
ENABLE_LIVE_ORDERS = os.getenv("ENABLE_LIVE_ORDERS", "0").lower() in {"1","true","on"}
REQUIRE_HUMAN_CONFIRM = os.getenv("REQUIRE_HUMAN_CONFIRM", "1").lower() in {"1","true","on"}
MAX_TICK_AGE_SEC = float(os.getenv("MAX_TICK_AGE_SEC", "60"))
RATE_LIMIT_RPS = float(os.getenv("RATE_LIMIT_RPS", "1"))
