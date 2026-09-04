INSERT INTO notification_log (
    organization_id,
    branch_id,
    template_id,
    patient_registration_id,
    notification_type,
    recipient,
    subject,
    message_body,
    status,
    sent_at,
    created_by
)
SELECT
    nt.organization_id,
    nt.branch_id,
    nt.id,
    pr.id,
    'EMAIL',
    'patient@example.com',
    'Laboratory Report Ready',
    'Dear Patient, your laboratory report is ready for download.',
    'SENT',
    CURRENT_TIMESTAMP,
    u.id
FROM notification_template nt
JOIN patient_registrations pr
    ON pr.organization_id = nt.organization_id
   AND pr.branch_id = nt.branch_id
JOIN users u
    ON u.organization_id = nt.organization_id
   AND u.branch_id = nt.branch_id
LIMIT 1;
