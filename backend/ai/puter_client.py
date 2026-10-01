import os
class PuterClient:
 def __init__(self):self.token=os.getenv("PUTER_AUTH_TOKEN","")
 def enabled(self):return bool(self.token)
