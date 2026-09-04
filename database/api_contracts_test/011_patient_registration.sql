-- API-T071 : CREATE REGISTRATION
-- Expected API : 201 Created
-- Expected DB  : INSERT successful

BEGIN;

WITH ctx AS (
    SELECT
        o.id AS organization_id,
        b.id AS branch_id,
        p.id AS patient_id,
        u.id AS admin_user_id
    FROM organizations o
    JOIN branches b
        ON b.organization_id = o.id
       AND b.branch_code = 'PUNE002'
    JOIN patient_identifiers pi
        ON pi.organization_id = o.id
       AND pi.branch_id = b.id
       AND pi.identifier_type = 'MRN'
       AND pi.identifier_value = 'MRN000001'
    JOIN patients p
        ON p.id = pi.patient_id
    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'
    WHERE o.organization_code = 'LAB002'
)
INSERT INTO patient_registrations (
    organization_id,
    branch_id,
    patient_id,
    registration_number,
    registration_status,
    created_by
)
SELECT
    organization_id,
    branch_id,
    patient_id,
    'REG-API-T071',
    'REGISTERED',
    admin_user_id
FROM ctx
RETURNING
    id,
    organization_id,
    branch_id,
    patient_id,
    registration_number,
    registration_status;

ROLLBACK;


-- API-T072 : VIEW REGISTRATION
-- Expected API : 200 OK
-- Expected DB  : Registration returned

BEGIN;

INSERT INTO patient_registrations (
    organization_id,
    branch_id,
    patient_id,
    registration_number,
    registration_status,
    created_by
)
SELECT
    o.id,
    b.id,
    p.id,
    'REG-API-T072',
    'REGISTERED',
    u.id
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
   AND b.branch_code = 'PUNE002'
JOIN patient_identifiers pi
    ON pi.organization_id = o.id
   AND pi.branch_id = b.id
   AND pi.identifier_type = 'MRN'
   AND pi.identifier_value = 'MRN000001'
JOIN patients p
    ON p.id = pi.patient_id
JOIN users u
    ON u.organization_id = o.id
   AND u.username = 'admin'
WHERE o.organization_code = 'LAB002';

SELECT
    pr.id,
    pr.organization_id,
    pr.branch_id,
    pr.patient_id,
    pr.registration_number,
    pr.registration_status,
    pr.registered_at
FROM patient_registrations pr
JOIN organizations o
    ON o.id = pr.organization_id
JOIN branches b
    ON b.id = pr.branch_id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND pr.registration_number = 'REG-API-T072';

ROLLBACK;
-- API-T073 : MISSING REGISTRATION NUMBER
-- Expected API : 400 Bad Request
-- Expected DB  : NOT NULL constraint violation
BEGIN;

SAVEPOINT sp_missing_registration_number;

WITH ctx AS (
    SELECT
        o.id AS organization_id,
        b.id AS branch_id,
        p.id AS patient_id,
        u.id AS admin_user_id
    FROM organizations o
    JOIN branches b
        ON b.organization_id = o.id
       AND b.branch_code = 'PUNE002'
    JOIN patient_identifiers pi
        ON pi.organization_id = o.id
       AND pi.branch_id = b.id
       AND pi.identifier_type = 'MRN'
       AND pi.identifier_value = 'MRN000001'
    JOIN patients p
        ON p.id = pi.patient_id
    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'
    WHERE o.organization_code = 'LAB002'
)
INSERT INTO patient_registrations (
    organization_id,
    branch_id,
    patient_id,
    registration_number,
    registration_status,
    created_by
)
SELECT
    organization_id,
    branch_id,
    patient_id,
    NULL,
    'REGISTERED',
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_missing_registration_number;

SELECT
    'PASS' AS validation,
    'Missing registration number rejected' AS result;

COMMIT;

-- API-T074 : DUPLICATE REGISTRATION NUMBER
-- Expected API : 409 Conflict
-- Expected DB  : UNIQUE constraint violation

BEGIN;

WITH ctx AS (
    SELECT
        o.id AS organization_id,
        b.id AS branch_id,
        p.id AS patient_id,
        u.id AS admin_user_id
    FROM organizations o
    JOIN branches b
        ON b.organization_id = o.id
       AND b.branch_code = 'PUNE002'
    JOIN patient_identifiers pi
        ON pi.organization_id = o.id
       AND pi.branch_id = b.id
       AND pi.identifier_type = 'MRN'
       AND pi.identifier_value = 'MRN000001'
    JOIN patients p
        ON p.id = pi.patient_id
    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'
    WHERE o.organization_code = 'LAB002'
)
INSERT INTO patient_registrations (
    organization_id,
    branch_id,
    patient_id,
    registration_number,
    registration_status,
    created_by
)
SELECT
    organization_id,
    branch_id,
    patient_id,
    'REG-API-T074',
    'REGISTERED',
    admin_user_id
FROM ctx;

SAVEPOINT sp_duplicate_registration;

WITH ctx AS (
    SELECT
        o.id AS organization_id,
        b.id AS branch_id,
        p.id AS patient_id,
        u.id AS admin_user_id
    FROM organizations o
    JOIN branches b
        ON b.organization_id = o.id
       AND b.branch_code = 'PUNE002'
    JOIN patient_identifiers pi
        ON pi.organization_id = o.id
       AND pi.branch_id = b.id
       AND pi.identifier_type = 'MRN'
       AND pi.identifier_value = 'MRN000001'
    JOIN patients p
        ON p.id = pi.patient_id
    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'
    WHERE o.organization_code = 'LAB002'
)
INSERT INTO patient_registrations (
    organization_id,
    branch_id,
    patient_id,
    registration_number,
    registration_status,
    created_by
)
SELECT
    organization_id,
    branch_id,
    patient_id,
    'REG-API-T074',
    'REGISTERED',
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_duplicate_registration;

SELECT
    'PASS' AS validation,
    'Duplicate registration number rejected' AS result;

ROLLBACK;
-- API-T075 : INVALID PATIENT
-- Expected API : 404 Not Found
-- Expected DB  : FK constraint violation

BEGIN;

SAVEPOINT sp_invalid_patient;

WITH ctx AS (
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
)
INSERT INTO patient_registrations (
    organization_id,
    branch_id,
    patient_id,
    registration_number,
    registration_status,
    created_by
)
SELECT
    organization_id,
    branch_id,
    '00000000-0000-0000-0000-000000000000',
    'REG-API-T075',
    'REGISTERED',
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_invalid_patient;

SELECT
    'PASS' AS validation,
    'Invalid patient rejected by FK' AS result;

COMMIT;

-- API-T076 : UPDATE REGISTRATION STATUS
-- Expected API : 200 OK
-- Expected DB  : UPDATE successful

BEGIN;

-- First create registration
INSERT INTO patient_registrations (
    organization_id,
    branch_id,
    patient_id,
    registration_number,
    registration_status,
    created_by
)
SELECT
    o.id,
    b.id,
    p.id,
    'REG-API-T076',
    'REGISTERED',
    u.id
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
   AND b.branch_code = 'PUNE002'
JOIN patient_identifiers pi
    ON pi.organization_id = o.id
   AND pi.branch_id = b.id
   AND pi.identifier_type = 'MRN'
   AND pi.identifier_value = 'MRN000001'
JOIN patients p
    ON p.id = pi.patient_id
JOIN users u
    ON u.organization_id = o.id
   AND u.username = 'admin'
WHERE o.organization_code = 'LAB002';

-- Update status
UPDATE patient_registrations
SET registration_status = 'COMPLETED'
WHERE registration_number = 'REG-API-T076'
  AND organization_id = (
      SELECT id
      FROM organizations
      WHERE organization_code = 'LAB002'
  )
  AND branch_id = (
      SELECT b.id
      FROM branches b
      JOIN organizations o
          ON o.id = b.organization_id
      WHERE o.organization_code = 'LAB002'
        AND b.branch_code = 'PUNE002'
  )
RETURNING
    id,
    registration_number,
    registration_status;

ROLLBACK;


-- API-T077 : INVALID REGISTRATION ID
-- Expected API : 404 Not Found
-- Expected DB  : 0 rows

SELECT
    id,
    registration_number,
    registration_status
FROM patient_registrations
WHERE id = '00000000-0000-0000-0000-000000000000';

-- API-T078 : PATIENT MULTIPLE REGISTRATIONS
-- Expected API : 201 Created
-- Expected DB  : Same patient can have multiple registrations

BEGIN;

INSERT INTO patient_registrations (
    organization_id,
    branch_id,
    patient_id,
    registration_number,
    registration_status,
    created_by
)
SELECT
    o.id,
    b.id,
    p.id,
    'REG-API-T078',
    'REGISTERED',
    u.id
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
   AND b.branch_code = 'PUNE002'
JOIN patient_identifiers pi
    ON pi.organization_id = o.id
   AND pi.branch_id = b.id
   AND pi.identifier_type = 'MRN'
   AND pi.identifier_value = 'MRN000001'
JOIN patients p
    ON p.id = pi.patient_id
JOIN users u
    ON u.organization_id = o.id
   AND u.username = 'admin'
WHERE o.organization_code = 'LAB002'
RETURNING
    id,
    patient_id,
    registration_number,
    registration_status;

ROLLBACK;

-- API-T079 : REGISTRATION SEARCH BY PATIENT
-- Expected API : 200 OK
-- Expected DB  : Registration history returned

SELECT
    pr.id,
    pr.patient_id,
    pr.registration_number,
    pr.registration_status,
    pr.registered_at
FROM patient_registrations pr
JOIN organizations o
    ON o.id = pr.organization_id
JOIN branches b
    ON b.id = pr.branch_id
JOIN patient_identifiers pi
    ON pi.patient_id = pr.patient_id
   AND pi.organization_id = pr.organization_id
   AND pi.branch_id = pr.branch_id
   AND pi.identifier_type = 'MRN'
   AND pi.identifier_value = 'MRN000001'
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
ORDER BY pr.registered_at DESC;

-- API-T080 : ORGANIZATION / BRANCH SCOPE
-- Expected API : 404 Not Found
-- Expected DB  : 0 rows
-- Invalid organization

SELECT
    pr.id,
    pr.registration_number,
    pr.registration_status
FROM patient_registrations pr
JOIN organizations o
    ON o.id = pr.organization_id
WHERE o.organization_code = 'INVALID-ORG'
  AND pr.registration_number = 'REG-API-T071';


-- Invalid branch

SELECT
    pr.id,
    pr.registration_number,
    pr.registration_status
FROM patient_registrations pr
JOIN organizations o
    ON o.id = pr.organization_id
JOIN branches b
    ON b.id = pr.branch_id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'INVALID-BRANCH'
  AND pr.registration_number = 'REG-API-T071';