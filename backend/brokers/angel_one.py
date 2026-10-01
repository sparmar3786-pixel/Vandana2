import os
from .base import BrokerData
class AngelOneBroker(BrokerData):
 def __init__(self):self.api_key=os.getenv("ANGEL_API_KEY","");self.client_id=os.getenv("ANGEL_CLIENT_ID","")
 def snapshot(self,symbol):raise RuntimeError("Angel One session is not configured; credentials are never bundled.")
def credentials_configured():return all(os.getenv(k) for k in ("ANGEL_API_KEY","ANGEL_CLIENT_ID","ANGEL_PIN","ANGEL_TOTP_SECRET"))
