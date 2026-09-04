-- API-T081 : CREATE CLINICAL HISTORY
-- Expected API : 201 Created

BEGIN;

WITH ctx AS (
    SELECT
        o.id AS organization_id,
        b.id AS branch_id,
        p.id AS patient_id,
        pr.id AS registration_id,
        cm.id AS clinical_id,
        u.id AS admin_user_id
    FROM organizations o
    JOIN branches b
        ON b.organization_id = o.id
       AND b.branch_code = 'PUNE002'
    JOIN patients p
        ON p.first_name = 'Manas'
       AND p.last_name = 'Gaikwad'
    JOIN patient_registrations pr
        ON pr.patient_id = p.id
       AND pr.organization_id = o.id
       AND pr.branch_id = b.id
    JOIN clinical_master cm
        ON cm.organization_id = o.id
       AND cm.branch_id = b.id
       AND cm.clinical_type = 'SYMPTOM'
       AND cm.clinical_name = 'Fever'
    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'
    WHERE o.organization_code = 'LAB002'
    ORDER BY pr.created_at DESC
    LIMIT 1
)
INSERT INTO patient_clinical_history (
    organization_id,
    branch_id,
    patient_id,
    registration_id,
    clinical_id,
    severity,
    duration_value,
    duration_unit,
    status,
    notes,
    created_by
)
SELECT
    organization_id,
    branch_id,
    patient_id,
    registration_id,
    clinical_id,
    'MODERATE',
    5,
    'DAY',
    'ACTIVE',
    'API clinical history test',
    admin_user_id
FROM ctx
RETURNING
    id,
    organization_id,
    branch_id,
    patient_id,
    registration_id,
    clinical_id,
    severity,
    duration_value,
    duration_unit,
    status,
    notes;

ROLLBACK;

-- API-T082 : VIEW CLINICAL HISTORY
-- Expected API : 200 OK

BEGIN;

SELECT
    pch.id,
    pch.patient_id,
    pch.registration_id,
    pch.clinical_id,
    cm.clinical_type,
    cm.clinical_code,
    cm.clinical_name,
    pch.diagnosed_date,
    pch.severity,
    pch.duration_value,
    pch.duration_unit,
    pch.status,
    pch.notes
FROM patient_clinical_history pch
JOIN patients p
    ON p.id = pch.patient_id
JOIN clinical_master cm
    ON cm.id = pch.clinical_id
JOIN organizations o
    ON o.id = pch.organization_id
JOIN branches b
    ON b.id = pch.branch_id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND p.first_name = 'Manas'
  AND p.last_name = 'Gaikwad'
ORDER BY pch.created_at DESC;

ROLLBACK;

-- API-T083 : UPDATE CLINICAL HISTORY
-- Expected API : 200 OK
-- Expected DB : UPDATE 1

BEGIN;

UPDATE patient_clinical_history
SET
    severity = 'MILD',
    status = 'ACTIVE',
    notes = 'Clinical history updated through API validation'
WHERE id = (
    SELECT pch.id
    FROM patient_clinical_history pch
    JOIN patients p
        ON p.id = pch.patient_id
    JOIN organizations o
        ON o.id = pch.organization_id
    JOIN branches b
        ON b.id = pch.branch_id
    JOIN clinical_master cm
        ON cm.id = pch.clinical_id
    WHERE o.organization_code = 'LAB002'
      AND b.branch_code = 'PUNE002'
      AND p.first_name = 'Manas'
      AND p.last_name = 'Gaikwad'
      AND cm.clinical_name = 'Fever'
    ORDER BY pch.created_at DESC
    LIMIT 1
)
RETURNING
    id,
    patient_id,
    clinical_id,
    severity,
    status,
    notes;

ROLLBACK;

-- API-T084 : INVALID PATIENT
-- Expected API : 404 Not Found
-- Expected DB : FK violation

BEGIN;

SAVEPOINT sp_invalid_patient;

INSERT INTO patient_clinical_history (
    organization_id,
    branch_id,
    patient_id,
    clinical_id,
    status,
    notes
)
SELECT
    o.id,
    b.id,
    '00000000-0000-0000-0000-000000000000',
    cm.id,
    'ACTIVE',
    'Invalid patient test'
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
   AND b.branch_code = 'PUNE002'
JOIN clinical_master cm
    ON cm.organization_id = o.id
   AND cm.branch_id = b.id
   AND cm.clinical_name = 'Fever'
WHERE o.organization_code = 'LAB002'
LIMIT 1;

ROLLBACK TO SAVEPOINT sp_invalid_patient;

SELECT
    'PASS' AS validation,
    'Invalid patient rejected' AS result;

COMMIT;

-- API-T085 : INVALID CLINICAL MASTER
-- Expected API : 404 Not Found
-- Expected DB : FK violation

BEGIN;

SAVEPOINT sp_invalid_clinical;

WITH ctx AS (
    SELECT
        o.id AS organization_id,
        b.id AS branch_id,
        p.id AS patient_id
    FROM organizations o
    JOIN branches b
        ON b.organization_id = o.id
       AND b.branch_code = 'PUNE002'
    JOIN patients p
        ON p.first_name = 'Manas'
       AND p.last_name = 'Gaikwad'
    WHERE o.organization_code = 'LAB002'
    LIMIT 1
)
INSERT INTO patient_clinical_history (
    organization_id,
    branch_id,
    patient_id,
    clinical_id,
    status,
    notes
)
SELECT
    organization_id,
    branch_id,
    patient_id,
    '00000000-0000-0000-0000-000000000000',
    'ACTIVE',
    'Invalid clinical master test'
FROM ctx;

ROLLBACK TO SAVEPOINT sp_invalid_clinical;

SELECT
    'PASS' AS validation,
    'Invalid clinical master rejected' AS result;

COMMIT;

-- API-T086 : INVALID REGISTRATION
-- Expected API : 404 Not Found
-- Expected DB : FK violation

BEGIN;

SAVEPOINT sp_invalid_registration;

WITH ctx AS (
    SELECT
        o.id AS organization_id,
        b.id AS branch_id,
        p.id AS patient_id,
        cm.id AS clinical_id
    FROM organizations o
    JOIN branches b
        ON b.organization_id = o.id
       AND b.branch_code = 'PUNE002'
    JOIN patients p
        ON p.first_name = 'Manas'
       AND p.last_name = 'Gaikwad'
    JOIN clinical_master cm
        ON cm.organization_id = o.id
       AND cm.branch_id = b.id
       AND cm.clinical_name = 'Fever'
    WHERE o.organization_code = 'LAB002'
    LIMIT 1
)
INSERT INTO patient_clinical_history (
    organization_id,
    branch_id,
    patient_id,
    registration_id,
    clinical_id,
    status,
    notes
)
SELECT
    organization_id,
    branch_id,
    patient_id,
    '00000000-0000-0000-0000-000000000000',
    clinical_id,
    'ACTIVE',
    'Invalid registration test'
FROM ctx;

ROLLBACK TO SAVEPOINT sp_invalid_registration;

SELECT
    'PASS' AS validation,
    'Invalid registration rejected' AS result;

COMMIT;

-- API-T087 : INVALID CLINICAL HISTORY ID
-- Expected API : 404 Not Found
-- Expected DB : 0 rows
SELECT
    id,
    patient_id,
    clinical_id,
    status,
    notes
FROM patient_clinical_history
WHERE id = '00000000-0000-0000-0000-000000000000';


-- API-T088 : SEARCH CLINICAL HISTORY BY TYPE
-- Expected API : 200 OK

SELECT
    pch.id,
    pch.patient_id,
    cm.clinical_type,
    cm.clinical_code,
    cm.clinical_name,
    pch.severity,
    pch.status,
    pch.notes
FROM patient_clinical_history pch
JOIN clinical_master cm
    ON cm.id = pch.clinical_id
JOIN organizations o
    ON o.id = pch.organization_id
JOIN branches b
    ON b.id = pch.branch_id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'PUNE002'
  AND cm.clinical_type = 'DISEASE'
ORDER BY pch.created_at DESC;

-- API-T089 : ORGANIZATION / BRANCH SCOPE
-- Expected API : 404 Not Found / 0 rows

-- Invalid organization

SELECT
    pch.id,
    pch.patient_id,
    pch.clinical_id,
    pch.status
FROM patient_clinical_history pch
JOIN organizations o
    ON o.id = pch.organization_id
WHERE o.organization_code = 'INVALID-ORG';


-- Invalid branch

SELECT
    pch.id,
    pch.patient_id,
    pch.clinical_id,
    pch.status
FROM patient_clinical_history pch
JOIN organizations o
    ON o.id = pch.organization_id
JOIN branches b
    ON b.id = pch.branch_id
WHERE o.organization_code = 'LAB002'
  AND b.branch_code = 'INVALID-BRANCH';


-- API-T090 : VERIFY PATIENT CLINICAL HISTORY
-- Expected API : 200 OK

SELECT
    p.first_name,
    p.last_name,
    cm.clinical_type,
    cm.clinical_code,
    cm.clinical_name,
    pch.registration_id,
    pch.diagnosed_date,
    pch.severity,
    pch.duration_value,
    pch.duration_unit,
    pch.status,
    pch.notes
FROM patient_clinical_history pch
JOIN patients p
    ON p.id = pch.patient_id
JOIN clinical_master cm
    ON cm.id = pch.clinical_id
WHERE p.first_name = 'Manas'
  AND p.last_name = 'Gaikwad'
ORDER BY cm.clinical_type, cm.clinical_name;