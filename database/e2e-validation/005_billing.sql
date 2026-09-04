BEGIN;


-- CREATE BILL FOR LAB002


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
      AND pr.registration_number = 'REG001'
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
    'BILL0001',
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


-- INSERT BILL TEST


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
      AND bm.bill_number = 'BILL0001'
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

COMMIT;


-- VERIFY


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
WHERE bm.bill_number = 'BILL0001'
  AND o.organization_code = 'LAB002';

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
WHERE bm.bill_number = 'BILL0001'
  AND o.organization_code = 'LAB002';