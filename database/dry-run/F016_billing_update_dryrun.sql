



BEGIN;

-- 1. INSERT DEDICATED TEST BILL (idempotent via unique bill_number)

WITH ctx AS (
    SELECT
        o.id AS organization_id,
        b.id AS branch_id,
        pr.id AS patient_registration_id,
        bc.id AS billing_category_id,
        u.id AS created_by
    FROM organizations o
    JOIN branches b
        ON b.organization_id = o.id
       AND b.branch_code = 'PUNE-01'
    JOIN patient_registrations pr
        ON pr.organization_id = o.id
       AND pr.branch_id = b.id
    JOIN billing_category_master bc
        ON bc.organization_id = o.id
       AND bc.branch_id = b.id
    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'receptionist01'
    WHERE o.organization_code = 'DEMO-LAB 2'
    ORDER BY pr.created_at DESC
    LIMIT 1
)
INSERT INTO billing_master (
    organization_id,
    branch_id,
    patient_registration_id,
    bill_number,
    billing_category_id,
    total_amount,
    payable_amount,
    paid_amount,
    balance_amount,
    payment_mode,
    payment_status,
    remarks,
    created_by,
    updated_by
)
SELECT
    ctx.organization_id,
    ctx.branch_id,
    ctx.patient_registration_id,
    'BILL-UPD-TEST-001',
    ctx.billing_category_id,
    500,
    500,
    0,
    500,
    'Cash',
    'Pending',
    'Dummy bill for BL003/BL004 dry run',
    ctx.created_by,
    ctx.created_by
FROM ctx
WHERE NOT EXISTS (
    SELECT 1
    FROM billing_master bm
    WHERE bm.organization_id = ctx.organization_id
      AND bm.branch_id = ctx.branch_id
      AND bm.bill_number = 'BILL-UPD-TEST-001'
);


-- 2. INSERT DEDICATED BILLING TEST LINE ITEM (idempotent via bill + test pair)

-- 2. INSERT DEDICATED BILLING TEST LINE ITEM

WITH ctx AS
(
    SELECT
        bm.organization_id,
        bm.branch_id,
        bm.id AS billing_id,
        tm.id AS test_id,
        tm.sample_type_id,
        tm.performing_lab_id,
        u.id AS created_by
    FROM billing_master bm

    JOIN organizations o
      ON o.id = bm.organization_id

    JOIN users u
      ON u.organization_id = bm.organization_id
     AND u.username = 'receptionist01'

    JOIN test_master tm
      ON tm.organization_id = bm.organization_id
     AND tm.branch_id = bm.branch_id

    WHERE o.organization_code = 'DEMO-LAB 2 2'
      AND bm.bill_number = 'BILL-UPD-TEST-001'

    ORDER BY tm.created_at
    LIMIT 1
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
    net_amount,
    barcode,
    status,
    remarks,
    created_by,
    updated_by
)
SELECT
    organization_id,
    branch_id,
    billing_id,
    test_id,
    sample_type_id,
    performing_lab_id,
    1,
    500,
    500,
    'BC-UPD-TEST-001',
    'Pending',
    'Dummy billing test',
    created_by,
    created_by
FROM ctx
WHERE NOT EXISTS
(
    SELECT 1
    FROM billing_tests
    WHERE barcode = 'BC-UPD-TEST-001'
);

-- 3. BL003: UPDATE BILL

WITH ctx AS (
    SELECT
        o.id AS organization_id,
        b.id AS branch_id
    FROM organizations o
    JOIN branches b
        ON b.organization_id = o.id
       AND b.branch_code = 'PUNE-01'
    WHERE o.organization_code = 'DEMO-LAB 2'
)
UPDATE billing_master bm
SET
    total_amount = 600,
    payable_amount = 600,
    balance_amount = 600,
    remarks = 'Updated during BL003 dry run',
    updated_at = CURRENT_TIMESTAMP
FROM ctx
WHERE bm.organization_id = ctx.organization_id
  AND bm.branch_id = ctx.branch_id
  AND bm.bill_number = 'BILL-UPD-TEST-001';


-- 4. VERIFY BL003

SELECT
    bm.bill_number,
    bm.total_amount,
    bm.payable_amount,
    bm.balance_amount,
    bm.remarks,
    bm.updated_at
FROM billing_master bm
WHERE bm.bill_number = 'BILL-UPD-TEST-001';


-- 5. BL008: UPDATE BILLING TEST

WITH ctx AS (
    SELECT
        o.id AS organization_id,
        b.id AS branch_id
    FROM organizations o
    JOIN branches b
        ON b.organization_id = o.id
       AND b.branch_code = 'PUNE-01'
    WHERE o.organization_code = 'DEMO-LAB 2'
)
UPDATE billing_tests bt
SET
    rate = 600,
    net_amount = 600,
    remarks = 'Updated during BL008 dry run',
    updated_at = CURRENT_TIMESTAMP
FROM ctx
JOIN billing_master bm
    ON bm.organization_id = ctx.organization_id
   AND bm.branch_id = ctx.branch_id
   AND bm.bill_number = 'BILL-UPD-TEST-001'
WHERE bt.billing_id = bm.id
  AND bt.barcode = 'BC-UPD-TEST-001';


-- 6. VERIFY BL008

SELECT
    bm.bill_number,
    bt.barcode,
    bt.rate,
    bt.net_amount,
    bt.remarks,
    bt.updated_at
FROM billing_tests bt
JOIN billing_master bm
    ON bm.id = bt.billing_id
WHERE bt.barcode = 'BC-UPD-TEST-001';


-- 7. BL004: CANCEL BILL

WITH ctx AS (
    SELECT
        o.id AS organization_id,
        b.id AS branch_id
    FROM organizations o
    JOIN branches b
        ON b.organization_id = o.id
       AND b.branch_code = 'PUNE-01'
    WHERE o.organization_code = 'DEMO-LAB 2'
)
UPDATE billing_master bm
SET
    is_cancelled = TRUE,
    payment_status = 'Cancelled',
    remarks = 'Cancelled during BL004 dry run',
    updated_at = CURRENT_TIMESTAMP
FROM ctx
WHERE bm.organization_id = ctx.organization_id
  AND bm.branch_id = ctx.branch_id
  AND bm.bill_number = 'BILL-UPD-TEST-001';


-- 8. VERIFY BL004

SELECT
    bm.bill_number,
    bm.is_cancelled,
    bm.payment_status,
    bm.remarks
FROM billing_master bm
WHERE bm.bill_number = 'BILL-UPD-TEST-001';


-- 9. BL009: REMOVE BILLING TEST

DELETE FROM billing_tests bt
USING billing_master bm
WHERE bt.billing_id = bm.id
  AND bm.bill_number = 'BILL-UPD-TEST-001'
  AND bt.barcode = 'BC-UPD-TEST-001';


COMMIT;


-- Verification

-- BL003: expect total_amount/payable_amount/balance_amount = 600
SELECT
    bill_number,
    total_amount,
    payable_amount,
    balance_amount
FROM billing_master
WHERE bill_number = 'BILL-UPD-TEST-001';

-- BL004: expect is_cancelled = TRUE, payment_status = 'Cancelled'
SELECT
    bill_number,
    is_cancelled,
    payment_status
FROM billing_master
WHERE bill_number = 'BILL-UPD-TEST-001';

-- BL008/BL009: expect zero rows (test line item was updated, then removed)
SELECT
    bt.barcode,
    bt.rate,
    bt.net_amount
FROM billing_tests bt
JOIN billing_master bm
    ON bm.id = bt.billing_id
WHERE bm.bill_number = 'BILL-UPD-TEST-001';
