INSERT INTO notification_template (
    organization_id,
    branch_id,
    template_name,
    notification_type,
    subject,
    message_body,
    created_by
)
SELECT
    o.id,
    b.id,
    'REPORT_READY',
    'EMAIL',
    'Laboratory Report Ready',
    'Dear Patient, your report is ready.',
    u.id
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
JOIN users u
    ON u.organization_id = o.id
   AND u.branch_id = b.id
WHERE o.organization_code = 'DEMO-LAB 2'
  AND b.branch_code = 'PUNE-01'
LIMIT 1;
