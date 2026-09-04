
-- API-006 : CREATE TEST (TEST MASTER)

-- API-T025 : VALID TEST CREATION
-- Expected API : 201 Created

BEGIN;

INSERT INTO test_master (
    organization_id,
    branch_id,
    department_id,
    test_code,
    test_name,
    selling_price,
    cost_price,
    cprr
)
SELECT
    o.id,
    b.id,
    d.id,
    'LFT001',
    'Liver Function Test',
    600,
    350,
    0
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
JOIN department_master d
    ON d.organization_id = o.id
   AND d.branch_id = b.id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND d.department_code = 'HEM'
RETURNING
    id,
    organization_id,
    branch_id,
    department_id,
    test_code,
    test_name,
    selling_price,
    cost_price,
    is_active;

ROLLBACK;



-- API-T026 : MISSING TEST CODE
-- Expected API : 400 Bad Request


BEGIN;

INSERT INTO test_master (
    organization_id,
    branch_id,
    department_id,
    test_code,
    test_name,
    selling_price,
    cost_price,
    cprr
)
SELECT
    o.id,
    b.id,
    d.id,
    NULL,
    'Missing Test Code',
    600,
    350,
    0
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
JOIN department_master d
    ON d.organization_id = o.id
   AND d.branch_id = b.id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND d.department_code = 'HEM';

ROLLBACK;



-- API-T027 : MISSING TEST NAME
-- Expected API : 400 Bad Request


BEGIN;

INSERT INTO test_master (
    organization_id,
    branch_id,
    department_id,
    test_code,
    test_name,
    selling_price,
    cost_price,
    cprr
)
SELECT
    o.id,
    b.id,
    d.id,
    'MISSINGNAME001',
    NULL,
    600,
    350,
    0
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
JOIN department_master d
    ON d.organization_id = o.id
   AND d.branch_id = b.id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND d.department_code = 'HEM';

ROLLBACK;



-- API-T028 : MISSING DEPARTMENT
-- Expected API : 400 Bad Request


BEGIN;

INSERT INTO test_master (
    organization_id,
    branch_id,
    department_id,
    test_code,
    test_name,
    selling_price,
    cost_price,
    cprr
)
SELECT
    o.id,
    b.id,
    NULL,
    'DEPT001',
    'No Department Test',
    600,
    350,
    0
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002';

ROLLBACK;



-- API-T029 : DUPLICATE TEST CODE
-- Expected API : 409 Conflict


BEGIN;

-- First test
INSERT INTO test_master (
    organization_id,
    branch_id,
    department_id,
    test_code,
    test_name,
    selling_price,
    cost_price,
    cprr
)
SELECT
    o.id,
    b.id,
    d.id,
    'TEST_DUP_001',
    'Duplicate Code Test A',
    600,
    350,
    0
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
JOIN department_master d
    ON d.organization_id = o.id
   AND d.branch_id = b.id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND d.department_code = 'HEM';

-- Duplicate test code
INSERT INTO test_master (
    organization_id,
    branch_id,
    department_id,
    test_code,
    test_name,
    selling_price,
    cost_price,
    cprr
)
SELECT
    o.id,
    b.id,
    d.id,
    'TEST_DUP_001',
    'Duplicate Code Test B',
    650,
    400,
    0
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
JOIN department_master d
    ON d.organization_id = o.id
   AND d.branch_id = b.id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND d.department_code = 'HEM';

ROLLBACK;



-- API-T030 : INVALID BRANCH
-- Expected API : 404 Not Found


BEGIN;

INSERT INTO test_master (
    organization_id,
    branch_id,
    department_id,
    test_code,
    test_name,
    selling_price,
    cost_price,
    cprr
)
SELECT
    o.id,
    '00000000-0000-0000-0000-000000000001',
    d.id,
    'INVALIDBRANCH001',
    'Invalid Branch Test',
    600,
    350,
    0
FROM organizations o
JOIN department_master d
    ON d.organization_id = o.id
WHERE o.organization_code = 'LAB002'
  AND d.department_code = 'HEM';

ROLLBACK;



-- API-T031 : INVALID DEPARTMENT
-- Expected API : 404 Not Found


BEGIN;

INSERT INTO test_master (
    organization_id,
    branch_id,
    department_id,
    test_code,
    test_name,
    selling_price,
    cost_price,
    cprr
)
SELECT
    o.id,
    b.id,
    '00000000-0000-0000-0000-000000000001',
    'INVALIDDEPT001',
    'Invalid Department Test',
    600,
    350,
    0
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002';

ROLLBACK;



-- API-T032 : DUPLICATE TEST NAME
-- Expected API : 409 Conflict


BEGIN;

-- First test
INSERT INTO test_master (
    organization_id,
    branch_id,
    department_id,
    test_code,
    test_name,
    selling_price,
    cost_price,
    cprr
)
SELECT
    o.id,
    b.id,
    d.id,
    'TEST_NAME_DUP_001',
    'Duplicate Test Name',
    600,
    350,
    0
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
JOIN department_master d
    ON d.organization_id = o.id
   AND d.branch_id = b.id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND d.department_code = 'HEM';

-- Duplicate test name with different test code
INSERT INTO test_master (
    organization_id,
    branch_id,
    department_id,
    test_code,
    test_name,
    selling_price,
    cost_price,
    cprr
)
SELECT
    o.id,
    b.id,
    d.id,
    'TEST_NAME_DUP_002',
    'Duplicate Test Name',
    650,
    400,
    0
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
JOIN department_master d
    ON d.organization_id = o.id
   AND d.branch_id = b.id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND d.department_code = 'HEM';

ROLLBACK;



-- VERIFICATION
-- All test records above should have been rolled back.
-- Expected result: 0 rows


SELECT
    tm.test_code,
    tm.test_name,
    tm.department_id,
    tm.is_active
FROM test_master tm
WHERE tm.test_code IN (
    'LFT001',
    'MISSINGNAME001',
    'NODEPT001',
    'TEST_DUP_001',
    'INVALIDBRANCH001',
    'INVALIDDEPT001',
    'TEST_NAME_DUP_001',
    'TEST_NAME_DUP_002'
);