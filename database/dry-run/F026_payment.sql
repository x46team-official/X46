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
    am.organization_id,
    am.branch_id,
    am.id,
    bm.id,
    am.patient_registration_id,
    'UPI',
    1500.00,
    'TXN123456789',
    'SUCCESS',
    'Dry Run Payment',
    u.id
FROM accession_master am
JOIN billing_master bm
    ON am.billing_id = bm.id
   AND am.branch_id = bm.branch_id
JOIN users u
    ON u.organization_id = am.organization_id
   AND u.branch_id = am.branch_id
LIMIT 1;
