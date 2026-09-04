-- 
-- E001 - PATIENT JOURNEY (END-TO-END VALIDATION)
-- Registration -> Clinical History -> Billing -> Accession -> Payment ->
-- Sample Collection -> Result Entry -> Authorization -> Report Generation
-- See database/e2e-validation/patient_journel.md for the full step-by-step
-- narrative and expected output for this script.
-- 

\set ON_ERROR_STOP on

BEGIN;

-- Step 1 - Organization Selection: scope every record below to LAB002
SELECT id as organization_id
from organizations
where organization_code ='LAB002'
\gset

-- Step 2 - Branch Selection: scope every record below to PUNE002
SELECT id as branch_id

from branches
where organization_id = :'organization_id'
AND branch_code ='PUNE002'
\gset

-- Step 3 - User Identification: admin user is the creator/actor for all records
SELECT id as admin_user_id
from users
where organization_id=:'organization_id'
AND username='admin'
\gset

\echo Admin User ID = :admin_user_id

-- Step 4 - Patient Registration: create the patient master record

INSERT into patients
(
  organization_id,
  branch_id,
  patient_type,
  first_name,
  last_name,
  gender,
  date_of_birth,
  patient_category,
  is_active,
  created_by
)
values
(
  :'organization_id',
  :'branch_id',
  'OUTPATIENT',
  'Manas',
  'Gaikwad',
  'Male',
  DATE '2005-01-01',
  'GENERAL',
  TRUE,
  :'admin_user_id'
)
returning id as patient_id
\gset

-- Step 5 - Patient Identifier Creation: assign an MRN to the patient
INSERT INTO patient_identifiers
(
    organization_id,
    branch_id,
    patient_id,
    identifier_type,
    identifier_value,
    is_primary
)
VALUES
(
    :'organization_id',
    :'branch_id',
    :'patient_id',
    'MRN2',
    'MMRN-20260806-002',
    TRUE
);

-- Step 6 - Patient Contact Creation: record the primary mobile number
insert into patient_contacts
(
  organization_id,
  branch_id,
  patient_id,
  contact_type,
  contact_value,
  whatsapp_consent,
  is_primary,
  created_by
)
values
(
  :'organization_id',
  :'branch_id',
  :'patient_id',
  'MOBILE',
  '9000001002',
  TRUE,
  TRUE,
  :'admin_user_id'
);

-- Step 7 - Patient Address Creation: record the primary home address
INSERT INTO patient_addresses
(
  organization_id,
  branch_id,
  patient_id,
  address_type,
  address_line1,
  city,
  district,
  state,
  country,
  pincode,
  is_primary,
  created_by
)
values(
  :'organization_id',
  :'branch_id',
  :'patient_id',
  'HOME',
  'Yerwaada',
  'Pune',
  'PUNE',
  'Maharashtra',
  'INDIA',
  '411041',
  TRUE,
  :'admin_user_id'
  );



-- Step 8 - Patient Registration (Visit): open a lab visit for the patient
INSERT INTO patient_registrations
(
  organization_id,
  branch_id,
  patient_id,
  registration_number,
  registration_status,
  created_by
)
values
(
  :'organization_id',
  :'branch_id',
  :'patient_id',
  'REG003',
  'REGISTERED',
  :'admin_user_id'

)
returning id as registration_id
\gset

-- Step 9 - Clinical Master Setup: seed reference disease/symptom/allergy
-- entries (idempotent via ON CONFLICT DO NOTHING so re-runs are safe)
INSERT INTO clinical_master
(
   organization_id,
   branch_id,
    clinical_type,
    clinical_code,
    clinical_name,
    description,
    created_by
)
values
(
  :'organization_id',
  :'branch_id',
  'DISEASE',
  'DIS001',
  'Diabetes Mellitus',
  'type 2 diabetes',
  :'admin_user_id'
)
ON CONFLICT (organization_id, branch_id, clinical_type, clinical_name)
DO NOTHING;

INSERT INTO clinical_master
(
  organization_id,
  branch_id,
  clinical_type,
  clinical_code,
  clinical_name,
  description,
  created_by
)
values
(
  :'organization_id',
  :'branch_id',
  'SYMPTOM',
  'SYM001',
   'Fever',
    'High body temperature',
    :'admin_user_id'
)
ON CONFLICT (organization_id, branch_id, clinical_type, clinical_name)
DO NOTHING;


INSERT INTO clinical_master
(
    organization_id,
   branch_id,
    clinical_type,
    clinical_code,
    clinical_name,
    description,
    created_by
)
VALUES
(
    :'organization_id',
    :'branch_id',
    'ALLERGY',
    'ALG001',
    'Penicillin Allergy',
    'Drug Allergy',
    :'admin_user_id'
)
ON CONFLICT (organization_id, branch_id, clinical_type, clinical_name)
DO NOTHING;

-- Step 10 - Patient Clinical History: link the patient to Diabetes Mellitus
INSERT INTO patient_clinical_history
(
    organization_id,
    branch_id,
    patient_id,
    clinical_id,
    diagnosed_date,
    status,
    notes,
    created_by
)
SELECT
    :'organization_id',
    :'branch_id',
    :'patient_id',
    id,
    DATE '2024-01-10',
    'ACTIVE',
    'Known diabetic patient',
    :'admin_user_id'
FROM clinical_master
WHERE organization_id = :'organization_id'
AND branch_id = :'branch_id'
AND clinical_name = 'Diabetes Mellitus';

-- Step 10 (cont.) - link the patient to the Fever symptom (with severity/duration)
INSERT INTO patient_clinical_history
(
    organization_id,
    branch_id,
    patient_id,
    registration_id,
    clinical_id,
    severity,
    duration_value,
    duration_unit,
    status,
    notes,
    created_by
)
SELECT
    :'organization_id',
    :'branch_id',
    :'patient_id',
    :'registration_id',
    id,
    'MODERATE',
    3,
    'DAY',
    'ACTIVE',
    'Fever since last three days',
    :'admin_user_id'
FROM clinical_master
WHERE organization_id = :'organization_id'
AND branch_id = :'branch_id'
AND clinical_name = 'Fever';

-- Step 10 (cont.) - link the patient to the Penicillin Allergy
INSERT INTO patient_clinical_history
(
    organization_id,
    branch_id,
    patient_id,
    clinical_id,
    status,
    notes,
    created_by
)
SELECT
    :'organization_id',
    :'branch_id',
    :'patient_id',
    id,
    'ACTIVE',
    'Patient allergic to Penicillin',
    :'admin_user_id'
FROM clinical_master
WHERE organization_id = :'organization_id'
AND branch_id = :'branch_id'
AND clinical_name = 'Penicillin Allergy';

-- ### Phase 4 - Billing & Accession

-- Step 11 - Billing Master: raise a bill for the CBC001 test under the PATH
-- billing category, linked to the patient's registration
WITH bill_ctx AS (
    SELECT
        o.id AS organization_id,
        pr.branch_id,
        pr.id AS registration_id,
        u.id AS created_by,
        bcm.id AS billing_category_id,
        tm.id AS test_id,
        tm.sample_type_id,
        tm.performing_lab_id,
        tm.selling_price,
        tm.tat_minutes
    FROM organizations o

    JOIN patient_registrations pr
      ON pr.organization_id = o.id

    JOIN users u
      ON u.id = pr.created_by

    JOIN billing_category_master bcm
      ON bcm.organization_id = o.id

    JOIN test_master tm
      ON tm.organization_id = o.id

    WHERE o.organization_code = 'LAB002'
      AND pr.id = :'registration_id'
      AND bcm.billing_category_code = 'PATH'
      AND tm.test_code = 'CBC001'
)

INSERT INTO billing_master
(
    organization_id,
    branch_id,
    patient_registration_id,
    bill_number,
    bill_date,
    billing_category_id,
    total_amount,
    discount_amount,
    concession_amount,
    additional_amount,
    payable_amount,
    paid_amount,
    balance_amount,
    payment_status,
    created_by
)
SELECT
    organization_id,
    branch_id,
    registration_id,
    'BILL0002',
    CURRENT_TIMESTAMP,
    billing_category_id,
    selling_price,
    0,
    0,
    0,
    selling_price,
    0,
    selling_price,
    'Pending',
    created_by
FROM bill_ctx
ON CONFLICT (organization_id, branch_id, bill_number)
DO NOTHING;


-- Step 12 - Billing Tests: attach the CBC001 test line item to the bill
WITH bill_ctx AS
(
    SELECT
        bm.id AS billing_id,
        bm.organization_id,
        bm.branch_id,
        bm.created_by,
        tm.id AS test_id,
        tm.sample_type_id,
        tm.performing_lab_id,
        tm.selling_price,
        tm.tat_minutes
    FROM billing_master bm

    JOIN organizations o
      ON o.id = bm.organization_id

    JOIN test_master tm
      ON tm.organization_id = bm.organization_id

    WHERE o.organization_code = 'LAB002'
      AND bm.bill_number = 'BILL0002'
      AND tm.test_code = 'CBC001'
)

INSERT INTO billing_tests
(
    organization_id,
    branch_id,
    billing_id,
    test_id,
    sample_type_id,
    performing_lab_id,
    quantity,
    rate,
    discount_amount,
    concession_amount,
    net_amount,
    tat_minutes,
    status,
    created_by
)
SELECT
    organization_id,
    branch_id,
    billing_id,
    test_id,
    sample_type_id,
    performing_lab_id,
    1,
    selling_price,
    0,
    0,
    selling_price,
    tat_minutes,
    'Pending',
    created_by
FROM bill_ctx
WHERE NOT EXISTS
(
    SELECT 1
    FROM billing_tests bt
    WHERE bt.billing_id = bill_ctx.billing_id
      AND bt.test_id = bill_ctx.test_id
);

-- Step 13 - Accession Creation: open an accession against the bill
WITH acc_ctx AS (
    SELECT
        bm.organization_id,
        bm.branch_id,
        bm.id AS billing_id,
        bm.patient_registration_id,
        u.id AS admin_user_id
    FROM billing_master bm
    JOIN organizations o
      ON o.id = bm.organization_id
    JOIN users u
      ON u.organization_id = bm.organization_id
     AND u.username = 'admin'
    WHERE o.organization_code = 'LAB002'
      AND bm.bill_number = 'BILL0002'
)

INSERT INTO accession_master
(
    organization_id,
    branch_id,
    billing_id,
    patient_registration_id,
    accession_number,
    accession_date,
    priority,
    status,
    remarks,
    created_by
)
SELECT
    organization_id,
    branch_id,
    billing_id,
    patient_registration_id,
    'ACC0003',
    CURRENT_TIMESTAMP,
    'NORMAL',
    'PENDING',
    'Patient Journey Validation',
    admin_user_id
FROM acc_ctx
ON CONFLICT (organization_id, branch_id, accession_number)
DO NOTHING;


-- Step 14 - Accession Tests: create the per-test accession record with a
-- generated barcode, initial sample/collection/authorization/report statuses
WITH ctx AS
(
    SELECT
        am.id AS accession_id,
        am.organization_id,
        am.branch_id,
        bt.id AS billing_test_id,
        bt.test_id,
        bt.sample_type_id,
        bt.performing_lab_id,
        u.id AS admin_user_id
    FROM accession_master am
    JOIN billing_master bm
      ON bm.id = am.billing_id
    JOIN organizations o
      ON o.id = am.organization_id
    JOIN billing_tests bt
      ON bt.billing_id = bm.id
    JOIN users u
      ON u.organization_id = am.organization_id
     AND u.username = 'admin'
    WHERE o.organization_code = 'LAB002'
      AND am.accession_number = 'ACC0003'
)

INSERT INTO accession_tests
(
    organization_id,
    branch_id,
    accession_id,
    billing_test_id,
    test_id,
    sample_type_id,
    performing_lab_id,
    barcode,
    barcode_status,
    print_count,
    sample_status,
    collection_status,
    authorization_status,
    report_status,
    remarks,
    created_by
)
SELECT
    organization_id,
    branch_id,
    accession_id,
    billing_test_id,
    test_id,
    sample_type_id,
    performing_lab_id,
     'BC' || to_char(CURRENT_TIMESTAMP, 'YYYYMMDDHH24MISSMS'),
    'GENERATED',
    0,
    'PENDING',
    'NOT_COLLECTED',
    'PENDING',
    'PENDING',
    'Awaiting sample collection',
    admin_user_id
FROM ctx
WHERE NOT EXISTS
(
    SELECT 1
    FROM accession_tests at
    WHERE at.accession_id = ctx.accession_id
      AND at.billing_test_id = ctx.billing_test_id
);

-- Step 15 - Payment: capture full cash payment against the bill/accession
WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        bm.branch_id,
        u.id AS admin_user_id,
        pr.id AS registration_id,
        bm.id AS billing_id,
        am.id AS accession_id,
        bm.payable_amount
    FROM organizations o

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    JOIN billing_master bm
        ON bm.organization_id = o.id

    JOIN accession_master am
        ON am.billing_id = bm.id

    JOIN patient_registrations pr
        ON pr.id = bm.patient_registration_id

    WHERE o.organization_code = 'LAB002'
      AND bm.bill_number = 'BILL0002'
      AND am.accession_number = 'ACC0003'
)

INSERT INTO payment
(
    organization_id,
    branch_id,
    accession_id,
    billing_master_id,
    patient_registration_id,
    payment_mode,
    amount_paid,
    transaction_reference,
    payment_status,
    remarks,
    created_by
)
SELECT
    ctx.organization_id,
    ctx.branch_id,
    ctx.accession_id,
    ctx.billing_id,
    ctx.registration_id,
    'CASH',
    ctx.payable_amount,
    'TXN0001',
    'SUCCESS',
    'E2E Payment Validation',
    ctx.admin_user_id
FROM ctx
WHERE NOT EXISTS
(
    SELECT 1
    FROM payment p
    WHERE p.billing_master_id = ctx.billing_id
);


-- Step 16 - Billing Update: mark the bill Paid now that payment succeeded

WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        bm.branch_id,
        u.id AS admin_user_id,
        bm.id AS billing_id
    FROM organizations o

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    JOIN billing_master bm
        ON bm.organization_id = o.id

    WHERE o.organization_code = 'LAB002'
      AND bm.bill_number = 'BILL0002'
)
UPDATE billing_master bm
SET
    paid_amount = bm.payable_amount,
    balance_amount = 0,
    payment_mode = 'CASH',
    payment_status = 'Paid',
    transaction_reference = 'TXN0001',
    updated_by = ctx.admin_user_id,
    updated_at = CURRENT_TIMESTAMP
FROM ctx
WHERE bm.id = ctx.billing_id
  AND (
        bm.paid_amount <> bm.payable_amount
     OR bm.balance_amount <> 0
     OR bm.payment_status <> 'Paid'
     OR bm.payment_mode <> 'CASH'
  );


-- Step 17 - Sample Collection: record the collected specimen for the test
WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        at.branch_id,
        u.id AS collector_id,
        am.id AS accession_id,
        at.id AS accession_test_id
    FROM organizations o

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    JOIN accession_master am
        ON am.organization_id = o.id

    JOIN accession_tests at
        ON at.accession_id = am.id

    WHERE o.organization_code = 'LAB002'
      AND am.accession_number = 'ACC0003'
)

INSERT INTO sample_collection
(
    organization_id,
    branch_id,
    accession_test_id,
    collector_id,
    collection_datetime,
    collection_location,
    sample_condition,
    quantity,
    quantity_unit,
    collection_status,
    remarks,
    created_by
)
SELECT
    ctx.organization_id,
    ctx.branch_id,
    ctx.accession_test_id,
    ctx.collector_id,
    CURRENT_TIMESTAMP,
    'Sample Collection Center',
    'GOOD',
    5,
    'mL',
    'COLLECTED',
    'E2E Sample Collection Validation',
    ctx.collector_id
FROM ctx
where NOT EXISTS
(
    SELECT 1
    FROM  sample_collection sc
    where sc.accession_test_id = ctx.accession_test_id
);

-- Step 18 - Accession Test Status Update: reflect COLLECTED on the accession test
WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        at.branch_id,
        u.id AS collector_id,
        am.id AS accession_id,
        at.id AS accession_test_id
    FROM organizations o

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    JOIN accession_master am
        ON am.organization_id = o.id

    JOIN accession_tests at
        ON at.accession_id = am.id

    WHERE o.organization_code = 'LAB002'
      AND am.accession_number = 'ACC0003'
)

UPDATE accession_tests at
SET
    sample_status = 'COLLECTED',
    collection_status = 'COLLECTED',
    updated_by = ctx.collector_id,
    updated_at = CURRENT_TIMESTAMP
FROM ctx
WHERE at.id = ctx.accession_test_id
AND
(
       at.sample_status <> 'COLLECTED'
    OR at.collection_status <> 'COLLECTED'
);


-- Step 19 - Result Entry: create a result entry record for the accession test
WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        at.branch_id,
        u.id AS admin_user_id,
        at.id AS accession_test_id
    FROM organizations o

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    JOIN accession_master am
        ON am.organization_id = o.id

    JOIN accession_tests at
        ON at.accession_id = am.id

    WHERE o.organization_code = 'LAB002'
      AND am.accession_number = 'ACC0003'
)

INSERT INTO result_entry
(
    organization_id,
    branch_id,
    accession_test_id,
    result_status,
    entered_at,
    entered_by,
    created_by
)
SELECT
    organization_id,
    branch_id,
    accession_test_id,
    'COMPLETED',
    CURRENT_TIMESTAMP,
    admin_user_id,
    admin_user_id
FROM ctx
WHERE NOT EXISTS
(
    SELECT 1
    FROM result_entry re
    WHERE re.organization_id = ctx.organization_id
      AND re.branch_id = ctx.branch_id
      AND re.accession_test_id = ctx.accession_test_id
);


-- Step 20 - Result Entry Details: record a value for every mapped CBC parameter
WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        re.branch_id,
        u.id AS admin_user_id,
        re.id AS result_entry_id,
        tpm.parameter_id
    FROM organizations o

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    JOIN accession_master am
        ON am.organization_id = o.id

    JOIN accession_tests at
        ON at.accession_id = am.id

    JOIN result_entry re
        ON re.accession_test_id = at.id

    JOIN test_parameter_mapping tpm
        ON tpm.test_id = at.test_id

    WHERE o.organization_code = 'LAB002'
      AND am.accession_number = 'ACC0003'
)

INSERT INTO result_entry_details
(
    organization_id,
    branch_id,
    result_entry_id,
    parameter_id,
    result_value,
    result_flag,
    created_by
)
SELECT
    organization_id,
    branch_id,
    result_entry_id,
    parameter_id,
    '10',
    'NORMAL',
    admin_user_id
FROM ctx
WHERE NOT EXISTS
(
    SELECT 1
    FROM result_entry_details red
    WHERE red.result_entry_id = ctx.result_entry_id
      AND red.parameter_id = ctx.parameter_id
);


-- Step 21 - Result Entry Completion: mark the result entry COMPLETED

WITH ctx AS
(
    SELECT
        re.id AS result_entry_id,
        u.id AS admin_user_id
    FROM organizations o

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    JOIN accession_master am
        ON am.organization_id = o.id

    JOIN accession_tests at
        ON at.accession_id = am.id

    JOIN result_entry re
        ON re.accession_test_id = at.id

    WHERE o.organization_code = 'LAB002'
      AND am.accession_number = 'ACC0003'
)

UPDATE result_entry re
SET
    result_status = 'COMPLETED',
    entered_at = CURRENT_TIMESTAMP,
    entered_by = ctx.admin_user_id,
    updated_at = CURRENT_TIMESTAMP,
    updated_by = ctx.admin_user_id
FROM ctx
WHERE re.id = ctx.result_entry_id
  AND re.result_status <> 'COMPLETED';


-- Step 21 (cont.) - Accession Test Completion: mark sample_status COMPLETED

WITH ctx AS
(
    SELECT
        at.id AS accession_test_id,
        u.id AS admin_user_id
    FROM organizations o

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    JOIN accession_master am
        ON am.organization_id = o.id

    JOIN accession_tests at
        ON at.accession_id = am.id

    WHERE o.organization_code = 'LAB002'
      AND am.accession_number = 'ACC0003'
)

UPDATE accession_tests at
SET
    sample_status = 'COMPLETED',
    updated_at = CURRENT_TIMESTAMP,
    updated_by = ctx.admin_user_id
FROM ctx
WHERE at.id = ctx.accession_test_id
  AND at.sample_status <> 'COMPLETED';

-- Step 22 - Result Authorization: authorize the CBC001 result entry
WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        u.id AS admin_user_id,
        re.id AS result_entry_id,
        at.id AS accession_test_id
    FROM organizations o
    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'
    JOIN accession_master am
        ON am.organization_id = o.id
       AND am.accession_number = 'ACC0003'
    JOIN accession_tests at
        ON at.accession_id = am.id
    JOIN test_master tm
        ON tm.id = at.test_id
       AND tm.test_code = 'CBC001'
    JOIN result_entry re
        ON re.accession_test_id = at.id
    WHERE o.organization_code = 'LAB002'
)

UPDATE result_entry re
SET
    result_status = 'AUTHORIZED',
    verified_at = CURRENT_TIMESTAMP,
    verified_by = ctx.admin_user_id,
    updated_at = CURRENT_TIMESTAMP,
    updated_by = ctx.admin_user_id
FROM ctx
WHERE re.id = ctx.result_entry_id
  AND re.result_status <> 'AUTHORIZED';

-- Step 22 (cont.) - Accession Test Authorization: reflect AUTHORIZED status
WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        u.id AS admin_user_id,
        at.id AS accession_test_id
    FROM organizations o
    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'
    JOIN accession_master am
        ON am.organization_id = o.id
       AND am.accession_number = 'ACC0003'
    JOIN accession_tests at
        ON at.accession_id = am.id
    JOIN test_master tm
        ON tm.id = at.test_id
       AND tm.test_code = 'CBC001'
    WHERE o.organization_code = 'LAB002'
)

UPDATE accession_tests at
SET
    authorization_status = 'AUTHORIZED',
    updated_at = CURRENT_TIMESTAMP,
    updated_by = ctx.admin_user_id
FROM ctx
WHERE at.id = ctx.accession_test_id
  AND at.authorization_status <> 'AUTHORIZED';

-- Step 23 - Report Generation: generate the report for the accession
WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        am.branch_id,
        am.id AS accession_id,
        u.id AS admin_user_id
    FROM organizations o
    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'
    JOIN accession_master am
        ON am.organization_id = o.id
       AND am.accession_number = 'ACC0003'
    WHERE o.organization_code = 'LAB002'
)

INSERT INTO report_master
(
    organization_id,
    branch_id,
    accession_id,
    report_number,
    report_status,
    generated_at,
    generated_by,
    created_by
)
SELECT
    organization_id,
    branch_id,
    accession_id,
    'RPT-ACC0003',
    'GENERATED',
    CURRENT_TIMESTAMP,
    admin_user_id,
    admin_user_id
FROM ctx
ON CONFLICT (organization_id, branch_id, accession_id)
DO NOTHING;


-- Step 23 (cont.) - Accession Report Status Update: mark report_status READY
WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        am.branch_id,
        am.id AS accession_id,
        u.id AS admin_user_id
    FROM organizations o
    JOIN users u
        ON u.organization_id = o.id
       AND u.username='admin'
    JOIN accession_master am
        ON am.organization_id=o.id
       AND am.accession_number='ACC0003'
    WHERE o.organization_code='LAB002'
)

UPDATE accession_tests at
SET
    report_status='READY',
    updated_at=CURRENT_TIMESTAMP,
    updated_by=ctx.admin_user_id
FROM ctx
WHERE at.accession_id=ctx.accession_id
  AND at.report_status<>'READY';

COMMIT;

-- 
-- VERIFICATION QUERIES - confirm every step above landed correctly
-- 

-- Verify: Patient (Step 4)
SELECT * FROM patients WHERE id = :'patient_id';

-- Verify: Patient Contact (Step 6)
SELECT * FROM patient_contacts
WHERE patient_id = :'patient_id';

-- Verify: Patient Address (Step 7)
SELECT * FROM patient_addresses
WHERE patient_id = :'patient_id';

-- Verify: Patient Identifier (Step 5)
SELECT * FROM patient_identifiers
WHERE patient_id = :'patient_id';

-- Verify: Patient Registration / Visit (Step 8)
SELECT * FROM patient_registrations
WHERE id = :'registration_id';

-- Verify: Clinical Master seed data (Step 9)
SELECT *
FROM clinical_master
ORDER BY clinical_type, clinical_name;

-- Verify: Patient Clinical History (Step 10)
SELECT
    p.first_name,
    p.last_name,
    cm.clinical_type,
    cm.clinical_name,
    pch.status,
    pch.severity,
    pch.duration_value,
    pch.duration_unit,
    pch.notes
FROM patient_clinical_history pch
JOIN patients p
    ON p.id = pch.patient_id
JOIN clinical_master cm
    ON cm.id = pch.clinical_id
WHERE p.id = :'patient_id'
ORDER BY cm.clinical_type;

-- Verify: Billing Master (Step 11, updated in Step 16)
SELECT
    o.organization_code,
    bm.bill_number,
    pr.registration_number,
    bm.total_amount,
    bm.payable_amount,
    bm.payment_status
FROM billing_master bm
JOIN organizations o
  ON o.id = bm.organization_id
JOIN patient_registrations pr
  ON pr.id = bm.patient_registration_id
WHERE bm.bill_number = 'BILL0002'
  AND o.organization_code = 'LAB002';

-- Verify: Billing Tests (Step 12)
SELECT
    o.organization_code,
    tm.test_code,
    tm.test_name,
    bt.rate,
    bt.net_amount,
    bt.status
FROM billing_tests bt
JOIN billing_master bm
  ON bm.id = bt.billing_id
JOIN organizations o
  ON o.id = bm.organization_id
JOIN test_master tm
  ON tm.id = bt.test_id
WHERE bm.bill_number = 'BILL0002'
  AND o.organization_code = 'LAB002';

-- Verify: Accession Master (Step 13)
SELECT
    o.organization_code,
    am.accession_number,
    am.priority,
    am.status
FROM accession_master am
JOIN organizations o
  ON o.id = am.organization_id
WHERE o.organization_code = 'LAB002'
  AND am.accession_number = 'ACC0003';

-- Verify: Accession Tests (Step 14, updated through Steps 18/21/22/23)
SELECT
    o.organization_code,
    tm.test_code,
    tm.test_name,
    at.barcode,
    at.sample_status,
    at.collection_status,
    at.authorization_status,
    at.report_status
FROM accession_tests at
JOIN accession_master am
  ON am.id = at.accession_id
JOIN organizations o
  ON o.id = am.organization_id
JOIN test_master tm
  ON tm.id = at.test_id
WHERE o.organization_code = 'LAB002'
  AND am.accession_number = 'ACC0003';

-- Verify: Sample Collection (Step 17)
SELECT
    o.organization_code,
    am.accession_number,
    tm.test_code,
    tm.test_name,
    sc.collection_datetime,
    sc.collection_location,
    sc.sample_condition,
    sc.quantity,
    sc.quantity_unit,
    sc.collection_status,
    u.username AS collector
FROM sample_collection sc

JOIN accession_tests at
    ON at.id = sc.accession_test_id

JOIN accession_master am
    ON am.id = at.accession_id

JOIN test_master tm
    ON tm.id = at.test_id

JOIN organizations o
    ON o.id = sc.organization_id

LEFT JOIN users u
    ON u.id = sc.collector_id

WHERE o.organization_code = 'LAB002'
  AND am.accession_number = 'ACC0003';


-- Verify: Accession Test final status snapshot (Steps 18/21/22/23)
SELECT
    o.organization_code,
    am.accession_number,
    at.barcode,
    at.sample_status,
    at.collection_status,
    at.authorization_status,
    at.report_status
FROM accession_tests at

JOIN accession_master am
    ON am.id = at.accession_id

JOIN organizations o
    ON o.id = at.organization_id

WHERE o.organization_code = 'LAB002'
  AND am.accession_number = 'ACC0003';

-- Verify: Result Entry (Steps 19/21) with parameter count
SELECT
    o.organization_code,
    am.accession_number,
    tm.test_code,
    tm.test_name,
    re.result_status,
    COUNT(red.id) AS parameter_count
FROM result_entry re

JOIN accession_tests at
    ON at.id = re.accession_test_id

JOIN accession_master am
    ON am.id = at.accession_id

JOIN organizations o
    ON o.id = re.organization_id

JOIN test_master tm
    ON tm.id = at.test_id

LEFT JOIN result_entry_details red
    ON red.result_entry_id = re.id

WHERE o.organization_code = 'LAB002'
  AND am.accession_number = 'ACC0003'

GROUP BY
    o.organization_code,
    am.accession_number,
    tm.test_code,
    tm.test_name,
    re.result_status;


-- Verify: Parameter Results (Step 20)
SELECT
    pm.parameter_code,
    pm.parameter_name,
    red.result_value,
    red.result_flag
FROM result_entry_details red

JOIN parameter_master pm
    ON pm.id = red.parameter_id

JOIN result_entry re
    ON re.id = red.result_entry_id

JOIN accession_tests at
    ON at.id = re.accession_test_id

JOIN accession_master am
    ON am.id = at.accession_id

JOIN organizations o
    ON o.id = re.organization_id

WHERE o.organization_code = 'LAB002'
  AND am.accession_number = 'ACC0003'

ORDER BY pm.parameter_code;

-- Verify: Report Master (Step 23)
SELECT
    o.organization_code,
    am.accession_number,
    rm.report_number,
    rm.report_status,
    at.report_status,
    rm.generated_at,
    u.username AS generated_by
FROM report_master rm
JOIN organizations o
    ON o.id=rm.organization_id
JOIN accession_master am
    ON am.id=rm.accession_id
JOIN accession_tests at
    ON at.accession_id=am.id
LEFT JOIN users u
    ON u.id=rm.generated_by
WHERE o.organization_code='LAB002'
  AND am.accession_number='ACC0003';

SELECT
    'Patient Journey E2E Validation Completed Successfully' AS status;

SELECT organization_code, id
FROM organizations;


