-- API-004 : CREATE USER
-- API-T014 : VALID USER CREATION
-- Expected API : 201 Created

BEGIN;

INSERT INTO users (
    organization_id,
    branch_id,
    username,
    email,
    password_hash,
    first_name,
    last_name
)
SELECT
    o.id,
    b.id,
    'test_user_001',
    'testuser001@x46.com',
    'TEST_HASH_123',
    'Test',
    'User'
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
RETURNING
    id,
    organization_id,
    branch_id,
    username,
    email,
    first_name,
    last_name,
    is_active;

ROLLBACK;


-- API-004-T015 : MISSING USERNAME
-- Expected API : 400 Bad Request

BEGIN;

INSERT INTO users (
    organization_id,
    branch_id,
    username,
    email,
    password_hash,
    first_name,
    last_name
)
SELECT
    o.id,
    b.id,
    NULL,
    'missingusername@x46.com',
    'TEST_HASH_123',
    'Test',
    'User'
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002';

ROLLBACK;


-- API-004-T016 : MISSING PASSWORD
-- Expected API : 400 Bad Request

BEGIN;

INSERT INTO users (
    organization_id,
    branch_id,
    username,
    email,
    password_hash,
    first_name,
    last_name
)
SELECT
    o.id,
    b.id,
    'missing_password_user',
    'missingpassword@x46.com',
    NULL,
    'Test',
    'User'
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002';

ROLLBACK;


-- API-004-T017 : MISSING FIRST NAME
-- Expected API : 400 Bad Request

BEGIN;

INSERT INTO users (
    organization_id,
    branch_id,
    username,
    email,
    password_hash,
    first_name,
    last_name
)
SELECT
    o.id,
    b.id,
    'Manas',
    'manas@x46.com',
    'Manas123',
    NULL,
    'User'
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002';

ROLLBACK;


-- API-004-T018 : DUPLICATE USERNAME
-- Expected API : 409 Conflict

BEGIN;

-- First user
INSERT INTO users (
    organization_id,
    branch_id,
    username,
    email,
    password_hash,
    first_name,
    last_name
)
SELECT
    o.id,
    b.id,
    'manas',
    'Manas@x46.com',
    'Manas',
    'First',
    'User'
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002';


-- Duplicate username
INSERT INTO users (
    organization_id,
    branch_id,
    username,
    email,
    password_hash,
    first_name,
    last_name
)
SELECT
    o.id,
    b.id,
    'manas',
    'Manas@x46.com',
    'Manas123',
    'Second',
    'User'
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002';

ROLLBACK;


-- API4-T019 : INVALID ORGANIZATION / BRANCH
-- Expected API : 404 Not Found

BEGIN;

INSERT INTO users (
    organization_id,
    branch_id,
    username,
    email,
    password_hash,
    first_name,
    last_name
)
SELECT
    o.id,
    b.id,
        'manas',
    'Manas@x46.com',
    'Manas123',
    'Invalid',
    'User'
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
WHERE o.organization_code = 'ORG'
  AND b.branch_code = 'BRANCH';

ROLLBACK;