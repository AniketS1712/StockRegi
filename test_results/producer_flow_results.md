# Producer Flow Integration Test Results

**Run at:** 2026-09-16T16:56:56.240216

**Summary: 10 of 10 tests passed**

---

| # | Description | Expected | Actual | Result |
|---|-------------|----------|--------|--------|
| 1 | Purchase raw material → item/tx/line/stock correct | is_raw=true, type=purchase, 1 line dir=in qty=100.0, stock=100.0 | is_raw=true, type=purchase, lines=1 dir=in qty=100.0, stock=100.0 | ✅ PASS |
| 2 | Second purchase same item → dedup + cumulative stock | same_id, 1 item row, stock=150.0 | same_id=true, rows=1, stock=150.0 | ✅ PASS |
| 3 | Purchase finished good → is_fg=true, is_raw=false, stock correct | is_fg=true, is_raw=false, stock=20.0 | is_fg=true, is_raw=false, stock=20.0 | ✅ PASS |
| 4 | Production → raw stock ↓, FG stock ↑, 2 lines same tx_id | type=production, lines=2, all_same_tx, raw=120.0, fg=5.0 | type=production, lines=2, all_same=true, raw=120.0, fg=5.0 | ✅ PASS |
| 5 | Production > stock → "Not enough" error, stock unchanged, no orphan tx | "Not enough" in error, stock=120.0, tx_count=4 | has_error=true("PostgrestException(message: Not enough TEST_Steel Rod in sto..."), stock=120.0, tx_count=4 | ✅ PASS |
| 6 | createOrder → stock decreases, type=order, line dir=out | type=order, stock=3.0, dir=out | type=order, stock=3.0, dir=out | ✅ PASS |
| 7 | createOrder > stock → "Not enough" error, stock unchanged, no orphan tx | "Not enough" in error, stock=3.0, tx_count=5 | has_error=true("PostgrestException(message: Not enough TEST_Steel Widget Pro..."), stock=3.0, tx_count=5 | ✅ PASS |
| 8 | Security: A calls create_production with B business_id → rejected | "Not authorized" error, no rows in B | rejected=true("PostgrestException(message: Not authorized for this business..."), no_rows=true | ✅ PASS |
| 9 | Security: A calls create_order with B item_id → rejected | "does not belong" error | rejected=true("PostgrestException(message: Item 5506ff7a-bed3-405d-aad4-a57...") | ✅ PASS |
| 10 | Isolation: A queries never show B items/stock | B not in A stock_levels, B not in A items | b_in_stock=false, b_in_items=false | ✅ PASS |

---

🎉 All tests passed.
