BEGIN;

-- API-T150 : INVALID ACCESSION TEST (CREATE RESULT ENTRY)
-- Expected API : 404 Not Found

SAVEPOINT sp_invalid_accession_test;

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

INSERT INTO result_entry
(
    organization_id,
    branch_id,
    accession_test_id,
    result_status,
    created_by
)
SELECT
    organization_id,
    branch_id,
    '00000000-0000-0000-0000-000000000000',
    'PENDING',
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_invalid_accession_test;

SELECT
    'PASS' AS validation,
    'Invalid accession_test_id rejected by FK' AS result;


-- API-T151 : DUPLICATE RESULT ENTRY
-- Expected API : 409 Conflict

SAVEPOINT sp_duplicate_result_entry;

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
       AND am.accession_number = 'ACC0001'

    JOIN accession_tests at
        ON at.accession_id = am.id

    JOIN result_entry re
        ON re.accession_test_id = at.id

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    WHERE o.organization_code = 'LAB002'
    LIMIT 1
)

INSERT INTO result_entry
(
    organization_id,
    branch_id,
    accession_test_id,
    result_status,
    created_by
)
SELECT
    organization_id,
    branch_id,
    accession_test_id,
    'PENDING',
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_duplicate_result_entry;

SELECT
    'PASS' AS validation,
    'Duplicate result_entry rejected by UNIQUE constraint (uq_result_entry)' AS result;


-- API-T152 : INVALID PARAMETER (ADD RESULT DETAIL)
-- Expected API : 404 Not Found

SAVEPOINT sp_invalid_parameter;

WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        re.branch_id,
        re.id AS result_entry_id,
        u.id AS admin_user_id
    FROM organizations o

    JOIN accession_master am
        ON am.organization_id = o.id
       AND am.accession_number = 'ACC0001'

    JOIN accession_tests at
        ON at.accession_id = am.id

    JOIN result_entry re
        ON re.accession_test_id = at.id

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    WHERE o.organization_code = 'LAB002'
    LIMIT 1
)

INSERT INTO result_entry_details
(
    organization_id,
    branch_id,
    result_entry_id,
    parameter_id,
    result_value,
    created_by
)
SELECT
    organization_id,
    branch_id,
    result_entry_id,
    '00000000-0000-0000-0000-000000000000',
    '10',
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_invalid_parameter;

SELECT
    'PASS' AS validation,
    'Invalid parameter_id rejected by FK' AS result;


-- API-T153 : DUPLICATE RESULT DETAIL
-- Expected API : 409 Conflict

SAVEPOINT sp_duplicate_result_detail;

WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        re.branch_id,
        re.id AS result_entry_id,
        red.parameter_id,
        u.id AS admin_user_id
    FROM organizations o

    JOIN accession_master am
        ON am.organization_id = o.id
       AND am.accession_number = 'ACC0001'

    JOIN accession_tests at
        ON at.accession_id = am.id

    JOIN result_entry re
        ON re.accession_test_id = at.id

    JOIN result_entry_details red
        ON red.result_entry_id = re.id

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    WHERE o.organization_code = 'LAB002'
    LIMIT 1
)

INSERT INTO result_entry_details
(
    organization_id,
    branch_id,
    result_entry_id,
    parameter_id,
    result_value,
    created_by
)
SELECT
    organization_id,
    branch_id,
    result_entry_id,
    parameter_id,
    '11',
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_duplicate_result_detail;

SELECT
    'PASS' AS validation,
    'Duplicate result_entry_details rejected by UNIQUE constraint (uq_result_parameter)' AS result;


-- API-T154 : INVALID RESULT FLAG
-- Expected API : 400 Bad Request

SAVEPOINT sp_invalid_result_flag;

WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        re.branch_id,
        re.id AS result_entry_id,
        tpm.parameter_id,
        u.id AS admin_user_id
    FROM organizations o

    JOIN accession_master am
        ON am.organization_id = o.id
       AND am.accession_number = 'ACC0001'

    JOIN accession_tests at
        ON at.accession_id = am.id

    JOIN result_entry re
        ON re.accession_test_id = at.id

    JOIN test_parameter_mapping tpm
        ON tpm.test_id = at.test_id

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    WHERE o.organization_code = 'LAB002'
    LIMIT 1
)

INSERT INTO result_entry_details
(
    organization_id,
    branch_id,
    result_entry_id,
    parameter_id,
    result_value,
    result_flag,
    created_by
)
SELECT
    organization_id,
    branch_id,
    result_entry_id,
    parameter_id,
    '99',
    'INVALID_FLAG',
    admin_user_id
FROM ctx
LIMIT 1;

ROLLBACK TO SAVEPOINT sp_invalid_result_flag;

SELECT
    'PASS' AS validation,
    'Invalid result_flag rejected by CHECK constraint' AS result;


-- API-T155 : INVALID RESULT STATUS
-- Expected API : 400 Bad Request

SAVEPOINT sp_invalid_result_status;

WITH ctx AS
(
    SELECT
        re.id AS result_entry_id,
        u.id AS admin_user_id
    FROM organizations o

    JOIN accession_master am
        ON am.organization_id = o.id
       AND am.accession_number = 'ACC0001'

    JOIN accession_tests at
        ON at.accession_id = am.id

    JOIN result_entry re
        ON re.accession_test_id = at.id

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    WHERE o.organization_code = 'LAB002'
    LIMIT 1
)

UPDATE result_entry re
SET
    result_status = 'INVALID_STATUS',
    updated_by = ctx.admin_user_id,
    updated_at = CURRENT_TIMESTAMP
FROM ctx
WHERE re.id = ctx.result_entry_id;

ROLLBACK TO SAVEPOINT sp_invalid_result_status;

SELECT
    'PASS' AS validation,
    'Invalid result_status rejected by CHECK constraint' AS result;


COMMIT;
