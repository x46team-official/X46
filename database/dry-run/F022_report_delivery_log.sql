INSERT INTO report_delivery_log (
    organization_id,
    branch_id,
    report_id,
    delivery_type,
    recipient_type,
    recipient_name,
    recipient_contact,
    delivery_status,
    delivered_at,
    delivered_by,
    remarks,
    created_by
)
SELECT
    rm.organization_id,
    rm.branch_id,
    rm.id,
    'EMAIL',
    'PATIENT',
    'MANAS',
    'manas@gmail.com',
    'DELIVERED',
    CURRENT_TIMESTAMP,
    u.id,
    'Dry run',
    u.id
FROM report_master rm
JOIN users u
    ON u.organization_id = rm.organization_id
   AND u.branch_id = rm.branch_id
LIMIT 1
ON CONFLICT DO NOTHING;

SELECT * FROM report_delivery_log;
