import unittest
from backend.models import Snapshot, OptionLeg
from backend.quality import validate_snapshot
from backend.decision import final_decision

class TerminalContractTests(unittest.TestCase):
    def test_missing_oi_is_data_gap(self):
        snap = Snapshot(index='NIFTY', spot=25000, timestamp=1000, options=[OptionLeg(strike=25000, side='CE', ltp=100, oi=None, volume=10)])
        result = validate_snapshot(snap, now=1001)
        self.assertFalse(result.ok)
        self.assertIn('MISSING_OI', result.reasons)

    def test_stale_snapshot_is_blocked(self):
        snap = Snapshot(index='NIFTY', spot=25000, timestamp=1000, options=[OptionLeg(strike=25000, side='CE', ltp=100, oi=1000, volume=10)])
        result = validate_snapshot(snap, now=1061, max_age=60)
        self.assertFalse(result.ok)
        self.assertIn('STALE_SNAPSHOT', result.reasons)

    def test_no_padding_to_five(self):
        plans = [{'side':'CALL BUY','strike':25000,'entry':100,'sl':75,'target':150}]
        self.assertEqual(final_decision(plans)['trade_count'], 1)

    def test_empty_plans_are_wait(self):
        self.assertEqual(final_decision([])['verdict'], 'NO QUALIFYING TRADE')

if __name__ == '__main__':
    unittest.main()
