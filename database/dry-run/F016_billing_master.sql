INSERT INTO billing_master
(
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
    remarks
)

SELECT
    o.id,
    b.id,
    pr.id,
    'BILL0001',
    bc.id,
    350,
    350,
    350,
    0,
    'Cash',
    'Paid',
    'First Billing'

FROM organizations o
JOIN branches b
ON b.organization_id = o.id

JOIN patient_registrations pr
ON pr.organization_id = o.id
AND pr.branch_id = b.id

JOIN billing_category_master bc
ON bc.organization_id = o.id
AND bc.branch_id = b.id

WHERE o.organization_code = 'DEMO-LAB  2'
  AND b.branch_code = 'PUNE-01'
LIMIT 1;

SELECT * FROM billing_master;
