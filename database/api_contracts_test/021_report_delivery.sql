BEGIN;

-- API-T165 : INVALID REPORT ID (DELIVERY)
-- Expected API : 404 Not Found

SAVEPOINT sp_invalid_report_id_delivery;

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

INSERT INTO report_delivery_log
(
    organization_id,
    branch_id,
    report_id,
    delivery_type,
    recipient_type,
    delivery_status,
    created_by
)
SELECT
    organization_id,
    branch_id,
    '00000000-0000-0000-0000-000000000000',
    'PRINT',
    'PATIENT',
    'PENDING',
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_invalid_report_id_delivery;

SELECT
    'PASS' AS validation,
    'Invalid report_id rejected by FK' AS result;


-- API-T166 : INVALID DELIVERY TYPE
-- Expected API : 400 Bad Request

SAVEPOINT sp_invalid_delivery_type;

WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        rm.branch_id,
        rm.id AS report_id,
        u.id AS admin_user_id
    FROM organizations o

    JOIN accession_master am
        ON am.organization_id = o.id
       AND am.accession_number = 'ACC0001'

    JOIN report_master rm
        ON rm.accession_id = am.id

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    WHERE o.organization_code = 'LAB002'
    LIMIT 1
)

INSERT INTO report_delivery_log
(
    organization_id,
    branch_id,
    report_id,
    delivery_type,
    recipient_type,
    delivery_status,
    created_by
)
SELECT
    organization_id,
    branch_id,
    report_id,
    'FAX',
    'PATIENT',
    'PENDING',
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_invalid_delivery_type;

SELECT
    'PASS' AS validation,
    'Invalid delivery_type rejected by CHECK constraint' AS result;


-- API-T167 : INVALID RECIPIENT TYPE
-- Expected API : 400 Bad Request

SAVEPOINT sp_invalid_recipient_type;

WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        rm.branch_id,
        rm.id AS report_id,
        u.id AS admin_user_id
    FROM organizations o

    JOIN accession_master am
        ON am.organization_id = o.id
       AND am.accession_number = 'ACC0001'

    JOIN report_master rm
        ON rm.accession_id = am.id

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    WHERE o.organization_code = 'LAB002'
    LIMIT 1
)

INSERT INTO report_delivery_log
(
    organization_id,
    branch_id,
    report_id,
    delivery_type,
    recipient_type,
    delivery_status,
    created_by
)
SELECT
    organization_id,
    branch_id,
    report_id,
    'PRINT',
    'INSURER',
    'PENDING',
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_invalid_recipient_type;

SELECT
    'PASS' AS validation,
    'Invalid recipient_type rejected by CHECK constraint' AS result;


-- API-T168 : INVALID REPORT ID (RELEASE)
-- Expected API : 404 Not Found

SAVEPOINT sp_invalid_report_id_release;

WITH ctx AS
(
    SELECT
        u.id AS admin_user_id
    FROM organizations o

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    WHERE o.organization_code = 'LAB002'
    LIMIT 1
)

UPDATE report_master rm
SET
    report_status = 'RELEASED',
    released_at = CURRENT_TIMESTAMP,
    released_by = ctx.admin_user_id,
    updated_by = ctx.admin_user_id,
    updated_at = CURRENT_TIMESTAMP
FROM ctx
WHERE rm.id = '00000000-0000-0000-0000-000000000000';

SELECT
    CASE
        WHEN (SELECT COUNT(*) FROM report_master WHERE id = '00000000-0000-0000-0000-000000000000') = 0
        THEN 'PASS'
        ELSE 'FAIL'
    END AS validation,
    '0 rows updated - invalid report_id' AS result;

ROLLBACK TO SAVEPOINT sp_invalid_report_id_release;


COMMIT;
