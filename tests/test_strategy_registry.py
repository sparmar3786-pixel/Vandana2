import unittest
from backend.strategies.registry import STRATEGY_REGISTRY

class StrategyRegistryTests(unittest.TestCase):
    def test_exact_377_modules(self):
        self.assertEqual(len(STRATEGY_REGISTRY), 377)
        self.assertEqual(sorted(STRATEGY_REGISTRY), list(range(1, 378)))

if __name__ == '__main__':
    unittest.main()
