BEGIN;


-- Get Organization


SELECT id AS organization_id
FROM organizations
WHERE organization_code = 'LAB002'
\gset


-- Get Branch


SELECT id AS branch_id
FROM branches
WHERE organization_id = :'organization_id'
  AND branch_code = 'PUNE002'
\gset


-- Get Admin User


SELECT id AS admin_user_id
FROM users
WHERE organization_id = :'organization_id'
  AND username = 'admin'
\gset


-- Get ADMIN Role


SELECT id AS admin_role_id
FROM roles
WHERE organization_id = :'organization_id'
  AND branch_id = :'branch_id'
  AND role_code = 'ADMIN'
\gset


-- Assign ADMIN Role


INSERT INTO user_roles (
    organization_id,
    branch_id,
    user_id,
    role_id
)
SELECT
    :'organization_id',
    :'branch_id',
    :'admin_user_id',
    :'admin_role_id'
WHERE NOT EXISTS (
    SELECT 1
    FROM user_roles
    WHERE user_id = :'admin_user_id'
      AND role_id = :'admin_role_id'
);

COMMIT;


-- Verification


SELECT
    u.username,
    r.role_code,
    r.role_name,
    ur.assigned_at
FROM user_roles ur
JOIN users u
    ON u.id = ur.user_id
JOIN roles r
    ON r.id = ur.role_id;
