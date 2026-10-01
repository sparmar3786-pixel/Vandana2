from .base import BrokerData
class NSEPublicBroker(BrokerData):
 def snapshot(self,symbol):raise RuntimeError("Public NSE fallback is disabled until explicitly configured.")
