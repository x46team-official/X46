-- ORG-003 : CREATE ROLE

-- API-3-T009 : VALID ROLE CREATION
-- Expected API : 201 Created

BEGIN;

INSERT INTO roles (
    organization_id,
    branch_id,
    role_code,
    role_name
)
SELECT
    o.id,
    b.id,
    'LAB_TEST_ROLE_001',
    'Lab Test Role'
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
RETURNING
    id,
    organization_id,
    branch_id,
    role_code,
    role_name;

ROLLBACK;

-- API-3-T010 : MISSING ROLE CODE
-- Expected API : 400 Bad Request

BEGIN;

INSERT INTO roles (
    organization_id,
    branch_id,
    role_code,
    role_name
)
SELECT
    o.id,
    b.id,
    NULL,
    'Administrator'
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002';

ROLLBACK;

-- API-3-T011 : MISSING ROLE NAME
-- Expected API : 400 Bad Request

BEGIN;

INSERT INTO roles (
    organization_id,
    branch_id,
    role_code,
    role_name
)
SELECT
    o.id,
    b.id,
    'RECEPTION',
    NULL
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002';

ROLLBACK;

-- API-3-T012 : DUPLICATE ROLE CODE
-- Expected API : 409 Conflict

BEGIN;

-- First role
INSERT INTO roles (
    organization_id,
    branch_id,
    role_code,
    role_name
)
SELECT
    o.id,
    b.id,
    'TEST_ROLE_DUP',
    'Test Role'
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002';

-- Duplicate role
INSERT INTO roles (
    organization_id,
    branch_id,
    role_code,
    role_name
)
SELECT
    o.id,
    b.id,
    'ADMIN',
    'ADMINISTRATOR'
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002';

ROLLBACK;

-- API-3-T013 : INVALID ORGANIZATION / BRANCH
-- Expected API : 404 Not Found


BEGIN;

INSERT INTO roles (
    organization_id,
    branch_id,
    role_code,
    role_name
)
SELECT
    o.id,
    b.id,
    'TECHNICIAN',
    'Technician'
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
WHERE o.organization_code = 'INVALID-ORG'
  AND b.branch_code = 'INVALID-BRANCH';

ROLLBACK;