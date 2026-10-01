from abc import ABC,abstractmethod
class BrokerData(ABC):
 @abstractmethod
 def snapshot(self,symbol):raise NotImplementedError
