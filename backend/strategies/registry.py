from .catalog import STRATEGY_REGISTRY

def get_strategy(i): return STRATEGY_REGISTRY.get(int(i))
def search(q=""): return [s for s in STRATEGY_REGISTRY.values() if not q or q.lower() in s.name.lower()]
