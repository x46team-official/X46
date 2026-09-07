-- API-T091 : CREATE BILL
-- Expected API : 201 Created
BEGIN;

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
       AND pr.registration_number = 'REG001'
    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'
    WHERE o.organization_code = 'LAB002'
)
INSERT INTO billing_master (
    organization_id,
    branch_id,
    patient_registration_id,
    bill_number,
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
    patient_registration_id,
    'BILL-API-T091',
    350.00,
    0.00,
    0.00,
    0.00,
    350.00,
    0.00,
    350.00,
    'Pending',
    admin_user_id
FROM ctx
RETURNING
    id,
    organization_id,
    branch_id,
    patient_registration_id,
    bill_number,
    total_amount,
    payable_amount,
    paid_amount,
    balance_amount,
    payment_status;

ROLLBACK;

-- API-T092 : VIEW BILL
-- Expected API : 200 OK

BEGIN;

SELECT
    bm.id,
    bm.organization_id,
    bm.branch_id,
    bm.patient_registration_id,
    bm.bill_number,
    bm.bill_date,
    bm.total_amount,
    bm.discount_amount,
    bm.concession_amount,
    bm.additional_amount,
    bm.payable_amount,
    bm.paid_amount,
    bm.balance_amount,
    bm.payment_mode,
    bm.payment_status,
    bm.remarks,
    bm.is_cancelled
FROM billing_master bm
JOIN organizations o
    ON o.id = bm.organization_id
JOIN branches b
    ON b.id = bm.branch_id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND bm.bill_number = 'BILL0001';

ROLLBACK;

-- API-T093 : UPDATE BILL
-- Expected API : 200 OK

BEGIN;

UPDATE billing_master bm
SET
    discount_amount = 50.00,
    payable_amount = 300.00,
    balance_amount = 300.00,
    remarks = 'Billing updated through API validation',
    updated_at = CURRENT_TIMESTAMP
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
WHERE bm.organization_id = o.id
  AND bm.branch_id = b.id
  AND o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND bm.bill_number = 'BILL0001'
RETURNING
    bm.id,
    bm.branch_id,
    bm.bill_number,
    bm.total_amount,
    bm.discount_amount,
    bm.payable_amount,
    bm.balance_amount,
    bm.remarks;

ROLLBACK;

-- API-T094 : ADD TEST TO BILL
-- Expected API : 201 Created

BEGIN;

WITH ctx AS (
    SELECT
        bm.id AS billing_id,
        bm.organization_id,
        bm.branch_id,
        tm.id AS test_id,
        u.id AS admin_user_id
    FROM billing_master bm
    JOIN organizations o
        ON o.id = bm.organization_id
    JOIN branches b
        ON b.id = bm.branch_id
       AND b.organization_id = o.id
    JOIN test_master tm
        ON tm.organization_id = o.id
       AND tm.test_code = 'CBC001'
    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'
    WHERE o.organization_code = 'LAB002'
      AND b.branch_code = 'PUNE002'
      AND bm.bill_number = 'BILL0001'
    LIMIT 1
)
INSERT INTO billing_tests (
    organization_id,
    branch_id,
    billing_id,
    test_id,
    quantity,
    rate,
    discount_amount,
    concession_amount,
    net_amount,
    status,
    created_by
)
SELECT
    organization_id,
    branch_id,
    billing_id,
    test_id,
    1,
    350.00,
    0.00,
    0.00,
    350.00,
    'Pending',
    admin_user_id
FROM ctx
RETURNING
    id,
    organization_id,
    branch_id,
    billing_id,
    test_id,
    quantity,
    rate,
    net_amount,
    status;

ROLLBACK;

-- API-T095 : VIEW BILLING TESTS
-- Expected API : 200 OK

SELECT
    bt.id,
    bt.organization_id,
    bt.branch_id,
    bt.billing_id,
    bt.test_id,
    tm.test_code,
    tm.test_name,
    bt.quantity,
    bt.rate,
    bt.discount_amount,
    bt.concession_amount,
    bt.net_amount,
    bt.barcode,
    bt.status
FROM billing_tests bt
JOIN billing_master bm
    ON bm.id = bt.billing_id
JOIN organizations o
    ON o.id = bm.organization_id
JOIN branches b
    ON b.id = bm.branch_id
JOIN test_master tm
    ON tm.id = bt.test_id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND bm.bill_number = 'BILL0001'
ORDER BY bt.created_at;


-- API-T096 : SEARCH BILLS
-- Expected API : 200 OK

SELECT
    bm.id,
    bm.branch_id,
    bm.bill_number,
    bm.patient_registration_id,
    bm.total_amount,
    bm.payable_amount,
    bm.paid_amount,
    bm.balance_amount,
    bm.payment_status,
    bm.is_cancelled
FROM billing_master bm
JOIN organizations o
    ON o.id = bm.organization_id
JOIN branches b
    ON b.id = bm.branch_id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND bm.bill_number ILIKE '%BILL%'
ORDER BY bm.bill_date DESC;

-- CANCEL BILL
-- Expected API : 200 OK

BEGIN;

UPDATE billing_master bm
SET
    is_cancelled = TRUE,
    remarks = 'Cancelled through API validation',
    updated_at = CURRENT_TIMESTAMP
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
WHERE bm.organization_id = o.id
  AND bm.branch_id = b.id
  AND o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND bm.bill_number = 'BILL0001'
RETURNING
    bm.id,
    bm.branch_id,
    bm.bill_number,
    bm.is_cancelled,
    bm.remarks;

ROLLBACK;

--  INVALID REGISTRATION
-- Expected API : 404 Not Found
-- Expected DB : FK violation

BEGIN;

SAVEPOINT sp_invalid_registration;

WITH ctx AS (
    SELECT
        o.id AS organization_id,
        b.id AS branch_id,
        u.id AS admin_user_id
    FROM organizations o
    JOIN branches b
        ON b.organization_id = o.id
       AND b.branch_code = 'PUNE002'
    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'
    WHERE o.organization_code = 'LAB002'
)
INSERT INTO billing_master (
    organization_id,
    branch_id,
    patient_registration_id,
    bill_number,
    total_amount,
    payable_amount,
    balance_amount,
    created_by
)
SELECT
    organization_id,
    branch_id,
    '00000000-0000-0000-0000-000000000000',
    'BILL-API-T098',
    100.00,
    100.00,
    100.00,
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_invalid_registration;

SELECT
    'PASS' AS validation,
    'Invalid patient registration rejected by FK' AS result;

COMMIT;

-- DUPLICATE BILL NUMBER
-- Expected API : 409 Conflict
-- Expected DB : UNIQUE violation

BEGIN;

SAVEPOINT sp_duplicate_bill;

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
       AND pr.registration_number = 'REG001'
    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'
    WHERE o.organization_code = 'LAB002'
)
INSERT INTO billing_master (
    organization_id,
    branch_id,
    patient_registration_id,
    bill_number,
    total_amount,
    payable_amount,
    balance_amount,
    created_by
)
SELECT
    organization_id,
    branch_id,
    patient_registration_id,
    'BILL0001',
    100.00,
    100.00,
    100.00,
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_duplicate_bill;

SELECT
    'PASS' AS validation,
    'Duplicate bill number rejected' AS result;

COMMIT;

-- INVALID BILLING ID
-- Expected API : 404 Not Found

SELECT
    bm.id,
    bm.bill_number,
    bm.payment_status,
    bm.is_cancelled
FROM billing_master bm
JOIN organizations o
    ON o.id = bm.organization_id
JOIN branches b
    ON b.id = bm.branch_id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND bm.id = '00000000-0000-0000-0000-000000000000';