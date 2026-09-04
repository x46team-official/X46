BEGIN;

SELECT id AS organization_id
FROM organizations
WHERE organization_code = 'LAB002'
\gset
\echo organization_id = :organization_id

SELECT id AS branch_id
FROM branches
WHERE organization_id = :'organization_id'
AND branch_code = 'PUNE002'
\gset
\echo branch_id = :branch_id

SELECT id AS admin_user_id
FROM users
WHERE organization_id = :'organization_id'
AND username = 'admin'
\gset
\echo admin_user_id = :admin_user_id

SELECT id AS patient_id
FROM patients
WHERE first_name = 'Manas'
AND last_name = 'Gaikwad'
ORDER BY created_at DESC
LIMIT 1
\gset
\echo patient_id = :patient_id
--get registration

SELECT id AS registration_id
FROM patient_registrations
WHERE patient_id = :'patient_id'
ORDER BY created_at DESC
LIMIT 1
\gset


--INSERT MASTER DATA

INSERT INTO clinical_master
(
   organization_id,
   branch_id,
    clinical_type,
    clinical_code,
    clinical_name,
    description,
    created_by
)
values
(
  :'organization_id',
  :'branch_id',
  'DISEASE',
  'DIS001',
  'Diabetes Mellitus',
  'type 2 diabetes',
  :'admin_user_id'
)
ON CONFLICT (organization_id, branch_id, clinical_type, clinical_name)
DO NOTHING;

INSERT INTO clinical_master
(
  organization_id,
  branch_id,
  clinical_type,
  clinical_code,
  clinical_name,
  description,
  created_by
)
values
(
  :'organization_id',
  :'branch_id',
  'SYMPTOM',
  'SYM001',
   'Fever',
    'High body temperature',
    :'admin_user_id'
)
ON CONFLICT (organization_id, branch_id, clinical_type, clinical_name)
DO NOTHING;


INSERT INTO clinical_master
(
    organization_id,
   branch_id,
    clinical_type,
    clinical_code,
    clinical_name,
    description,
    created_by
)
VALUES
(
    :'organization_id',
    :'branch_id',
    'ALLERGY',
    'ALG001',
    'Penicillin Allergy',
    'Drug Allergy',
    :'admin_user_id'
)
ON CONFLICT (organization_id, branch_id, clinical_type, clinical_name)
DO NOTHING;

-- PATIENT DIABETES HISTORY
INSERT INTO patient_clinical_history
(
    organization_id,
    branch_id,
    patient_id,
    clinical_id,
    diagnosed_date,
    status,
    notes,
    created_by
)
SELECT
    :'organization_id',
    :'branch_id',
    :'patient_id',
    id,
    DATE '2024-01-10',
    'ACTIVE',
    'Known diabetic patient',
    :'admin_user_id'
FROM clinical_master
WHERE organization_id = :'organization_id'
AND branch_id = :'branch_id'
AND clinical_name = 'Diabetes Mellitus';


INSERT INTO patient_clinical_history
(
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
    :'organization_id',
    :'branch_id',
    :'patient_id',
    :'registration_id',
    id,
    'MODERATE',
    3,
    'DAY',
    'ACTIVE',
    'Fever since last three days',
    :'admin_user_id'
FROM clinical_master
WHERE organization_id = :'organization_id'
AND branch_id = :'branch_id'
AND clinical_name = 'Fever';

INSERT INTO patient_clinical_history
(
    organization_id,
    branch_id,
    patient_id,
    clinical_id,
    status,
    notes,
    created_by
)
SELECT
    :'organization_id',
    :'branch_id',
    :'patient_id',
    id,
    'ACTIVE',
    'Patient allergic to Penicillin',
    :'admin_user_id'
FROM clinical_master
WHERE organization_id = :'organization_id'
AND branch_id = :'branch_id'
AND clinical_name = 'Penicillin Allergy';

commit;

--verification
SELECT *
FROM clinical_master
ORDER BY clinical_type, clinical_name;

SELECT
    p.first_name,
    p.last_name,
    cm.clinical_type,
    cm.clinical_name,
    pch.status,
    pch.severity,
    pch.duration_value,
    pch.duration_unit,
    pch.notes
FROM patient_clinical_history pch
JOIN patients p
    ON p.id = pch.patient_id
JOIN clinical_master cm
    ON cm.id = pch.clinical_id
WHERE p.id = :'patient_id'
ORDER BY cm.clinical_type;

SELECT organization_code, id
FROM organizations;
