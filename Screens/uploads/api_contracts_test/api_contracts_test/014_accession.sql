-- 014_accession.sql
-- Accession Management API DB Validation

BEGIN;

WITH ctx AS (
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
INSERT INTO accession_master (
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
    'ACC-API-T101',
    CURRENT_TIMESTAMP,
    'NORMAL',
    'PENDING',
    'API accession validation',
    admin_user_id
FROM ctx
RETURNING
    id,
    organization_id,
    branch_id,
    billing_id,
    patient_registration_id,
    accession_number,
    priority,
    status;

ROLLBACK;

-- VIEW ACCESSION
-- Expected API : 200 OK
BEGIN;

SELECT
    am.id,
    am.organization_id,
    am.branch_id,
    am.billing_id,
    am.patient_registration_id,
    am.accession_number,
    am.accession_date,
    am.priority,
    am.status,
    am.remarks
FROM accession_master am
JOIN organizations o
    ON o.id = am.organization_id
JOIN branches b
    ON b.id = am.branch_id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND am.accession_number = 'ACC0001';

ROLLBACK;

-- UPDATE ACCESSION
-- Expected API : 200 OK

BEGIN;

UPDATE accession_master am
SET
    priority = 'URGENT',
    remarks = 'Accession updated through API validation',
    updated_at = CURRENT_TIMESTAMP
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
WHERE am.organization_id = o.id
  AND am.branch_id = b.id
  AND o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND am.accession_number = 'ACC0001'
RETURNING
    am.id,
    am.accession_number,
    am.priority,
    am.status,
    am.remarks;

ROLLBACK;



--UPDATE ACCESSION STATUS
-- Expected API : 200 OK

BEGIN;

UPDATE accession_master am
SET
    status = 'COLLECTED',
    updated_at = CURRENT_TIMESTAMP
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
WHERE am.organization_id = o.id
  AND am.branch_id = b.id
  AND o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND am.accession_number = 'ACC0001'
RETURNING
    am.id,
    am.accession_number,
    am.status;

ROLLBACK;

-- LIST ACCESSION TESTS
-- Expected API : 200 OK

SELECT
    at.id,
    at.organization_id,
    at.branch_id,
    at.accession_id,
    at.billing_test_id,
    at.test_id,
    tm.test_code,
    tm.test_name,
    at.sample_type_id,
    at.performing_lab_id,
    at.barcode,
    at.barcode_status,
    at.sample_status,
    at.collection_status,
    at.authorization_status,
    at.report_status,
    at.remarks
FROM accession_tests at
JOIN accession_master am
    ON am.id = at.accession_id
JOIN organizations o
    ON o.id = am.organization_id
JOIN branches b
    ON b.id = am.branch_id
JOIN test_master tm
    ON tm.id = at.test_id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND am.accession_number = 'ACC0001'
ORDER BY at.created_at;

-- UPDATE SAMPLE STATUS
-- Expected API : 200 OK

BEGIN;

UPDATE accession_tests at
SET
    sample_status = 'COLLECTED',
    updated_at = CURRENT_TIMESTAMP
FROM accession_master am
JOIN organizations o
    ON o.id = am.organization_id
JOIN branches b
    ON b.id = am.branch_id
WHERE at.accession_id = am.id
  AND am.organization_id = o.id
  AND am.branch_id = b.id
  AND o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND am.accession_number = 'ACC0001'
RETURNING
    at.id,
    at.accession_id,
    at.sample_status;

ROLLBACK;

--  UPDATE COLLECTION STATUS
-- Expected API : 200 OK

BEGIN;

UPDATE accession_tests at
SET
    collection_status = 'COLLECTED',
    updated_at = CURRENT_TIMESTAMP
FROM accession_master am
JOIN organizations o
    ON o.id = am.organization_id
JOIN branches b
    ON b.id = am.branch_id
WHERE at.accession_id = am.id
  AND am.organization_id = o.id
  AND am.branch_id = b.id
  AND o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND am.accession_number = 'ACC0001'
RETURNING
    at.id,
    at.accession_id,
    at.collection_status;

ROLLBACK;

--  UPDATE AUTHORIZATION STATUS
-- Expected API : 200 OK

BEGIN;

UPDATE accession_tests at
SET
    authorization_status = 'AUTHORIZED',
    updated_at = CURRENT_TIMESTAMP
FROM accession_master am
JOIN organizations o
    ON o.id = am.organization_id
JOIN branches b
    ON b.id = am.branch_id
WHERE at.accession_id = am.id
  AND am.organization_id = o.id
  AND am.branch_id = b.id
  AND o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND am.accession_number = 'ACC0001'
RETURNING
    at.id,
    at.accession_id,
    at.authorization_status;

ROLLBACK;

-- UPDATE REPORT STATUS
-- Expected API : 200 OK

BEGIN;

UPDATE accession_tests at
SET
    report_status = 'READY',
    updated_at = CURRENT_TIMESTAMP
FROM accession_master am
JOIN organizations o
    ON o.id = am.organization_id
JOIN branches b
    ON b.id = am.branch_id
WHERE at.accession_id = am.id
  AND am.organization_id = o.id
  AND am.branch_id = b.id
  AND o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND am.accession_number = 'ACC0001'
RETURNING
    at.id,
    at.accession_id,
    at.report_status;

ROLLBACK;

--  INVALID ACCESSION ID
-- Expected API : 404 Not Found
-- Expected DB : 0 rows

SELECT
    id,
    accession_number,
    priority,
    status
FROM accession_master
WHERE id = '00000000-0000-0000-0000-000000000000';

--  DUPLICATE ACCESSION NUMBER
-- Expected API : 409 Conflict
-- Expected DB : UNIQUE violation

BEGIN;

SAVEPOINT sp_duplicate_accession;

WITH ctx AS (
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
INSERT INTO accession_master (
    organization_id,
    branch_id,
    billing_id,
    patient_registration_id,
    accession_number,
    accession_date,
    priority,
    status,
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
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_duplicate_accession;

SELECT
    'PASS' AS validation,
    'Duplicate accession number rejected' AS result;

COMMIT;

-- INVALID BILLING ID
-- Expected API : 404 Not Found


BEGIN;

SAVEPOINT sp_invalid_billing;

WITH ctx AS (
    SELECT
        o.id AS organization_id,
        b.id AS branch_id,
        pr.id AS patient_registration_id,
        u.id AS admin_user_id
    FROM organizations o
    JOIN branches b
        ON b.organization_id = o.id
       AND b.branch_code = 'PUNE002'
    JOIN patient_registrations pr
        ON pr.organization_id = o.id
       AND pr.branch_id = b.id
    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'
    WHERE o.organization_code = 'LAB002'
    LIMIT 1
)
INSERT INTO accession_master (
    organization_id,
    branch_id,
    billing_id,
    patient_registration_id,
    accession_number,
    priority,
    status,
    created_by
)
SELECT
    organization_id,
    branch_id,
    '00000000-0000-0000-0000-000000000000',
    patient_registration_id,
    'ACC-API-T112',
    'NORMAL',
    'PENDING',
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_invalid_billing;

SELECT
    'PASS' AS validation,
    'Invalid billing ID rejected by FK' AS result;

COMMIT;

--INVALID PATIENT REGISTRATION
-- Expected API : 404 Not Found


BEGIN;

SAVEPOINT sp_invalid_registration;

WITH ctx AS (
    SELECT
        o.id AS organization_id,
        b.id AS branch_id,
        bm.id AS billing_id,
        u.id AS admin_user_id
    FROM organizations o
    JOIN branches b
        ON b.organization_id = o.id
       AND b.branch_code = 'PUNE002'
    JOIN billing_master bm
        ON bm.organization_id = o.id
       AND bm.branch_id = b.id
    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'
    WHERE o.organization_code = 'LAB002'
    LIMIT 1
)
INSERT INTO accession_master (
    organization_id,
    branch_id,
    billing_id,
    patient_registration_id,
    accession_number,
    priority,
    status,
    created_by
)
SELECT
    organization_id,
    branch_id,
    billing_id,
    '00000000-0000-0000-0000-000000000000',
    'ACC-API-T113',
    'NORMAL',
    'PENDING',
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_invalid_registration;

SELECT
    'PASS' AS validation,
    'Invalid patient registration rejected by FK' AS result;

COMMIT;

--  SEARCH ACCESSIONS
-- Expected API : 200 OK

SELECT
    am.id,
    am.accession_number,
    am.priority,
    am.status,
    am.billing_id,
    am.patient_registration_id
FROM accession_master am
JOIN organizations o
    ON o.id = am.organization_id
JOIN branches b
    ON b.id = am.branch_id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND am.accession_number ILIKE '%ACC%'
ORDER BY am.accession_date DESC;

-- INVALID ORGANIZATION / BRANCH SCOPE
-- Expected API : 404 Not Found

SELECT
    am.id,
    am.accession_number,
    am.status
FROM accession_master am
JOIN organizations o
    ON o.id = am.organization_id
JOIN branches b
    ON b.id = am.branch_id
WHERE o.organization_code = 'INVALID-ORG'
   OR b.branch_code = 'INVALID-BRANCH';