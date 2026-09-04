-- API-005 : USER ROLE MANAGEMENT
-- API CONTRACT DATABASE TESTS
-- API-T020 : VALID USER ROLE ASSIGNMENT
-- Expected API : 201 Created

BEGIN;

INSERT INTO user_roles (
    organization_id,
    branch_id,
    user_id,
    role_id
)
SELECT
    u.organization_id,
    u.branch_id,
    u.id,
    r.id
FROM users u
JOIN roles r
    ON r.organization_id = u.organization_id
   AND r.branch_id = u.branch_id
WHERE u.organization_id = (
        SELECT id
        FROM organizations
        WHERE organization_code = 'LAB002'
    )
  AND u.branch_id = (
        SELECT id
        FROM branches
        WHERE branch_code = 'PUNE002'
          AND organization_id = (
              SELECT id
              FROM organizations
              WHERE organization_code = 'LAB002'
          )
    )
  AND u.username = 'test_user_001'
  AND r.role_code = 'LAB_TEST_ROLE_001'
RETURNING
    organization_id,
    branch_id,
    user_id,
    role_id,
    assigned_at;

ROLLBACK;

-- API-T021 : MISSING USER
-- Expected API : 404 Not Found

BEGIN;

INSERT INTO user_roles (
    organization_id,
    branch_id,
    user_id,
    role_id
)
SELECT
    o.id,
    b.id,
    NULL,
    r.id
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
JOIN roles r
    ON r.organization_id = o.id
   AND r.branch_id = b.id
   AND r.role_code = 'LAB_TEST_ROLE_001'
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002';

ROLLBACK;

-- API-T022 : MISSING ROLE
-- Expected API : 404 Not Found

BEGIN;

INSERT INTO user_roles (
    organization_id,
    branch_id,
    user_id,
    role_id
)
SELECT
    o.id,
    b.id,
    u.id,
    NULL
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
JOIN users u
    ON u.organization_id = o.id
   AND u.branch_id = b.id
   AND u.username = 'test_user_001'
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002';

ROLLBACK;

-- API-T023 : DUPLICATE USER ROLE
-- Expected API : 409 Conflict

BEGIN;

-- First assignment
INSERT INTO user_roles (
    organization_id,
    branch_id,
    user_id,
    role_id
)
SELECT
    u.organization_id,
    u.branch_id,
    u.id,
    r.id
FROM users u
JOIN roles r
    ON r.organization_id = u.organization_id
   AND r.branch_id = u.branch_id
WHERE u.organization_id = (
        SELECT id
        FROM organizations
        WHERE organization_code = 'LAB002'
    )
  AND u.branch_id = (
        SELECT id
        FROM branches
        WHERE branch_code = 'PUNE002'
          AND organization_id = (
              SELECT id
              FROM organizations
              WHERE organization_code = 'LAB002'
          )
    )
  AND u.username = 'test_user_001'
  AND r.role_code = 'LAB_TEST_ROLE_001';


-- Duplicate assignment
INSERT INTO user_roles (
    organization_id,
    branch_id,
    user_id,
    role_id
)
SELECT
    u.organization_id,
    u.branch_id,
    u.id,
    r.id
FROM users u
JOIN roles r
    ON r.organization_id = u.organization_id
   AND r.branch_id = u.branch_id
WHERE u.organization_id = (
        SELECT id
        FROM organizations
        WHERE organization_code = 'LAB002'
    )
  AND u.branch_id = (
        SELECT id
        FROM branches
        WHERE branch_code = 'PUNE002'
          AND organization_id = (
              SELECT id
              FROM organizations
              WHERE organization_code = 'LAB002'
          )
    )
  AND u.username = 'test_user_001'
  AND r.role_code = 'LAB_TEST_ROLE_001';

ROLLBACK;


-- API-T024 : INVALID ORGANIZATION / BRANCH
-- Expected API : 404 Not Found

BEGIN;

INSERT INTO user_roles (
    organization_id,
    branch_id,
    user_id,
    role_id
)
SELECT
    o.id,
    b.id,
    u.id,
    r.id
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
JOIN users u
    ON u.organization_id = o.id
   AND u.branch_id = b.id
JOIN roles r
    ON r.organization_id = o.id
   AND r.branch_id = b.id
WHERE o.organization_code = 'INVALID-ORG'
  AND b.branch_code = 'INVALID-BRANCH'
  AND u.username = 'test_user_001'
  AND r.role_code = 'LAB_TEST_ROLE_001';

ROLLBACK;


-- VERIFICATION

SELECT
    ur.organization_id,
    ur.branch_id,
    ur.user_id,
    u.username,
    ur.role_id,
    r.role_code,
    r.role_name,
    ur.assigned_at
FROM user_roles ur
JOIN users u
    ON u.id = ur.user_id
JOIN roles r
    ON r.id = ur.role_id
WHERE u.username = 'test_user_001'
  AND r.role_code = 'LAB_TEST_ROLE_001';