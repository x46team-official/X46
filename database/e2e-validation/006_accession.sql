BEGIN;


-- CREATE ACCESSION


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
      AND bm.bill_number = 'BILL0001'
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
    'ACC0001',
    CURRENT_TIMESTAMP,
    'NORMAL',
    'PENDING',
    'E2E Validation',
    admin_user_id
FROM acc_ctx
ON CONFLICT (organization_id, branch_id, accession_number)
DO NOTHING;


-- CREATE ACCESSION TESTS


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
      AND am.accession_number = 'ACC0001'
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

COMMIT;


-- VERIFY ACCESSION


SELECT
    o.organization_code,
    am.accession_number,
    am.priority,
    am.status
FROM accession_master am
JOIN organizations o
  ON o.id = am.organization_id
WHERE o.organization_code = 'LAB002'
  AND am.accession_number = 'ACC0001';

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
  AND am.accession_number = 'ACC0001';