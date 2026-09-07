
-- TEST MANAGEMENT API VALIDATION

-- BASE TEST RECORD

SELECT
    id,
    organization_id,
    branch_id,
    department_id,
    test_code,
    test_name,
    selling_price,
    cost_price,
    is_active
FROM test_master
LIMIT 1;

-- API-T039: UPDATE TEST
-- Expected: Test name updated successfully

-- API-T039: Update Test
-- Expected: Test updated successfully

UPDATE test_master
SET test_name = 'Complete Blood Count API Updated'
WHERE test_code = 'CBC001'
RETURNING
    id,
    test_code,
    test_name,
    selling_price,
    cost_price,
    is_active;

-- API-T040: MISSING TEST CODE
-- Expected: NOT NULL constraint error

INSERT INTO test_master (
    organization_id,
    branch_id,
    department_id,
    test_code,
    test_name
)
SELECT
    organization_id,
    branch_id,
    department_id,
    NULL,
    'Test Missing Code'
FROM test_master
LIMIT 1;

-- API-T041: MISSING TEST NAME
-- Expected: NOT NULL constraint error

INSERT INTO test_master (
    organization_id,
    branch_id,
    department_id,
    test_code,
    test_name
)
SELECT
    organization_id,
    branch_id,
    department_id,
    'TEST_NULL_NAME',
    NULL
FROM test_master
LIMIT 1;

-- API-T042: INVALID TEST ID
-- Expected: 0 rows

SELECT
    id,
    test_code,
    test_name
FROM test_master
WHERE id = '00000000-0000-0000-0000-000000000000';

-- API-T043: INVALID ORGANIZATION
-- Expected: 0 rows

SELECT
    id,
    organization_id,
    branch_id,
    test_code,
    test_name
FROM test_master
WHERE organization_id = '00000000-0000-0000-0000-000000000000';

-- API-T044: TEST FROM DIFFERENT ORGANIZATION
-- Expected: 0 rows

SELECT
    t.id,
    t.organization_id,
    t.branch_id,
    t.test_code,
    t.test_name
FROM test_master t
WHERE t.id = (
    SELECT id
    FROM test_master
    LIMIT 1
)
AND t.organization_id <> (
    SELECT organization_id
    FROM test_master
    LIMIT 1
);

-- API-T045: DUPLICATE TEST CODE
-- Expected: UNIQUE constraint error

INSERT INTO test_master (
    organization_id,
    branch_id,
    department_id,
    test_code,
    test_name
)
SELECT
    organization_id,
    branch_id,
    department_id,
    test_code,
    'Duplicate Code Test'
FROM test_master
LIMIT 1;

-- API-T046: DUPLICATE TEST NAME
-- Expected: UNIQUE constraint error

INSERT INTO test_master (
    organization_id,
    branch_id,
    department_id,
    test_code,
    test_name
)
SELECT
    organization_id,
    branch_id,
    department_id,
    'DUP_NAME_001',
    test_name
FROM test_master
LIMIT 1;

-- API-T047: DEACTIVATE TEST
-- Expected: is_active = false

UPDATE test_master
SET is_active = false
WHERE id = (
    SELECT id
    FROM test_master
    LIMIT 1
)
RETURNING
    id,
    test_code,
    test_name,
    is_active;

-- API-T048: LIST TESTS
-- Expected: Test records returned

SELECT
    id,
    test_code,
    test_name,
    selling_price,
    cost_price,
    is_active
FROM test_master
ORDER BY test_name;

-- API-T049: SEARCH TESTS
-- Expected: CBC-related tests returned

SELECT
    id,
    test_code,
    test_name,
    selling_price
FROM test_master
WHERE test_code ILIKE '%CBC%'
   OR test_name ILIKE '%CBC%';
