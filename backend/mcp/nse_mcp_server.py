import argparse
def main():
 p=argparse.ArgumentParser();p.add_argument("--transport",default="stdio");p.add_argument("--port",type=int,default=8765);p.parse_args();print("VandanaSachin NSE MCP boundary ready")
if __name__=="__main__":main()
