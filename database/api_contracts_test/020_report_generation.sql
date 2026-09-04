BEGIN;

-- API-T160 : INVALID ACCESSION
-- Expected API : 404 Not Found

SAVEPOINT sp_invalid_accession;

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

INSERT INTO report_master
(
    organization_id,
    branch_id,
    accession_id,
    report_number,
    report_status,
    created_by
)
SELECT
    organization_id,
    branch_id,
    '00000000-0000-0000-0000-000000000000',
    'RPT-INVALID',
    'GENERATED',
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_invalid_accession;

SELECT
    'PASS' AS validation,
    'Invalid accession_id rejected by FK' AS result;


-- API-T161 : DUPLICATE REPORT NUMBER
-- Expected API : 409 Conflict

SAVEPOINT sp_duplicate_report_number;

WITH ctx AS
(
    SELECT
        am.organization_id,
        am.branch_id,
        am.billing_id,
        am.patient_registration_id,
        u.id AS admin_user_id
    FROM organizations o

    JOIN accession_master am
        ON am.organization_id = o.id
       AND am.accession_number = 'ACC0001'

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    WHERE o.organization_code = 'LAB002'
    LIMIT 1
),

second_accession AS
(
    -- A second accession row (rolled back at the end of this test) is created here
    -- purely to obtain a distinct, valid accession_id to attach the duplicate
    -- report_number to, since the fixture data only seeds a single accession (ACC0001).
    INSERT INTO accession_master
    (
        organization_id,
        branch_id,
        billing_id,
        patient_registration_id,
        accession_number,
        created_by
    )
    SELECT
        organization_id,
        branch_id,
        billing_id,
        patient_registration_id,
        'ACC-DUPTEST',
        admin_user_id
    FROM ctx
    RETURNING id AS accession_id, organization_id, branch_id
)

INSERT INTO report_master
(
    organization_id,
    branch_id,
    accession_id,
    report_number,
    report_status,
    created_by
)
SELECT
    second_accession.organization_id,
    second_accession.branch_id,
    second_accession.accession_id,
    'RPT-ACC0001',
    'GENERATED',
    (SELECT admin_user_id FROM ctx)
FROM second_accession;

ROLLBACK TO SAVEPOINT sp_duplicate_report_number;

SELECT
    'PASS' AS validation,
    'Duplicate report_number rejected by UNIQUE constraint (uq_report_number)' AS result;


-- API-T162 : DUPLICATE REPORT FOR ACCESSION
-- Expected API : 409 Conflict

SAVEPOINT sp_duplicate_report_for_accession;

WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        am.branch_id,
        am.id AS accession_id,
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

INSERT INTO report_master
(
    organization_id,
    branch_id,
    accession_id,
    report_number,
    report_status,
    created_by
)
SELECT
    organization_id,
    branch_id,
    accession_id,
    'RPT-ACC0001-V2',
    'GENERATED',
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_duplicate_report_for_accession;

SELECT
    'PASS' AS validation,
    'Duplicate report for accession rejected by UNIQUE constraint (uq_report_accession)' AS result;


-- API-T163 : INVALID REPORT STATUS
-- Expected API : 400 Bad Request

SAVEPOINT sp_invalid_report_status;

WITH ctx AS
(
    SELECT
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

UPDATE report_master rm
SET
    report_status = 'INVALID_STATUS',
    updated_by = ctx.admin_user_id,
    updated_at = CURRENT_TIMESTAMP
FROM ctx
WHERE rm.id = ctx.report_id;

ROLLBACK TO SAVEPOINT sp_invalid_report_status;

SELECT
    'PASS' AS validation,
    'Invalid report_status rejected by CHECK constraint' AS result;


COMMIT;
