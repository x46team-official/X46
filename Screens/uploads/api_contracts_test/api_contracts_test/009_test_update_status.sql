-- API-009 : UPDATE / ACTIVATE / DEACTIVATE TEST 

-- API-T050 : VALID UPDATE TEST
-- Expected API : 200 OK

BEGIN;

UPDATE test_master tm
SET
    test_name = 'Complete Blood Count Updated',
    selling_price = 400,
    cost_price = 250,
    cprr = 0
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
WHERE tm.organization_id = o.id
  AND tm.branch_id = b.id
  AND o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND tm.test_code = 'CBC001'
RETURNING
    tm.id,
    tm.organization_id,
    tm.branch_id,
    tm.test_code,
    tm.test_name,
    tm.selling_price,
    tm.cost_price,
    tm.cprr,
    tm.is_active;

ROLLBACK;

-- API-T051 : UPDATE NON-EXISTING TEST
-- Expected API : 404 Not Found

BEGIN;

UPDATE test_master tm
SET test_name = 'Invalid Test'
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
WHERE tm.organization_id = o.id
  AND tm.branch_id = b.id
  AND o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND tm.id = '00000000-0000-0000-0000-000000000000'
RETURNING
    tm.id,
    tm.test_code,
    tm.test_name;

ROLLBACK;

-- API-T052 : UPDATE TEST WITH DUPLICATE NAME
-- Expected API : 409 Conflict


BEGIN;

-- Second test in the same organization/branch to create a real name collision
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
    'CBC002',
    'Duplicate Target Test',
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

-- Attempt to rename CBC001 to CBC002's name (violates uq_test_name)
UPDATE test_master tm
SET test_name = 'Duplicate Target Test'
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
WHERE tm.organization_id = o.id
  AND tm.branch_id = b.id
  AND o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND tm.test_code = 'CBC001';

ROLLBACK;

-- API-T053 : UPDATE TEST WITH INVALID ORGANIZATION SCOPE
-- Expected API : 404 Not Found

BEGIN;

UPDATE test_master tm
SET test_name = 'Invalid Organization Update'
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
WHERE tm.organization_id = o.id
  AND tm.branch_id = b.id
  AND o.organization_code = 'INVALID-ORG'
  AND b.branch_code = 'PUNE002'
  AND tm.test_code = 'CBC001'
RETURNING
    tm.id,
    tm.test_code,
    tm.test_name;

ROLLBACK;


-- API-T054 : UPDATE TEST WITH INVALID BRANCH SCOPE
-- Expected API : 404 Not Found


BEGIN;

UPDATE test_master tm
SET test_name = 'Invalid Branch Update'
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
WHERE tm.organization_id = o.id
  AND tm.branch_id = b.id
  AND o.organization_code = 'LAB002'
  AND b.branch_code = 'INVALID-BRANCH'
  AND tm.test_code = 'CBC001'
RETURNING
    tm.id,
    tm.test_code,
    tm.test_name;

ROLLBACK;



-- API-T055 : DEACTIVATE TEST
-- API-T056 : VERIFY DEACTIVATED TEST
-- API-T057 : REACTIVATE TEST
-- API-T058 : VERIFY REACTIVATED TEST
-- Expected API : 200 OK (is_active toggles false -> true)


BEGIN;

-- API-T055 : Deactivate
UPDATE test_master tm
SET is_active = false
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
WHERE tm.organization_id = o.id
  AND tm.branch_id = b.id
  AND o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND tm.test_code = 'CBC001'
RETURNING
    tm.id,
    tm.test_code,
    tm.test_name,
    tm.is_active;

-- API-T056 : Verify deactivated
SELECT
    tm.id,
    tm.test_code,
    tm.test_name,
    tm.is_active
FROM test_master tm
JOIN organizations o
    ON o.id = tm.organization_id
JOIN branches b
    ON b.id = tm.branch_id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND tm.test_code = 'CBC001';

-- API-T057 : Reactivate
UPDATE test_master tm
SET is_active = true
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
WHERE tm.organization_id = o.id
  AND tm.branch_id = b.id
  AND o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND tm.test_code = 'CBC001'
RETURNING
    tm.id,
    tm.test_code,
    tm.test_name,
    tm.is_active;

-- API-T058 : Verify reactivated
SELECT
    tm.id,
    tm.test_code,
    tm.test_name,
    tm.is_active
FROM test_master tm
JOIN organizations o
    ON o.id = tm.organization_id
JOIN branches b
    ON b.id = tm.branch_id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND tm.test_code = 'CBC001';

ROLLBACK;


-- API-T059 : DEACTIVATE NON-EXISTING TEST
-- Expected API : 404 Not Found

BEGIN;

UPDATE test_master tm
SET is_active = false
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
WHERE tm.organization_id = o.id
  AND tm.branch_id = b.id
  AND o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND tm.id = '00000000-0000-0000-0000-000000000000'
RETURNING
    tm.id,
    tm.test_code,
    tm.test_name,
    tm.is_active;

ROLLBACK;

-- API-T060 : FINAL CBC001 VERIFICATION
-- Expected : CBC001 unchanged - active, original name/price
-- (all preceding test cases ran inside BEGIN/ROLLBACK blocks)

SELECT
    tm.id,
    o.organization_code,
    b.branch_code,
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
  AND tm.test_code = 'CBC001';
