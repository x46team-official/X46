-- =====================================================
-- SY003 : Update Application Configuration
-- =====================================================

-- Verify Before Update

SELECT
    config_key,
    config_value,
    description,
    is_active
FROM application_settings
ORDER BY created_at DESC
LIMIT 1;

-- Update Configuration

UPDATE application_settings
SET
    config_value = 'TRUE',
    description = 'Updated during Dry Run',
    updated_at = CURRENT_TIMESTAMP,
    updated_by = (SELECT id FROM users LIMIT 1)
WHERE id =
(
    SELECT id
    FROM application_settings
    ORDER BY created_at DESC
    LIMIT 1
);

-- Verify

SELECT
    config_key,
    config_value,
    description
FROM application_settings
WHERE id =
(
    SELECT id
    FROM application_settings
    ORDER BY created_at DESC
    LIMIT 1
);


-- SY004 : Soft Delete Configuration


-- Verify Before Delete

SELECT
    config_key,
    is_active
FROM application_settings
ORDER BY created_at DESC
LIMIT 1;

-- Soft Delete

UPDATE application_settings
SET
    is_active = FALSE,
    deleted_at = CURRENT_TIMESTAMP,
    deleted_by = (SELECT id FROM users LIMIT 1),
    updated_at = CURRENT_TIMESTAMP,
    updated_by = (SELECT id FROM users LIMIT 1)
WHERE id =
(
    SELECT id
    FROM application_settings
    ORDER BY created_at DESC
    LIMIT 1
);

-- Verify

SELECT
    config_key,
    is_active,
    deleted_at
FROM application_settings
WHERE id =
(
    SELECT id
    FROM application_settings
    ORDER BY created_at DESC
    LIMIT 1
);


-- SY005 : Prevent Duplicate Configuration Key


-- Expected:
-- Duplicate configuration should fail due to
-- uq_application_settings

INSERT INTO application_settings
(
    organization_id,
    branch_id,
    config_key,
    config_value,
    description,
    created_by
)
SELECT
    organization_id,
    branch_id,
    config_key,
    config_value,
    description,
    (SELECT id FROM users LIMIT 1)
FROM application_settings
ORDER BY created_at DESC
LIMIT 1;


-- SY006 : Create Dashboard Cache


INSERT INTO dashboard_cache
(
    organization_id,
    branch_id,
    dashboard_key,
    dashboard_value,
    created_by
)
SELECT
    b.organization_id,
    b.id,
    'HOME_DASHBOARD',
    '{"patients":120,"pending_reports":8,"completed_reports":112}'::jsonb,
    (SELECT id FROM users LIMIT 1)
FROM branches b
LIMIT 1;

-- Verify

SELECT
    dashboard_key,
    dashboard_value,
    generated_at
FROM dashboard_cache
ORDER BY generated_at DESC
LIMIT 1;


-- SY007 : View Dashboard Cache


SELECT
    dashboard_key,
    dashboard_value,
    generated_at
FROM dashboard_cache
ORDER BY generated_at DESC
LIMIT 1;


-- SY008 : Refresh Dashboard Cache


-- Verify Before Update

SELECT
    dashboard_key,
    dashboard_value,
    generated_at
FROM dashboard_cache
ORDER BY generated_at DESC
LIMIT 1;

-- Refresh Cache

UPDATE dashboard_cache
SET
    dashboard_value =
    '{"patients":135,"pending_reports":5,"completed_reports":130}'::jsonb,
    generated_at = CURRENT_TIMESTAMP,
    updated_at = CURRENT_TIMESTAMP,
    updated_by = (SELECT id FROM users LIMIT 1)
WHERE id =
(
    SELECT id
    FROM dashboard_cache
    ORDER BY generated_at DESC
    LIMIT 1
);

-- Verify

SELECT
    dashboard_key,
    dashboard_value,
    generated_at
FROM dashboard_cache
WHERE id =
(
    SELECT id
    FROM dashboard_cache
    ORDER BY generated_at DESC
    LIMIT 1
);


-- SY009 : Clear Dashboard Cache (Soft Delete)


-- Verify Before Clear

SELECT
    dashboard_key,
    is_active
FROM dashboard_cache
ORDER BY generated_at DESC
LIMIT 1;

-- Soft Delete Cache

UPDATE dashboard_cache
SET
    is_active = FALSE,
    deleted_at = CURRENT_TIMESTAMP,
    deleted_by = (SELECT id FROM users LIMIT 1),
    updated_at = CURRENT_TIMESTAMP,
    updated_by = (SELECT id FROM users LIMIT 1)
WHERE id =
(
    SELECT id
    FROM dashboard_cache
    ORDER BY generated_at DESC
    LIMIT 1
);

-- Verify

SELECT
    dashboard_key,
    is_active,
    deleted_at
FROM dashboard_cache
WHERE id =
(
    SELECT id
    FROM dashboard_cache
    ORDER BY generated_at DESC
    LIMIT 1
);