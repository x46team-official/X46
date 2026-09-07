-- API-007 : VIEW TEST (TEST MASTER)
-- API-T033 : VALID TEST RETRIEVAL
-- Expected API : 200 OK

BEGIN;

SELECT
    tm.id,
    tm.organization_id,
    tm.branch_id,
    tm.department_id,
    tm.test_code,
    tm.test_name,
    tm.selling_price,
    tm.cost_price,
    tm.cprr,
    tm.is_active
FROM test_master tm
JOIN organizations o
    ON o.id = tm.organization_id
JOIN branches b
    ON b.id = tm.branch_id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND tm.test_code = 'FTS';

ROLLBACK;


-- ============================================================
-- API-T034 : INVALID TEST ID
-- Expected API : 404 Not Found
-- ============================================================

BEGIN;

SELECT
    tm.id,
    tm.organization_id,
    tm.branch_id,
    tm.department_id,
    tm.test_code,
    tm.test_name,
    tm.selling_price,
    tm.cost_price,
    tm.cprr,
    tm.is_active
FROM test_master tm
JOIN organizations o
    ON o.id = tm.organization_id
JOIN branches b
    ON b.id = tm.branch_id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND tm.id = '00000000-0000-0000-0000-000000000001';

ROLLBACK;


-- ============================================================
-- API-T035 : INVALID ORGANIZATION
-- Expected API : 404 Not Found
-- ============================================================

BEGIN;

SELECT
    tm.id,
    tm.organization_id,
    tm.branch_id,
    tm.department_id,
    tm.test_code,
    tm.test_name,
    tm.selling_price,
    tm.cost_price,
    tm.cprr,
    tm.is_active
FROM test_master tm
JOIN organizations o
    ON o.id = tm.organization_id
JOIN branches b
    ON b.id = tm.branch_id
WHERE o.organization_code = 'INVALID-ORG'
  AND b.branch_code = 'PUNE002'
  AND tm.test_code = 'FTS';

ROLLBACK;


-- ============================================================
-- API-T036 : INVALID BRANCH
-- Expected API : 404 Not Found
-- ============================================================

BEGIN;

SELECT
    tm.id,
    tm.organization_id,
    tm.branch_id,
    tm.department_id,
    tm.test_code,
    tm.test_name,
    tm.selling_price,
    tm.cost_price,
    tm.cprr,
    tm.is_active
FROM test_master tm
JOIN organizations o
    ON o.id = tm.organization_id
JOIN branches b
    ON b.id = tm.branch_id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'INVALID-BRANCH'
  AND tm.test_code = 'FTS';

ROLLBACK;


-- ============================================================
-- API-T037 : TEST NOT BELONGING TO ORGANIZATION / BRANCH
-- Expected API : 404 Not Found
-- ============================================================

BEGIN;

SELECT
    tm.id,
    tm.organization_id,
    tm.branch_id,
    tm.department_id,
    tm.test_code,
    tm.test_name,
    tm.selling_price,
    tm.cost_price,
    tm.cprr,
    tm.is_active
FROM test_master tm
WHERE tm.test_code = 'FTS'
  AND tm.organization_id = (
      SELECT id
      FROM organizations
      WHERE organization_code = 'LAB002'
  )
  AND tm.branch_id = (
      SELECT id
      FROM branches
      WHERE branch_code = 'INVALID-BRANCH'
        AND organization_id = (
            SELECT id
            FROM organizations
            WHERE organization_code = 'LAB002'
        )
  );

ROLLBACK;


-- ============================================================
-- API-T038 : VIEW INACTIVE TEST
-- Expected API : 200 OK
-- Only applicable if inactive tests are allowed to be viewed
-- ============================================================

BEGIN;

-- Create temporary inactive test for dry-run
INSERT INTO test_master (
    organization_id,
    branch_id,
    department_id,
    test_code,
    test_name,
    selling_price,
    cost_price,
    cprr,
    is_active
)
VALUES (
    '4511ab2a-fac9-4bf9-ab93-91f695502c88',
    '58f472a9-647c-4ff8-a760-d08b81bf1b66',
    'db51cc0b-bdde-4d83-9874-a7880ea35400',
    'CBC2',
    'Complete Blood Count - 2',
    600.00,
    300.00,
    0.00,
    false
);

-- Retrieve inactive test
SELECT
    tm.id,
    tm.organization_id,
    tm.branch_id,
    tm.department_id,
    tm.test_code,
    tm.test_name,
    tm.selling_price,
    tm.cost_price,
    tm.cprr,
    tm.is_active
FROM test_master tm
JOIN organizations o
    ON o.id = tm.organization_id
JOIN branches b
    ON b.id = tm.branch_id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND tm.test_code = 'CBC2'
  AND tm.is_active = false;

-- Remove temporary test data
ROLLBACK;


-- ============================================================
-- VERIFICATION
-- ============================================================

SELECT
    tm.id,
    o.organization_code,
    b.branch_code,
    tm.test_code,
    tm.test_name,
    tm.selling_price,
    tm.cost_price,
    tm.cprr,
    tm.is_active
FROM test_master tm
JOIN organizations o
    ON o.id = tm.organization_id
JOIN branches b
    ON b.id = tm.branch_id
WHERE tm.test_code IN ('FTS', 'CBC2')
ORDER BY tm.test_code;