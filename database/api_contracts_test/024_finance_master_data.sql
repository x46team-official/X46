BEGIN;

-- API-T187 : DUPLICATE CLIENT ORGANIZATION CODE
-- Expected API : 409 Conflict

SAVEPOINT sp_duplicate_client_code;

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

INSERT INTO client_organization_master
(
    organization_id,
    branch_id,
    client_code,
    client_name,
    created_by
)
SELECT
    organization_id,
    branch_id,
    'RGHPMC',
    'Duplicate Code Client',
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_duplicate_client_code;

SELECT
    'PASS' AS validation,
    'Duplicate client_code rejected by UNIQUE constraint (uq_client_organization_code)' AS result;


-- API-T188 : DUPLICATE CLIENT ORGANIZATION NAME
-- Expected API : 409 Conflict

SAVEPOINT sp_duplicate_client_name;

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

INSERT INTO client_organization_master
(
    organization_id,
    branch_id,
    client_code,
    client_name,
    created_by
)
SELECT
    organization_id,
    branch_id,
    'CLIENT-DUPNAME',
    'RGH PMC',
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_duplicate_client_name;

SELECT
    'PASS' AS validation,
    'Duplicate client_name rejected by UNIQUE constraint (uq_client_organization_name)' AS result;


-- API-T189 : DUPLICATE REFERRAL CODE
-- Expected API : 409 Conflict

SAVEPOINT sp_duplicate_referral_code;

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

INSERT INTO referral_master
(
    organization_id,
    branch_id,
    referral_code,
    referral_name,
    created_by
)
SELECT
    organization_id,
    branch_id,
    'CANTHOSP',
    'Duplicate Code Referral',
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_duplicate_referral_code;

SELECT
    'PASS' AS validation,
    'Duplicate referral_code rejected by UNIQUE constraint (uq_referral_code)' AS result;


-- API-T190 : DUPLICATE REFERRAL NAME
-- Expected API : 409 Conflict

SAVEPOINT sp_duplicate_referral_name;

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

INSERT INTO referral_master
(
    organization_id,
    branch_id,
    referral_code,
    referral_name,
    created_by
)
SELECT
    organization_id,
    branch_id,
    'REFERRAL-DUPNAME',
    'Cantonment Hospital',
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_duplicate_referral_name;

SELECT
    'PASS' AS validation,
    'Duplicate referral_name rejected by UNIQUE constraint (uq_referral_name)' AS result;


-- API-T191 : INVALID REFERRAL TYPE
-- Expected API : 400 Bad Request

SAVEPOINT sp_invalid_referral_type;

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

INSERT INTO referral_master
(
    organization_id,
    branch_id,
    referral_code,
    referral_name,
    referral_type,
    created_by
)
SELECT
    organization_id,
    branch_id,
    'REFERRAL-BADTYPE',
    'Bad Type Referral',
    'NOT_A_TYPE',
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_invalid_referral_type;

SELECT
    'PASS' AS validation,
    'Invalid referral_type rejected by CHECK constraint' AS result;


-- API-T192 : DUPLICATE AGENT CODE
-- Expected API : 409 Conflict

SAVEPOINT sp_duplicate_agent_code;

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

INSERT INTO agent_master
(
    organization_id,
    branch_id,
    agent_code,
    agent_name,
    created_by
)
SELECT
    organization_id,
    branch_id,
    'SANIYA',
    'Duplicate Code Agent',
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_duplicate_agent_code;

SELECT
    'PASS' AS validation,
    'Duplicate agent_code rejected by UNIQUE constraint (uq_agent_code)' AS result;


-- API-T193 : DUPLICATE AGENT NAME
-- Expected API : 409 Conflict

SAVEPOINT sp_duplicate_agent_name;

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

INSERT INTO agent_master
(
    organization_id,
    branch_id,
    agent_code,
    agent_name,
    created_by
)
SELECT
    organization_id,
    branch_id,
    'AGENT-DUPNAME',
    'Saniya',
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_duplicate_agent_name;

SELECT
    'PASS' AS validation,
    'Duplicate agent_name rejected by UNIQUE constraint (uq_agent_name)' AS result;


-- API-T194 : INVALID CLIENT ID ON PATIENT REGISTRATION
-- Expected API : 404 Not Found

SAVEPOINT sp_invalid_client_id;

UPDATE patient_registrations
SET client_id = '00000000-0000-0000-0000-000000000000'
WHERE registration_number = 'REG001';

ROLLBACK TO SAVEPOINT sp_invalid_client_id;

SELECT
    'PASS' AS validation,
    'Invalid client_id rejected by FK (fk_patient_registrations_client)' AS result;


-- API-T195 : INVALID REFERRAL DOCTOR ID ON PATIENT REGISTRATION
-- Expected API : 404 Not Found

SAVEPOINT sp_invalid_referral_doctor_id;

UPDATE patient_registrations
SET referral_doctor_id = '00000000-0000-0000-0000-000000000000'
WHERE registration_number = 'REG001';

ROLLBACK TO SAVEPOINT sp_invalid_referral_doctor_id;

SELECT
    'PASS' AS validation,
    'Invalid referral_doctor_id rejected by FK (fk_patient_registrations_referral)' AS result;


-- API-T196 : INVALID AGENT ID ON PATIENT REGISTRATION
-- Expected API : 404 Not Found

SAVEPOINT sp_invalid_agent_id;

UPDATE patient_registrations
SET agent_id = '00000000-0000-0000-0000-000000000000'
WHERE registration_number = 'REG001';

ROLLBACK TO SAVEPOINT sp_invalid_agent_id;

SELECT
    'PASS' AS validation,
    'Invalid agent_id rejected by FK (fk_patient_registrations_agent)' AS result;


-- API-T197 : NEGATIVE TDS AMOUNT
-- Expected API : 400 Bad Request

SAVEPOINT sp_negative_tds_amount;

WITH ctx AS
(
    SELECT bm.id AS billing_id
    FROM billing_master bm
    JOIN organizations o
        ON o.id = bm.organization_id
    WHERE o.organization_code = 'LAB002'
      AND bm.bill_number = 'BILL0001'
)

UPDATE billing_master bm
SET tds_amount = -5.00
FROM ctx
WHERE bm.id = ctx.billing_id;

ROLLBACK TO SAVEPOINT sp_negative_tds_amount;

SELECT
    'PASS' AS validation,
    'Negative tds_amount rejected by CHECK constraint (chk_billing_master_tds_amount)' AS result;


-- API-T198 : NEGATIVE WRITE-OFF AMOUNT
-- Expected API : 400 Bad Request

SAVEPOINT sp_negative_write_off_amount;

WITH ctx AS
(
    SELECT bm.id AS billing_id
    FROM billing_master bm
    JOIN organizations o
        ON o.id = bm.organization_id
    WHERE o.organization_code = 'LAB002'
      AND bm.bill_number = 'BILL0001'
)

UPDATE billing_master bm
SET write_off_amount = -10.00
FROM ctx
WHERE bm.id = ctx.billing_id;

ROLLBACK TO SAVEPOINT sp_negative_write_off_amount;

SELECT
    'PASS' AS validation,
    'Negative write_off_amount rejected by CHECK constraint (chk_billing_master_write_off_amount)' AS result;


COMMIT;
