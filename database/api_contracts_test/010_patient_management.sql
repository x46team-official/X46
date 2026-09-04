-- PATIENT MANAGEMENT API VALIDATION
-- API-T061 to API-T070

-- API-T061: Create Patient

INSERT INTO patients (
    organization_id,
    branch_id,
    patient_code,
    first_name,
    last_name,
    gender,
    date_of_birth,
    created_by
)
SELECT
    o.id,
    b.id,
    'PAT-TEST-001',
    'Rahul',
    'Sharma',
    'MALE',
    '1995-05-10',
    u.id
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
   AND b.branch_code = 'PUNE002'
JOIN users u
    ON u.organization_id = o.id
   AND u.username = 'admin'
WHERE o.organization_code = 'LAB002'
RETURNING *;

-- API-T062: View Patient

SELECT *
FROM patients
WHERE patient_code = 'PAT-TEST-001';

-- API-T063: Invalid Patient ID

SELECT *
FROM patients
WHERE id = '00000000-0000-0000-0000-000000000000';

-- API-T064: Missing First Name

INSERT INTO patients (
    organization_id,
    branch_id,
    patient_code,
    first_name,
    gender
)
SELECT
    organization_id,
    branch_id,
    'PAT-NULL-NAME',
    NULL,
    'MALE'
FROM patients
LIMIT 1;

-- API-T065: Duplicate Patient Code

INSERT INTO patients (
    organization_id,
    branch_id,
    patient_code,
    first_name,
    gender
)
SELECT
    organization_id,
    branch_id,
    patient_code,
    'Duplicate',
    'MALE'
FROM patients
WHERE patient_code = 'PAT-TEST-001';

-- API-T066: Update Patient

UPDATE patients
SET
    first_name = 'Rahul Updated',
    last_name = 'Sharma Updated'
WHERE patient_code = 'PAT-TEST-001'
RETURNING
    id,
    patient_code,
    first_name,
    last_name;

-- API-T067: Search Patient

SELECT
    id,
    patient_code,
    first_name,
    last_name,
    gender
FROM patients
WHERE patient_code ILIKE '%PAT-TEST%'
   OR first_name ILIKE '%Rahul%'
   OR last_name ILIKE '%Sharma%';

-- API-T068: Invalid Organization Scope

SELECT *
FROM patients
WHERE patient_code = 'PAT-TEST-001'
  AND organization_id =
      '00000000-0000-0000-0000-000000000000';

-- API-T069: Deactivate Patient

UPDATE patients
SET is_active = false
WHERE patient_code = 'PAT-TEST-001'
RETURNING
    id,
    patient_code,
    is_active;

-- API-T070: Reactivate Patient

UPDATE patients
SET is_active = true
WHERE patient_code = 'PAT-TEST-001'
RETURNING
    id,
    patient_code,
    is_active;