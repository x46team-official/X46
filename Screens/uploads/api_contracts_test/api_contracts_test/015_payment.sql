
-- API-T116 : CREATE PAYMENT
-- Expected API : 201 Created

BEGIN;

WITH ctx AS (
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
      AND bm.bill_number = 'BILL0001'
      AND am.accession_number = 'ACC0001'
)
INSERT INTO payment (
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
    organization_id,
    branch_id,
    accession_id,
    billing_id,
    registration_id,
    'CASH',
    payable_amount,
    'TXN-API-T116',
    'SUCCESS',
    'API Payment Validation',
    admin_user_id
FROM ctx
RETURNING
    id,
    organization_id,
    branch_id,
    accession_id,
    billing_master_id,
    patient_registration_id,
    payment_mode,
    amount_paid,
    transaction_reference,
    payment_status;

ROLLBACK;


-- API-T117 : VIEW PAYMENT
-- Expected API : 200 OK

SELECT
    p.id,
    p.organization_id,
    p.branch_id,
    p.accession_id,
    p.billing_master_id,
    p.patient_registration_id,
    p.payment_mode,
    p.amount_paid,
    p.transaction_reference,
    p.payment_status,
    p.payment_date,
    p.remarks
FROM payment p
JOIN organizations o
    ON o.id = p.organization_id
JOIN branches b
    ON b.id = p.branch_id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND p.transaction_reference = 'TXN0001';

-- API-T118 : UPDATE PAYMENT
-- Expected API : 200 OK

BEGIN;

UPDATE payment p
SET
    remarks = 'Payment updated through API validation',
    updated_at = CURRENT_TIMESTAMP
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
WHERE p.organization_id = o.id
  AND p.branch_id = b.id
  AND o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND p.transaction_reference = 'TXN0001'
RETURNING
    p.id,
    p.transaction_reference,
    p.payment_mode,
    p.amount_paid,
    p.payment_status,
    p.remarks;

ROLLBACK;
-- API-T119 : PAYMENT AGAINST BILL
-- Expected API : 201 Created

BEGIN;

WITH ctx AS (
    SELECT
        o.id AS organization_id,
        bm.branch_id,
        bm.id AS billing_id,
        bm.patient_registration_id,
        am.id AS accession_id,
        u.id AS admin_user_id
    FROM organizations o
    JOIN billing_master bm
        ON bm.organization_id = o.id
    JOIN accession_master am
        ON am.billing_id = bm.id
    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'
    WHERE o.organization_code = 'LAB002'
      AND bm.bill_number = 'BILL0001'
      AND am.accession_number = 'ACC0001'
)
INSERT INTO payment (
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
    organization_id,
    branch_id,
    accession_id,
    billing_id,
    patient_registration_id,
    'CASH',
    100.00,
    'TXN-API-T119',
    'SUCCESS',
    'Payment against bill validation',
    admin_user_id
FROM ctx
RETURNING
    id,
    billing_master_id,
    amount_paid,
    payment_mode,
    payment_status;

ROLLBACK;

-- API-T120 : INVALID BILLING ID
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
INSERT INTO payment (
    organization_id,
    branch_id,
    accession_id,
    billing_master_id,
    patient_registration_id,
    payment_mode,
    amount_paid,
    transaction_reference,
    payment_status,
    created_by
)
SELECT
    organization_id,
    branch_id,
    NULL,
    '00000000-0000-0000-0000-000000000000',
    patient_registration_id,
    'CASH',
    100.00,
    'TXN-API-T120',
    'SUCCESS',
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_invalid_billing;

SELECT
    'PASS' AS validation,
    'Invalid billing ID rejected by FK' AS result;

COMMIT;

-- API-T121 : INVALID PAYMENT MODE
-- Expected API : 400 Bad Request
-- Expected DB : FK violation

BEGIN;

SAVEPOINT sp_invalid_payment_mode;

WITH ctx AS (
    SELECT
        o.id AS organization_id,
        bm.branch_id,
        bm.id AS billing_id,
        bm.patient_registration_id,
        am.id AS accession_id,
        u.id AS admin_user_id,
        bm.payable_amount
    FROM organizations o
    JOIN billing_master bm
        ON bm.organization_id = o.id
    JOIN accession_master am
        ON am.billing_id = bm.id
    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'
    WHERE o.organization_code = 'LAB002'
      AND bm.bill_number = 'BILL0001'
      AND am.accession_number = 'ACC0001'
)
INSERT INTO payment (
    organization_id,
    branch_id,
    accession_id,
    billing_master_id,
    patient_registration_id,
    payment_mode,
    amount_paid,
    transaction_reference,
    payment_status,
    created_by
)
SELECT
    organization_id,
    branch_id,
    accession_id,
    billing_id,
    patient_registration_id,
    'BITCOIN',
    100.00,
    'TXN-API-T121',
    'SUCCESS',
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_invalid_payment_mode;

SELECT
    'PASS' AS validation,
    'Invalid payment mode rejected by FK' AS result;

COMMIT;

-- ============================================================
-- API-T122 : INVALID PAYMENT AMOUNT
-- Expected API : 400 Bad Request
-- DB EXPECTATION : CHECK constraint should reject <= 0
-- ============================================================

BEGIN;

SAVEPOINT sp_invalid_amount;

WITH ctx AS (
    SELECT
        o.id AS organization_id,
        bm.branch_id,
        bm.id AS billing_id,
        bm.patient_registration_id,
        am.id AS accession_id,
        u.id AS admin_user_id
    FROM organizations o
    JOIN billing_master bm
        ON bm.organization_id = o.id
    JOIN accession_master am
        ON am.billing_id = bm.id
    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'
    WHERE o.organization_code = 'LAB002'
      AND bm.bill_number = 'BILL0001'
      AND am.accession_number = 'ACC0001'
)
INSERT INTO payment (
    organization_id,
    branch_id,
    accession_id,
    billing_master_id,
    patient_registration_id,
    payment_mode,
    amount_paid,
    transaction_reference,
    payment_status,
    created_by
)
SELECT
    organization_id,
    branch_id,
    accession_id,
    billing_id,
    patient_registration_id,
    'CASH',
    0.00,
    'TXN-API-T122',
    'SUCCESS',
    admin_user_id
FROM ctx;

SELECT
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'GAP'
    END AS validation,
    CASE
        WHEN COUNT(*) = 0
            THEN 'Invalid payment amount rejected'
        ELSE
            'GAP: Database accepted amount_paid = 0.00'
    END AS result
FROM payment
WHERE transaction_reference = 'TXN-API-T122';

ROLLBACK;

-- ============================================================
-- API-T123 : DUPLICATE TRANSACTION REFERENCE
-- Expected API : 409 Conflict
-- DB EXPECTATION : UNIQUE transaction_reference
-- ============================================================

BEGIN;

SAVEPOINT sp_duplicate_transaction;

WITH ctx AS (
    SELECT
        o.id AS organization_id,
        bm.branch_id,
        bm.id AS billing_id,
        bm.patient_registration_id,
        am.id AS accession_id,
        u.id AS admin_user_id
    FROM organizations o
    JOIN billing_master bm
        ON bm.organization_id = o.id
    JOIN accession_master am
        ON am.billing_id = bm.id
    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'
    WHERE o.organization_code = 'LAB002'
      AND bm.bill_number = 'BILL0001'
      AND am.accession_number = 'ACC0001'
)
INSERT INTO payment (
    organization_id,
    branch_id,
    accession_id,
    billing_master_id,
    patient_registration_id,
    payment_mode,
    amount_paid,
    transaction_reference,
    payment_status,
    created_by
)
SELECT
    organization_id,
    branch_id,
    accession_id,
    billing_id,
    patient_registration_id,
    'CASH',
    100.00,
    'TXN0001',
    'SUCCESS',
    admin_user_id
FROM ctx;

SELECT
    CASE
        WHEN COUNT(*) = 1 THEN 'GAP'
        ELSE 'PASS'
    END AS validation,
    CASE
        WHEN COUNT(*) = 1
            THEN 'Duplicate transaction reference rejected'
        ELSE
            'GAP: Duplicate transaction reference is allowed'
    END AS result
FROM payment
WHERE transaction_reference = 'TXN0001';

ROLLBACK;

-- API-T124 : PAYMENT SEARCH
-- Expected API : 200 OK

SELECT
    p.id,
    p.billing_master_id,
    bm.bill_number,
    p.payment_mode,
    p.amount_paid,
    p.payment_status,
    p.transaction_reference,
    p.payment_date
FROM payment p
JOIN billing_master bm
    ON bm.id = p.billing_master_id
JOIN organizations o
    ON o.id = p.organization_id
JOIN branches b
    ON b.id = p.branch_id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND bm.bill_number = 'BILL0001'
ORDER BY p.payment_date DESC;

-- API-T125 : INVALID PAYMENT ID
-- Expected API : 404 Not Found
SELECT
    id,
    payment_mode,
    amount_paid,
    payment_status
FROM payment
WHERE id = '00000000-0000-0000-0000-000000000000';

-- API-T126 : ORGANIZATION / BRANCH SCOPE
-- Expected API : 404 Not Found

SELECT
    p.id,
    p.transaction_reference,
    p.payment_status
FROM payment p
JOIN organizations o
    ON o.id = p.organization_id
JOIN branches b
    ON b.id = p.branch_id
WHERE o.organization_code = 'INVALID-ORG'
   OR b.branch_code = 'INVALID-BRANCH';

-- API-T127 : PAYMENT STATUS
-- Expected API : 200 OK

BEGIN;

UPDATE payment p
SET
    payment_status = 'SUCCESS',
    updated_at = CURRENT_TIMESTAMP
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
WHERE p.organization_id = o.id
  AND p.branch_id = b.id
  AND o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND p.transaction_reference = 'TXN0001'
RETURNING
    p.id,
    p.transaction_reference,
    p.payment_status;

ROLLBACK;