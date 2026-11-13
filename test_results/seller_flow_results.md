# Seller Flow Integration Test Results

**Run at:** 2026-09-16T16:56:31.865867

**Summary: 9 of 9 tests passed**

---

| # | Description | Expected | Actual | Result |
|---|-------------|----------|--------|--------|
| 1 | Add Stock on new item → item created, type=purchase, stock correct | item created, type=purchase, stock=50.0 | itemExists=true, type=purchase, stock=50.0 | ✅ PASS |
| 2 | Add Stock on same item again → same item_id, cumulative stock | same_id=true, item_rows=1, stock=80.0 | same_id=true, item_rows=1, stock=80.0 | ✅ PASS |
| 3 | Add Stock with new category & attributes → category, keys, attributes created | category exists, 2 attribute_keys, 2 item_attributes, stock=15.0 | catExists=true, keysCount=2, attrsCount=2, stock=15.0 | ✅ PASS |
| 4 | createOrder for valid qty → stock decreases, type=order, line dir=out | type=order, dir=out, stock=55.0 | type=order, dir=out, stock=55.0 | ✅ PASS |
| 5 | createOrder > stock → "Not enough" error, stock unchanged, no orphan tx | "Not enough" in error, stock=55.0, tx_count=4 | has_error=true("PostgrestException(message: Not enough TEST_Cotton Shirt in ..."), stock=55.0, tx_count=4 | ✅ PASS |
| 6 | Security: Seller A calls create_order with Seller B business_id → rejected | "Not authorized" error, no rows written in B | rejected=true("PostgrestException(message: Not authorized for this business..."), no_rows=true | ✅ PASS |
| 7 | Security: Seller A calls create_order with Seller B item_id → rejected | "does not belong" error | rejected=true("PostgrestException(message: Item a5d8fd59-ca7f-4030-ad02-1aa...") | ✅ PASS |
| 8 | Isolation: Seller A queries never show Seller B items/stock | B not in A stock_levels, B not in A items | b_in_stock=false, b_in_items=false | ✅ PASS |
| 9 | Role Boundary Check: Seller A (role=seller) calls create_production RPC | Observed backend behavior recorded (succeeds or rejects based on DB role enforcement) | RPC succeeded (no role check on create_production) | ✅ PASS |

---

### Notes & Observations
FINDING: Calling create_production as Seller A (role='seller') SUCCEEDED (txId=afc48597-5ba9-4de7-9fac-3e8de13d7309). The database RPC currently checks business ownership (owner_id = auth.uid()) but does NOT enforce a role='producer' check. This represents an access-control gap at the DB level worth closing if seller accounts should be strictly prohibited from running production via direct RPC.

---

🎉 All tests passed.
