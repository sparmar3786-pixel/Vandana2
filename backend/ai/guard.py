ALLOWED={"CALL BUY","PUT BUY","WAIT","NO QUALIFYING TRADE"}
def guard(verdict,plans,quality):
 if quality!="OK":return False,"AI cannot override DATA_GAP"
 if verdict not in ALLOWED:return False,"invalid verdict"
 if verdict in {"CALL BUY","PUT BUY"} and not plans:return False,"AI cannot invent a plan"
 return True,"OK"
