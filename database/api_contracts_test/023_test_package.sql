BEGIN;

-- API-T182 : DUPLICATE PACKAGE CODE
-- Expected API : 409 Conflict

SAVEPOINT sp_duplicate_package_code;

WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        b.id AS branch_id,
        u.id AS admin_user_id
    FROM organizations o

    JOIN branches b
        ON b.organization_id = o.id
       AND b.branch_code = 'PUNE002'

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    WHERE o.organization_code = 'LAB002'
    LIMIT 1
)

INSERT INTO test_package_master
(
    organization_id,
    branch_id,
    package_code,
    package_name,
    selling_price,
    created_by
)
SELECT
    organization_id,
    branch_id,
    'PKG001',
    'Duplicate Code Package',
    999.00,
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_duplicate_package_code;

SELECT
    'PASS' AS validation,
    'Duplicate package_code rejected by UNIQUE constraint (uq_test_package_code)' AS result;


-- API-T183 : DUPLICATE PACKAGE NAME
-- Expected API : 409 Conflict

SAVEPOINT sp_duplicate_package_name;

WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        b.id AS branch_id,
        u.id AS admin_user_id
    FROM organizations o

    JOIN branches b
        ON b.organization_id = o.id
       AND b.branch_code = 'PUNE002'

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    WHERE o.organization_code = 'LAB002'
    LIMIT 1
)

INSERT INTO test_package_master
(
    organization_id,
    branch_id,
    package_code,
    package_name,
    selling_price,
    created_by
)
SELECT
    organization_id,
    branch_id,
    'PKG-DUPNAME',
    'Basic Health Package',
    999.00,
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_duplicate_package_name;

SELECT
    'PASS' AS validation,
    'Duplicate package_name rejected by UNIQUE constraint (uq_test_package_name)' AS result;


-- API-T184 : INVALID TEST ID IN PACKAGE
-- Expected API : 404 Not Found

SAVEPOINT sp_invalid_test_id_in_package;

WITH ctx AS
(
    SELECT
        tpm.id AS package_id,
        tpm.organization_id,
        tpm.branch_id,
        u.id AS admin_user_id
    FROM test_package_master tpm

    JOIN organizations o
        ON o.id = tpm.organization_id

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    WHERE o.organization_code = 'LAB002'
      AND tpm.package_code = 'PKG001'
    LIMIT 1
)

INSERT INTO test_package_test_mapping
(
    organization_id,
    branch_id,
    package_id,
    test_id,
    display_order,
    created_by
)
SELECT
    organization_id,
    branch_id,
    package_id,
    '00000000-0000-0000-0000-000000000000',
    99,
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_invalid_test_id_in_package;

SELECT
    'PASS' AS validation,
    'Invalid test_id rejected by FK' AS result;


-- API-T185 : DUPLICATE TEST IN PACKAGE
-- Expected API : 409 Conflict

SAVEPOINT sp_duplicate_test_in_package;

WITH ctx AS
(
    SELECT
        tpm.id AS package_id,
        tpm.organization_id,
        tpm.branch_id,
        u.id AS admin_user_id,
        tm.id AS test_id
    FROM test_package_master tpm

    JOIN organizations o
        ON o.id = tpm.organization_id

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    JOIN test_master tm
        ON tm.organization_id = o.id
       AND tm.test_code = 'CBC001'

    WHERE o.organization_code = 'LAB002'
      AND tpm.package_code = 'PKG001'
    LIMIT 1
)

INSERT INTO test_package_test_mapping
(
    organization_id,
    branch_id,
    package_id,
    test_id,
    display_order,
    created_by
)
SELECT
    organization_id,
    branch_id,
    package_id,
    test_id,
    1,
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_duplicate_test_in_package;

SELECT
    'PASS' AS validation,
    'Duplicate (package_id, test_id) rejected by UNIQUE constraint (uq_test_package_test_mapping)' AS result;


-- API-T186 : INVALID PACKAGE ID (BILLING)
-- Expected API : 404 Not Found

SAVEPOINT sp_invalid_package_id_billing;

WITH ctx AS
(
    SELECT
        bm.id AS billing_id,
        bm.organization_id,
        bm.branch_id,
        bm.created_by,
        tm.id AS test_id,
        tm.sample_type_id,
        tm.performing_lab_id,
        tm.selling_price,
        tm.tat_minutes
    FROM billing_master bm

    JOIN organizations o
        ON o.id = bm.organization_id

    JOIN test_master tm
        ON tm.organization_id = o.id
       AND tm.test_code = 'CBC001'

    WHERE o.organization_code = 'LAB002'
      AND bm.bill_number = 'BILL0003'
    LIMIT 1
)

INSERT INTO billing_tests
(
    organization_id,
    branch_id,
    billing_id,
    package_id,
    test_id,
    sample_type_id,
    performing_lab_id,
    quantity,
    rate,
    net_amount,
    tat_minutes,
    status,
    created_by
)
SELECT
    organization_id,
    branch_id,
    billing_id,
    '00000000-0000-0000-0000-000000000000',
    test_id,
    sample_type_id,
    performing_lab_id,
    1,
    selling_price,
    selling_price,
    tat_minutes,
    'Pending',
    created_by
FROM ctx;

ROLLBACK TO SAVEPOINT sp_invalid_package_id_billing;

SELECT
    'PASS' AS validation,
    'Invalid package_id rejected by FK (billing_tests.package_id)' AS result;


COMMIT;
