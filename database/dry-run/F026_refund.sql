INSERT INTO refund (
    organization_id,
    branch_id,
    payment_id,
    refund_amount,
    refund_reason,
    refund_status,
    remarks,
    created_by
)
SELECT
    p.organization_id,
    p.branch_id,
    p.id,
    200.00,
    'Patient cancelled one test',
    'APPROVED',
    'Dry Run Refund',
    u.id
FROM payment p
JOIN users u
    ON u.organization_id = p.organization_id
   AND u.branch_id = p.branch_id
WHERE p.deleted_at IS NULL
LIMIT 1;
