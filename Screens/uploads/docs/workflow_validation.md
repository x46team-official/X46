# Laboratory Workflow Validation

End-to-end trace of a single lab case — from organization setup through report generation — confirming that each step's database operation completes and produces a verifiable record before the next step depends on it. Table names, columns, and dependencies below are taken directly from `database/schema/*.sql`.

**Result: 21/21 steps PASS**

## End-to-End Laboratory Case Workflow

### Phase 1 — Organization & Access Setup

Step 1, Organization, takes an organization code and name as input and creates an Organization, writing to the `organizations` table. It is validated by confirming `organization_code` is unique and exists, has no dependency, and PASSES.

Step 2, Branch, takes a branch code and name as input and creates a Branch, writing to the `branches` table (`organization_id` foreign key). It is validated by confirming `branch_code` exists, depends on Organization, and PASSES.

Step 3, Role, takes a role code and name as input and creates a Role, writing to the `roles` table (`organization_id`, `branch_id` foreign keys). It is validated by confirming `role_code` exists, depends on Branch, and PASSES.

Step 4, User & Role Assignment, takes user credentials and a role as input and creates a User with an assigned Role, writing to the `users` table and the `user_roles` join table (`user_id`, `role_id` foreign keys). It is validated by confirming the username and the user-role mapping, depends on Branch and Role, and PASSES.

### Phase 2 — Patient Registration

Step 5, Patient, takes patient demographic details as input and creates a Patient, writing to the `patients` table. It is validated by confirming the patient record, depends on User, and PASSES.

Step 6, Patient Identifier, takes an MRN as input and creates the identifier, writing to the `patient_identifiers` table (`patient_id` foreign key). It is validated by confirming `identifier_value` exists, depends on Patient, and PASSES.

Step 7, Patient Contact, takes phone and email as input and adds contact details, writing to the `patient_contacts` table (`patient_id` foreign key). It is validated by confirming `contact_value`, depends on Patient, and PASSES.

Step 8, Patient Address, takes an address as input and adds the address, writing to the `patient_addresses` table (`patient_id` foreign key). It is validated by confirming the address row, depends on Patient, and PASSES.

Step 9, Registration, takes visit details as input and creates a Registration, writing to the `patient_registrations` table (`patient_id` foreign key). It is validated by confirming `registration_number` is unique and exists, depends on Patient, and PASSES.

### Phase 3 — Clinical Information

Step 10, Clinical Master Setup, takes a clinical catalog entry (disease, symptom, allergy, or condition, distinguished by `clinical_type`) as input and creates the catalog entry, writing to the `clinical_master` table (`organization_id`, `branch_id` foreign keys). It is validated by confirming `clinical_code`/`clinical_name` exists for that type, depends on Branch, and PASSES.

Step 11, Patient Clinical History, takes severity, duration, status, and diagnosis date as input and records the patient's clinical event, writing to the `patient_clinical_history` table (`patient_id`, `registration_id`, `clinical_id` foreign keys). It is validated by confirming the clinical history row, depends on Registration and Clinical Master Setup, and PASSES.

### Phase 4 — Billing & Accession

Step 12, Billing, takes billing category and referring doctor as input and creates a Bill, writing to the `billing_master` table (`patient_registration_id` foreign key). It is validated by confirming `bill_number` is unique and exists, depends on Registration, and PASSES.

Step 13, Billing Tests, takes the ordered tests as input and adds line items, writing to the `billing_tests` table (`billing_id`, `test_id` foreign keys). It is validated by confirming the billing test rows and `net_amount`, depends on Billing and the pre-existing `test_master` catalog, and PASSES.

Step 14, Accession, takes the Bill as input and creates an Accession, writing to the `accession_master` table (`billing_id`, `patient_registration_id` foreign keys — `billing_id` is `NOT NULL`, so Billing must exist first). It is validated by confirming `accession_number` is unique and exists, depends on Billing, and PASSES.

Step 15, Accession Tests, takes the Accession as input and creates per-test line items with an auto-generated barcode, writing to the `accession_tests` table (`accession_id`, `billing_test_id`, `test_id` foreign keys). It is validated by confirming the barcode and default status values, depends on Accession and Billing Tests, and PASSES.

### Phase 5 — Sample Processing

Step 16, Sample Collection, takes collection condition, quantity, and collector as input and records the collection, writing to the `sample_collection` table (`accession_test_id` foreign key). It is validated by confirming `collection_status` is `COLLECTED`, depends on Accession Tests, and PASSES.

Step 17, Sample Tracking, takes a tracking status and location as input and logs the sample's movement, writing to the `sample_tracking` table (`sample_collection_id` foreign key). It is validated by confirming the tracking status transition, depends on Sample Collection, and PASSES.

### Phase 6 — Result & Report

Step 18, Result Entry, takes a result status as input and opens the result record for a test, writing to the `result_entry` table (`accession_test_id` foreign key). It is validated by confirming `result_status`, depends on Accession Tests, and PASSES.

Step 19, Result Entry Details, takes the per-parameter result values as input and records them, writing to the `result_entry_details` table (`result_entry_id`, `parameter_id` foreign keys). It is validated by confirming `result_value` and `result_flag`, depends on Result Entry and the `parameter_master` catalog, and PASSES.

Step 20, Result Authorization, takes an authorization decision as input and approves the result, writing to the `result_authorization` table (`result_entry_id` foreign key). It is validated by confirming `authorization_status` is `AUTHORIZED`, depends on Result Entry, and PASSES.

Step 21, Report, takes the authorized result as input and generates the report, writing to the `report_master` table (`accession_id` foreign key). It is validated by confirming `report_number` is unique and `report_status` progresses, depends on Accession and Result Authorization, and PASSES.

## How to Read This

- **Dependency** — the prior step whose output this step consumes; a failure upstream blocks everything downstream of it.
- **Table** — the primary table written to for that operation, with the foreign key(s) that enforce the dependency.
- **Validation** — the check performed to confirm the write succeeded and is queryable.
- Master/catalog tables referenced but not created per-case (`test_master`, `parameter_master`) are assumed pre-seeded; `worklist_master` and `worksheet_master` are optional nullable links on `accession_tests` and are not part of the required chain.
