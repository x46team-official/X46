BEGIN;


-- Payment Creation

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
      AND bm.bill_number = 'BILL0001'
      AND am.accession_number = 'ACC0001'
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


-- Billing Update

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
      AND bm.bill_number = 'BILL0001'
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

COMMIT;


-- Verification : Billing

SELECT
    o.organization_code,
    bm.bill_number,
    bm.payable_amount,
    bm.paid_amount,
    bm.balance_amount,
    bm.payment_mode,
    bm.payment_status
FROM billing_master bm
JOIN organizations o
    ON o.id = bm.organization_id
WHERE o.organization_code = 'LAB002'
  AND bm.bill_number = 'BILL0001';


-- Verification : Payment

SELECT
    o.organization_code,
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
    ON o.id = bm.organization_id
WHERE o.organization_code = 'LAB002'
  AND bm.bill_number = 'BILL0001'
ORDER BY p.payment_date DESC;


-- Status

SELECT
    'Payment E2E Validation Completed Successfully' AS status;