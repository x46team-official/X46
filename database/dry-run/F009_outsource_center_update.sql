-- Verify Before Update

SELECT
    center_code,
    center_name,
    phone_number,
    email,
    is_active
FROM outsource_center_master
ORDER BY created_at DESC
LIMIT 1;

-- Update

UPDATE outsource_center_master
SET
    contact_person = 'Updated Contact',
    phone_number = '9876543210',
    email = 'updated.lab@example.com',
    update_at = CURRENT_TIMESTAMP,
    updated_by = (SELECT id FROM users LIMIT 1)
WHERE id =
(
    SELECT id
    FROM outsource_center_master
    ORDER BY created_at DESC
    LIMIT 1
);

-- Verify

SELECT
    center_code,
    contact_person,
    phone_number,
    email
FROM outsource_center_master
WHERE id =
(
    SELECT id
    FROM outsource_center_master
    ORDER BY created_at DESC
    LIMIT 1
);

--deactivate center
-- Verify Before Update

SELECT
    center_code,
    is_active
FROM outsource_center_master
ORDER BY created_at DESC
LIMIT 1;

-- Deactivate

UPDATE outsource_center_master
SET
    is_active = FALSE,
    update_at = CURRENT_TIMESTAMP,
    updated_by = (SELECT id FROM users LIMIT 1)
WHERE id =
(
    SELECT id
    FROM outsource_center_master
    ORDER BY created_at DESC
    LIMIT 1
);

-- Verify

SELECT
    center_code,
    is_active
FROM outsource_center_master
WHERE id =
(
    SELECT id
    FROM outsource_center_master
    ORDER BY created_at DESC
    LIMIT 1
);

-- Expected:
-- Duplicate Center Code should fail

INSERT INTO outsource_center_master
(
    organization_id,
    branch_id,
    center_code,
    center_name,
    created_by
)
SELECT
    organization_id,
    branch_id,
    center_code,
    'Duplicate Center',
    (SELECT id FROM users LIMIT 1)
FROM outsource_center_master
ORDER BY created_at DESC
LIMIT 1;

