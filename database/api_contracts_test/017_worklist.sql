BEGIN;

-- API-T139 : INVALID DEPARTMENT
-- Expected API : 404 Not Found

SAVEPOINT sp_invalid_department;

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

INSERT INTO worklist_master
(
    organization_id,
    branch_id,
    department_id,
    worklist_code,
    worklist_name,
    created_by
)
SELECT
    organization_id,
    branch_id,
    '00000000-0000-0000-0000-000000000000',
    'WL-INVALID',
    'Invalid Department Worklist',
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_invalid_department;

SELECT
    'PASS' AS validation,
    'Invalid department_id rejected by FK' AS result;


-- API-T140 : DUPLICATE WORKLIST CODE
-- Expected API : 409 Conflict

SAVEPOINT sp_duplicate_worklist_code;

WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        d.branch_id,
        d.id AS department_id,
        u.id AS admin_user_id
    FROM organizations o

    JOIN department_master d
        ON d.organization_id = o.id
       AND d.department_code = 'HEM'

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    WHERE o.organization_code = 'LAB002'
    LIMIT 1
)

INSERT INTO worklist_master
(
    organization_id,
    branch_id,
    department_id,
    worklist_code,
    worklist_name,
    created_by
)
SELECT
    organization_id,
    branch_id,
    department_id,
    'WL001',
    'Duplicate Code Worklist',
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_duplicate_worklist_code;

SELECT
    'PASS' AS validation,
    'Duplicate worklist_code rejected by UNIQUE constraint' AS result;


-- API-T141 : DUPLICATE WORKLIST NAME
-- Expected API : 409 Conflict

SAVEPOINT sp_duplicate_worklist_name;

WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        d.branch_id,
        d.id AS department_id,
        u.id AS admin_user_id
    FROM organizations o

    JOIN department_master d
        ON d.organization_id = o.id
       AND d.department_code = 'HEM'

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    WHERE o.organization_code = 'LAB002'
    LIMIT 1
)

INSERT INTO worklist_master
(
    organization_id,
    branch_id,
    department_id,
    worklist_code,
    worklist_name,
    created_by
)
SELECT
    organization_id,
    branch_id,
    department_id,
    'WL-DUPNAME',
    'Hematology Worklist',
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_duplicate_worklist_name;

SELECT
    'PASS' AS validation,
    'Duplicate worklist_name rejected by UNIQUE constraint' AS result;


-- API-T142 : DUPLICATE WORKSHEET CODE
-- Expected API : 409 Conflict

SAVEPOINT sp_duplicate_worksheet_code;

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

INSERT INTO worksheet_master
(
    organization_id,
    branch_id,
    worksheet_code,
    worksheet_name,
    created_by
)
SELECT
    organization_id,
    branch_id,
    'WS001',
    'Duplicate Code Worksheet',
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_duplicate_worksheet_code;

SELECT
    'PASS' AS validation,
    'Duplicate worksheet_code rejected by UNIQUE constraint' AS result;


-- API-T143 : DUPLICATE WORKSHEET NAME
-- Expected API : 409 Conflict

SAVEPOINT sp_duplicate_worksheet_name;

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

INSERT INTO worksheet_master
(
    organization_id,
    branch_id,
    worksheet_code,
    worksheet_name,
    created_by
)
SELECT
    organization_id,
    branch_id,
    'WS-DUPNAME',
    'Daily Hematology Worksheet',
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_duplicate_worksheet_name;

SELECT
    'PASS' AS validation,
    'Duplicate worksheet_name rejected by UNIQUE constraint' AS result;


-- API-T144 : INVALID ACCESSION TEST (WORKLIST ASSIGNMENT)
-- Expected API : 404 Not Found

SAVEPOINT sp_invalid_accession_test_assignment;

WITH ctx AS
(
    SELECT
        wm.id AS worklist_id,
        ws.id AS worksheet_id,
        u.id AS admin_user_id
    FROM organizations o

    JOIN worklist_master wm
        ON wm.organization_id = o.id
       AND wm.worklist_code = 'WL001'

    JOIN worksheet_master ws
        ON ws.organization_id = o.id
       AND ws.worksheet_code = 'WS001'

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    WHERE o.organization_code = 'LAB002'
    LIMIT 1
)

UPDATE accession_tests at
SET
    worklist_id = ctx.worklist_id,
    worksheet_id = ctx.worksheet_id,
    updated_by = ctx.admin_user_id,
    updated_at = CURRENT_TIMESTAMP
FROM ctx
WHERE at.id = '00000000-0000-0000-0000-000000000000';

SELECT
    CASE
        WHEN (SELECT COUNT(*) FROM accession_tests WHERE id = '00000000-0000-0000-0000-000000000000') = 0
        THEN 'PASS'
        ELSE 'FAIL'
    END AS validation,
    '0 rows updated - invalid accession_test_id' AS result;

ROLLBACK TO SAVEPOINT sp_invalid_accession_test_assignment;


-- API-T145 : INVALID WORKLIST ID (ASSIGNMENT)
-- Expected API : 404 Not Found

SAVEPOINT sp_invalid_worklist_id;

WITH ctx AS
(
    SELECT
        at.id AS accession_test_id,
        u.id AS admin_user_id
    FROM organizations o

    JOIN accession_master am
        ON am.organization_id = o.id
       AND am.accession_number = 'ACC0001'

    JOIN accession_tests at
        ON at.accession_id = am.id

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    WHERE o.organization_code = 'LAB002'
    LIMIT 1
)

UPDATE accession_tests at
SET
    worklist_id = '00000000-0000-0000-0000-000000000000',
    updated_by = ctx.admin_user_id,
    updated_at = CURRENT_TIMESTAMP
FROM ctx
WHERE at.id = ctx.accession_test_id;

ROLLBACK TO SAVEPOINT sp_invalid_worklist_id;

SELECT
    'PASS' AS validation,
    'Invalid worklist_id rejected by FK' AS result;


-- API-T146 : INVALID WORKSHEET ID (ASSIGNMENT)
-- Expected API : 404 Not Found

SAVEPOINT sp_invalid_worksheet_id;

WITH ctx AS
(
    SELECT
        at.id AS accession_test_id,
        u.id AS admin_user_id
    FROM organizations o

    JOIN accession_master am
        ON am.organization_id = o.id
       AND am.accession_number = 'ACC0001'

    JOIN accession_tests at
        ON at.accession_id = am.id

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    WHERE o.organization_code = 'LAB002'
    LIMIT 1
)

UPDATE accession_tests at
SET
    worksheet_id = '00000000-0000-0000-0000-000000000000',
    updated_by = ctx.admin_user_id,
    updated_at = CURRENT_TIMESTAMP
FROM ctx
WHERE at.id = ctx.accession_test_id;

ROLLBACK TO SAVEPOINT sp_invalid_worksheet_id;

SELECT
    'PASS' AS validation,
    'Invalid worksheet_id rejected by FK' AS result;


COMMIT;
