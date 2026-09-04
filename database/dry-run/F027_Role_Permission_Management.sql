-- Verify Before Update

SELECT
    role_code,
    role_name
FROM roles
LIMIT 1;

-- Update Role

UPDATE roles
SET
    role_name = 'Updated Administrator'
WHERE id =
(
    SELECT id
    FROM roles
    LIMIT 1
);

-- Verify

SELECT
    role_code,
    role_name
FROM roles
WHERE id =
(
    SELECT id
    FROM roles
    LIMIT 1
);

-- Verify Before Delete

SELECT
    role_code,
    role_name
FROM roles
LIMIT 1;

-- Delete Role

DELETE FROM roles
WHERE id =
(
    SELECT id
    FROM roles
    LIMIT 1
);

-- Expected:
-- Duplicate Role Code should fail due to uq_roles_org_branch_code

INSERT INTO roles
(
    organization_id,
    branch_id,
    role_code,
    role_name
)
SELECT
    organization_id,
    branch_id,
    role_code,
    'Duplicate Role'
FROM roles
LIMIT 1;

-- Verify Before Update

SELECT
    user_id,
    role_id,
    assigned_at
FROM user_roles
LIMIT 1;

-- Update User Role
-- Requires at least two roles.

UPDATE user_roles
SET
    role_id =
    (
        SELECT id
        FROM roles
        WHERE id <>
        (
            SELECT role_id
            FROM user_roles
            LIMIT 1
        )
        LIMIT 1
    ),
    assigned_at = CURRENT_TIMESTAMP
WHERE user_id =
(
    SELECT user_id
    FROM user_roles
    LIMIT 1
)
AND role_id =
(
    SELECT role_id
    FROM user_roles
    LIMIT 1
);

-- Verify

SELECT
    user_id,
    role_id,
    assigned_at
FROM user_roles
WHERE user_id =
(
    SELECT user_id
    FROM user_roles
    LIMIT 1
);

-- Verify Before Delete

SELECT
    user_id,
    role_id
FROM user_roles
LIMIT 1;

-- Delete User Role

DELETE FROM user_roles
WHERE user_id =
(
    SELECT user_id
    FROM user_roles
    LIMIT 1
)
AND role_id =
(
    SELECT role_id
    FROM user_roles
    LIMIT 1
);

-- Verify

SELECT *
FROM user_roles
WHERE user_id =
(
    SELECT user_id
    FROM user_roles
    LIMIT 1
)
AND role_id =
(
    SELECT role_id
    FROM user_roles
    LIMIT 1
);

-- Insert Permission

INSERT INTO role_permission
(
    organization_id,
    branch_id,
    role_id,
    module_name,
    can_create,
    can_view,
    can_update,
    can_delete,
    can_authorize,
    can_print,
    can_export,
    created_by
)
SELECT
    organization_id,
    branch_id,
    id,
    'Billing',
    TRUE,
    TRUE,
    TRUE,
    FALSE,
    TRUE,
    TRUE,
    FALSE,
    (SELECT id FROM users LIMIT 1)
FROM roles
LIMIT 1;

-- Verify

SELECT
    module_name,
    can_create,
    can_view,
    can_update,
    can_delete,
    can_authorize,
    can_print,
    can_export
FROM role_permission
ORDER BY created_at DESC
LIMIT 1;


--view role permission
SELECT
    module_name,
    can_create,
    can_view,
    can_update,
    can_delete,
    can_authorize,
    can_print,
    can_export
FROM role_permission
WHERE role_id =
(
    SELECT id
    FROM roles
    LIMIT 1
);

-- Verify Before Delete

SELECT
    module_name
FROM role_permission
LIMIT 1;

-- Delete Permission

DELETE FROM role_permission
WHERE id =
(
    SELECT id
    FROM role_permission
    LIMIT 1
);

-- Verify

SELECT *
FROM role_permission
WHERE id =
(
    SELECT id
    FROM role_permission
    LIMIT 1
);

-- Insert Menu Permission

INSERT INTO menu_permission
(
    organization_id,
    branch_id,
    role_id,
    menu_name,
    is_visible,
    display_order,
    created_by
)
SELECT
    organization_id,
    branch_id,
    id,
    'Billing',
    TRUE,
    1,
    (SELECT id FROM users LIMIT 1)
FROM roles
LIMIT 1;

-- Verify

SELECT
    menu_name,
    is_visible,
    display_order
FROM menu_permission
ORDER BY created_at DESC
LIMIT 1;