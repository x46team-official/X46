-- Verify Before Update

SELECT
    template_name,
    notification_type,
    subject,
    message_body,
    is_active
FROM notification_template
LIMIT 1;

-- Update Template

UPDATE notification_template
SET
    subject = 'Updated Appointment Reminder',
    message_body = 'Your appointment has been updated. Please contact the lab if you have any questions.',
    updated_at = CURRENT_TIMESTAMP,
    updated_by = (SELECT id FROM users LIMIT 1)
WHERE id =
(
    SELECT id
    FROM notification_template
    LIMIT 1
);

-- Verify

SELECT
    template_name,
    subject,
    message_body
FROM notification_template
WHERE id =
(
    SELECT id
    FROM notification_template
    LIMIT 1
);

-- Verify Before Update

SELECT
    template_name,
    is_active
FROM notification_template
LIMIT 1;

-- Deactivate Template

UPDATE notification_template
SET
    is_active = FALSE,
    updated_at = CURRENT_TIMESTAMP,
    updated_by = (SELECT id FROM users LIMIT 1)
WHERE id =
(
    SELECT id
    FROM notification_template
    LIMIT 1
);

-- Verify

SELECT
    template_name,
    is_active
FROM notification_template
WHERE id =
(
    SELECT id
    FROM notification_template
    LIMIT 1
);

-- Activate Template

UPDATE notification_template
SET
    is_active = TRUE,
    updated_at = CURRENT_TIMESTAMP,
    updated_by = (SELECT id FROM users LIMIT 1)
WHERE id =
(
    SELECT id
    FROM notification_template
    LIMIT 1
);

-- Verify

SELECT
    template_name,
    is_active
FROM notification_template
WHERE id =
(
    SELECT id
    FROM notification_template
    LIMIT 1
);

-- Expected:
-- Duplicate template should fail because of
-- UNIQUE (organization_id, branch_id, template_name, notification_type)

INSERT INTO notification_template
(
    organization_id,
    branch_id,
    template_name,
    notification_type,
    subject,
    message_body,
    created_by
)
SELECT
    organization_id,
    branch_id,
    template_name,
    notification_type,
    subject,
    message_body,
    (SELECT id FROM users LIMIT 1)
FROM notification_template
LIMIT 1;

-- Verify Before Update

SELECT
    notification_type,
    recipient,
    status,
    sent_at
FROM notification_log
LIMIT 1;

-- Update Status

UPDATE notification_log
SET
    status = 'SENT',
    sent_at = CURRENT_TIMESTAMP,
    updated_at = CURRENT_TIMESTAMP,
    updated_by = (SELECT id FROM users LIMIT 1)
WHERE id =
(
    SELECT id
    FROM notification_log
    LIMIT 1
);

-- Verify

SELECT
    notification_type,
    recipient,
    status,
    sent_at
FROM notification_log
WHERE id =
(
    SELECT id
    FROM notification_log
    LIMIT 1
);

-- Mark Notification as Failed

UPDATE notification_log
SET
    status = 'FAILED',
    error_message = 'SMTP Timeout',
    updated_at = CURRENT_TIMESTAMP,
    updated_by = (SELECT id FROM users LIMIT 1)
WHERE id =
(
    SELECT id
    FROM notification_log
    LIMIT 1
);

-- Retry Notification

UPDATE notification_log
SET
    status = 'PENDING',
    error_message = NULL,
    updated_at = CURRENT_TIMESTAMP,
    updated_by = (SELECT id FROM users LIMIT 1)
WHERE id =
(
    SELECT id
    FROM notification_log
    LIMIT 1
);

-- Verify

SELECT
    notification_type,
    recipient,
    status,
    error_message
FROM notification_log
WHERE id =
(
    SELECT id
    FROM notification_log
    LIMIT 1
);