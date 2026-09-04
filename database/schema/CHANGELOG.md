# Changelog

## 2026-08-21

Added
- API contracts API-128 through API-139, covering the previously-missing
  functionality gaps: User Management, Role Management, Worklist
  (list/view), Result Entry (view/update), Result Validation (list
  pending), Report (view), Report History, Report Delivery (batch
  send/status), Outsource, Finance Overview, Finance Reports, and Most
  Tested Tests (`database/api_contracts_json/API-128_user_management.json`
  through `API-139_most_tested_tests.json`)
- Each contract reuses existing endpoints wherever the functionality was
  already covered (e.g. create/authorize/generate/release operations) and
  documents two confirmed schema gaps rather than inventing columns:
  `roles` has no `is_active` column (Activate/Deactivate Role is blocked
  pending that column), and there is no outsource-order-level table or
  outsource status column behind Outsource Management

## 2026-08-19

Added
- Test package module: `test_package_master` (bundle definition) and
  `test_package_test_mapping` (member tests of a package)
- `billing_tests.package_id` to trace billing line items generated from a
  package back to the package they came from
- E2E validation for the package flow (`database/e2e-validation/018_test_package.sql`),
  negative-path constraint tests (`database/api_contracts_test/023_test_package.sql`),
  and API contracts API-120 through API-127
- Finance audit follow-up: real master tables behind three previously
  unreferenced `patient_registrations` columns -
  `client_organization_master` (client_id), `referral_master`
  (referral_doctor_id), `agent_master` (agent_id) - each now FK-enforced
- `billing_master.tds_amount`, `.write_off_amount`, `.write_off_reason`,
  `.written_off_by`, `.written_off_at`
- `payment.bank_name`, `.cheque_number`
- E2E validation for the new finance master data
  (`database/e2e-validation/019_finance_master_data.sql`) and 12
  negative-path constraint tests, API-T187 through API-T198
  (`database/api_contracts_test/024_finance_master_data.sql`)

## 2026-07-15

Added
- Appointment module
- Patient Search

Modified
- patient_identifiers uniqueness

Fixed
- FK naming