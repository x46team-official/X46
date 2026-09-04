BEGIN;

WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        am.branch_id,
        am.id AS accession_id,
        at.id AS accession_test_id,
        u.id AS admin_user_id
    FROM organizations o

    JOIN accession_master am
        ON am.organization_id = o.id

    JOIN accession_tests at
        ON at.accession_id = am.id

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    WHERE o.organization_code = 'LAB002'
      AND am.accession_number = 'ACC0001'

    LIMIT 1
)
SELECT *
FROM ctx;

-- INVALID ACCESSION TEST ID
-- Expected API: 404

BEGIN;

SAVEPOINT invalid_accession_test;

WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        am.branch_id,
        u.id AS collector_id
    FROM organizations o
    JOIN accession_master am
        ON am.organization_id = o.id
    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'
    WHERE o.organization_code = 'LAB002'
      AND am.accession_number = 'ACC0001'
    LIMIT 1
)

INSERT INTO sample_collection
(
    organization_id,
    branch_id,
    accession_test_id,
    collector_id,
    collection_datetime,
    collection_location,
    sample_condition,
    quantity,
    quantity_unit,
    collection_status,
    remarks,
    created_by
)
SELECT
    organization_id,
    branch_id,
    '00000000-0000-0000-0000-000000000000',
    collector_id,
    CURRENT_TIMESTAMP,
    'Sample Collection Center',
    'GOOD',
    5,
    'mL',
    'COLLECTED',
    'Invalid accession test',
    collector_id
FROM ctx;

ROLLBACK TO SAVEPOINT invalid_accession_test;

SELECT
    'PASS' AS validation,
    'Invalid accession_test_id rejected by FK' AS result;


-- INVALID COLLECTOR
-- Expected API: 404

SAVEPOINT invalid_collector;

WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        am.branch_id,
        at.id AS accession_test_id
    FROM organizations o

    JOIN accession_master am
        ON am.organization_id = o.id

    JOIN accession_tests at
        ON at.accession_id = am.id

    WHERE o.organization_code = 'LAB002'
      AND am.accession_number = 'ACC0001'

    LIMIT 1
)

INSERT INTO sample_collection
(
    organization_id,
    branch_id,
    accession_test_id,
    collector_id,
    collection_datetime,
    collection_location,
    sample_condition,
    quantity,
    quantity_unit,
    collection_status,
    remarks,
    created_by
)
SELECT
    organization_id,
    branch_id,
    accession_test_id,
    '00000000-0000-0000-0000-000000000000',
    CURRENT_TIMESTAMP,
    'Sample Collection Center',
    'GOOD',
    5,
    'mL',
    'COLLECTED',
    'Invalid collector',
    '00000000-0000-0000-0000-000000000000'
FROM ctx;

ROLLBACK TO SAVEPOINT invalid_collector;

SELECT
    'PASS' AS validation,
    'Invalid collector rejected by FK' AS result;

-- INVALID SAMPLE CONDITION
-- Expected API: 400

SAVEPOINT invalid_sample_condition;

WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        at.branch_id,
        at.id AS accession_test_id,
        u.id AS admin_user_id
    FROM organizations o

    JOIN accession_master am
        ON am.organization_id = o.id

    JOIN accession_tests at
        ON at.accession_id = am.id

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    WHERE o.organization_code = 'LAB002'
      AND am.accession_number = 'ACC0001'

    LIMIT 1
)

INSERT INTO sample_collection
(
    organization_id,
    branch_id,
    accession_test_id,
    collector_id,
    collection_datetime,
    collection_location,
    sample_condition,
    quantity,
    quantity_unit,
    collection_status,
    remarks,
    created_by
)
SELECT
    organization_id,
    branch_id,
    accession_test_id,
    admin_user_id,
    CURRENT_TIMESTAMP,
    'Sample Collection Center',
    'INVALID_CONDITION',
    5,
    'mL',
    'COLLECTED',
    'Invalid sample condition',
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT invalid_sample_condition;

SELECT
    'PASS' AS validation,
    'Invalid sample condition rejected' AS result;

-- INVALID COLLECTION STATUS
-- Expected API: 400

SAVEPOINT invalid_collection_status;

WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        at.branch_id,
        at.id AS accession_test_id,
        u.id AS admin_user_id
    FROM organizations o

    JOIN accession_master am
        ON am.organization_id = o.id

    JOIN accession_tests at
        ON at.accession_id = am.id

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    WHERE o.organization_code = 'LAB002'
      AND am.accession_number = 'ACC0001'

    LIMIT 1
)

INSERT INTO sample_collection
(
    organization_id,
    branch_id,
    accession_test_id,
    collector_id,
    collection_datetime,
    collection_location,
    sample_condition,
    quantity,
    quantity_unit,
    collection_status,
    remarks,
    created_by
)
SELECT
    organization_id,
    branch_id,
    accession_test_id,
    admin_user_id,
    CURRENT_TIMESTAMP,
    'Sample Collection Center',
    'GOOD',
    5,
    'mL',
    'INVALID_STATUS',
    'Invalid collection status',
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT invalid_collection_status;

SELECT
    'PASS' AS validation,
    'Invalid collection status rejected' AS result;

-- INVALID QUANTITY
-- Expected API: 400

SAVEPOINT invalid_quantity;

WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        at.branch_id,
        at.id AS accession_test_id,
        u.id AS admin_user_id
    FROM organizations o

    JOIN accession_master am
        ON am.organization_id = o.id

    JOIN accession_tests at
        ON at.accession_id = am.id

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    WHERE o.organization_code = 'LAB002'
      AND am.accession_number = 'ACC0001'

    LIMIT 1
)

INSERT INTO sample_collection
(
    organization_id,
    branch_id,
    accession_test_id,
    collector_id,
    collection_datetime,
    collection_location,
    sample_condition,
    quantity,
    quantity_unit,
    collection_status,
    remarks,
    created_by
)
SELECT
    organization_id,
    branch_id,
    accession_test_id,
    admin_user_id,
    CURRENT_TIMESTAMP,
    'Sample Collection Center',
    'GOOD',
    0,
    'mL',
    'COLLECTED',
    'Invalid quantity',
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT invalid_quantity;

SELECT
    'PASS' AS validation,
    'Invalid quantity rejected' AS result;


-- TEST 6
-- DUPLICATE SAMPLE COLLECTION
-- Expected API: 409

SAVEPOINT duplicate_sample_collection;

WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        at.branch_id,
        at.id AS accession_test_id,
        u.id AS admin_user_id
    FROM organizations o

    JOIN accession_master am
        ON am.organization_id = o.id

    JOIN accession_tests at
        ON at.accession_id = am.id

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    WHERE o.organization_code = 'LAB002'
      AND am.accession_number = 'ACC0001'

    LIMIT 1
)

INSERT INTO sample_collection
(
    organization_id,
    branch_id,
    accession_test_id,
    collector_id,
    collection_datetime,
    collection_location,
    sample_condition,
    quantity,
    quantity_unit,
    collection_status,
    remarks,
    created_by
)
SELECT
    organization_id,
    branch_id,
    accession_test_id,
    admin_user_id,
    CURRENT_TIMESTAMP,
    'Sample Collection Center',
    'GOOD',
    5,
    'mL',
    'COLLECTED',
    'Duplicate sample collection',
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT duplicate_sample_collection;

SELECT
    'PASS' AS validation,
    'Duplicate sample collection rejected' AS result;

-- INVALID ORGANIZATION / BRANCH SCOPE
-- Expected API: 404


SAVEPOINT invalid_scope;

WITH ctx AS
(
    SELECT
        at.id AS accession_test_id,
        u.id AS admin_user_id
    FROM organizations o

    JOIN accession_master am
        ON am.organization_id = o.id

    JOIN accession_tests at
        ON at.accession_id = am.id

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    WHERE o.organization_code = 'LAB002'
      AND am.accession_number = 'ACC0001'

    LIMIT 1
)

INSERT INTO sample_collection
(
    organization_id,
    branch_id,
    accession_test_id,
    collector_id,
    collection_datetime,
    collection_location,
    sample_condition,
    quantity,
    quantity_unit,
    collection_status,
    remarks,
    created_by
)
SELECT
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-0000-0000-000000000000',
    accession_test_id,
    admin_user_id,
    CURRENT_TIMESTAMP,
    'Sample Collection Center',
    'GOOD',
    5,
    'mL',
    'COLLECTED',
    'Invalid organization scope',
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT invalid_scope;

SELECT
    'PASS' AS validation,
    'Invalid organization/branch scope rejected' AS result;


COMMIT;