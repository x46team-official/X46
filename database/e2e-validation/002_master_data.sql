BEGIN;

SELECT id AS organization_id
FROM organizations
WHERE organization_code = 'LAB002'
\gset

SELECT id AS branch_id
FROM branches
WHERE organization_id = :'organization_id'
  AND branch_code = 'PUNE002'
\gset

SELECT id as admin_user_id
from users
where organization_id =:'organization_id'
and username='admin'
\gset

INSERT INTO department_master
(
    organization_id,
    branch_id,
    department_name,
    department_code,
    description,
    is_active,
    created_by
)
VALUES
(
    :'organization_id',
    :'branch_id',
    'Hematology',
    'HEM',
    'Hematology Department',
    TRUE,
    :'admin_user_id'
),
(
    :'organization_id',
    :'branch_id',
    'Biochemistry',
    'BIO',
    'Biochemistry Department',
    TRUE,
    :'admin_user_id'
),
(
    :'organization_id',
    :'branch_id',
    'Microbiology',
    'MIC',
    'Microbiology Department',
    TRUE,
    :'admin_user_id'
),
(
    :'organization_id',
    :'branch_id',
    'Serology',
    'SER',
    'Serology Department',
    TRUE,
    :'admin_user_id'
),
(
    :'organization_id',
    :'branch_id',
    'Histopathology',
    'HIS',
    'Histopathology Department',
    TRUE,
    :'admin_user_id'
)
ON CONFLICT (organization_id, branch_id, department_name)
DO NOTHING;

-- MD002: View Department (retrieve by code)
SELECT department_code, department_name, is_active
FROM department_master
WHERE organization_id = :'organization_id'
  AND branch_id = :'branch_id'
  AND department_code = 'HEM';

-- MD003: Update Department
UPDATE department_master
SET department_name = 'Hematology Dept',
    description = 'Updated Hematology Department',
    updated_by = :'admin_user_id',
    updated_at = CURRENT_TIMESTAMP
WHERE organization_id = :'organization_id'
  AND branch_id = :'branch_id'
  AND department_code = 'HEM';

SELECT department_code, department_name, description
FROM department_master
WHERE organization_id = :'organization_id'
  AND branch_id = :'branch_id'
  AND department_code = 'HEM';

-- MD004: Activate/Deactivate Department
UPDATE department_master
SET is_active = FALSE,
    updated_by = :'admin_user_id',
    updated_at = CURRENT_TIMESTAMP
WHERE organization_id = :'organization_id'
  AND branch_id = :'branch_id'
  AND department_code = 'SER';

SELECT department_code, is_active
FROM department_master
WHERE organization_id = :'organization_id'
  AND branch_id = :'branch_id'
  AND department_code = 'SER';

UPDATE department_master
SET is_active = TRUE,
    updated_by = :'admin_user_id',
    updated_at = CURRENT_TIMESTAMP
WHERE organization_id = :'organization_id'
  AND branch_id = :'branch_id'
  AND department_code = 'SER';

-- MD005: Prevent Duplicate Department Code (same code, different name -> must be rejected)
SAVEPOINT sp_duplicate_department_code;

INSERT INTO department_master
(
    organization_id,
    branch_id,
    department_name,
    department_code,
    description,
    is_active,
    created_by
)
VALUES
(
    :'organization_id',
    :'branch_id',
    'Hematology Duplicate',
    'HEM',
    'Should be rejected - duplicate department_code',
    TRUE,
    :'admin_user_id'
);

ROLLBACK TO SAVEPOINT sp_duplicate_department_code;

-- Verify duplicate was rejected (still exactly one HEM row)
SELECT department_code, COUNT(*)
FROM department_master
WHERE organization_id = :'organization_id'
  AND branch_id = :'branch_id'
  AND department_code = 'HEM'
GROUP BY department_code;

-- PARAMETER MASTER

INSERT INTO parameter_master
(
    organization_id,
    branch_id,
    parameter_code,
    parameter_name,
    unit,
    default_reference_range,
    created_by
)
VALUES
(:'organization_id',:'branch_id','HGB','Hemoglobin','g/dL','13.0 - 17.0',:'admin_user_id'),
(:'organization_id',:'branch_id','WBC','White Blood Cell','10^3/uL','4.0 - 11.0',:'admin_user_id'),
(:'organization_id',:'branch_id','RBC','Red Blood Cell','10^6/uL','4.5 - 5.9',:'admin_user_id'),
(:'organization_id',:'branch_id','HCT','Hematocrit','%','40 - 50',:'admin_user_id'),
(:'organization_id',:'branch_id','PLT','Platelet Count','10^3/uL','150 - 450',:'admin_user_id'),
(:'organization_id',:'branch_id','MCV','Mean Corpuscular Volume','fL','80 - 100',:'admin_user_id'),
(:'organization_id',:'branch_id','MCH','Mean Corpuscular Hemoglobin','pg','27 - 33',:'admin_user_id'),
(:'organization_id',:'branch_id','MCHC','Mean Corpuscular Hemoglobin Concentration','g/dL','32 - 36',:'admin_user_id')
ON CONFLICT (organization_id, branch_id, parameter_code)
DO NOTHING;

-- BILLING CATEGORY


INSERT INTO billing_category_master
(
    organization_id,
    branch_id,
    billing_category_code,
    billing_category_name,
    description,
    is_default,
    created_by
)
VALUES
(:'organization_id',:'branch_id','PATH','Pathology','Laboratory Tests',TRUE,:'admin_user_id'),
(:'organization_id',:'branch_id','RAD','Radiology','Radiology Services',FALSE,:'admin_user_id'),
(:'organization_id',:'branch_id','CONS','Consultation','Doctor Consultation',FALSE,:'admin_user_id'),
(:'organization_id',:'branch_id','PKG','Package','Health Packages',FALSE,:'admin_user_id')
ON CONFLICT (organization_id,branch_id,billing_category_code)
DO NOTHING;

-- MD007: View Billing Category (retrieve by code)
SELECT billing_category_code, billing_category_name, is_active
FROM billing_category_master
WHERE organization_id = :'organization_id'
  AND branch_id = :'branch_id'
  AND billing_category_code = 'PATH';

-- MD008: Update Billing Category
UPDATE billing_category_master
SET billing_category_name = 'Pathology Services',
    updated_by = :'admin_user_id',
    updated_at = CURRENT_TIMESTAMP
WHERE organization_id = :'organization_id'
  AND branch_id = :'branch_id'
  AND billing_category_code = 'PATH';

SELECT billing_category_code, billing_category_name
FROM billing_category_master
WHERE organization_id = :'organization_id'
  AND branch_id = :'branch_id'
  AND billing_category_code = 'PATH';

-- MD009: Activate/Deactivate Billing Category
UPDATE billing_category_master
SET is_active = FALSE,
    updated_by = :'admin_user_id',
    updated_at = CURRENT_TIMESTAMP
WHERE organization_id = :'organization_id'
  AND branch_id = :'branch_id'
  AND billing_category_code = 'RAD';

SELECT billing_category_code, is_active
FROM billing_category_master
WHERE organization_id = :'organization_id'
  AND branch_id = :'branch_id'
  AND billing_category_code = 'RAD';

UPDATE billing_category_master
SET is_active = TRUE,
    updated_by = :'admin_user_id',
    updated_at = CURRENT_TIMESTAMP
WHERE organization_id = :'organization_id'
  AND branch_id = :'branch_id'
  AND billing_category_code = 'RAD';

-- MD010: Prevent Duplicate Category Code (same code, different name -> must be rejected)
SAVEPOINT sp_duplicate_billing_category_code;

INSERT INTO billing_category_master
(
    organization_id,
    branch_id,
    billing_category_code,
    billing_category_name,
    description,
    is_default,
    created_by
)
VALUES
(
    :'organization_id',
    :'branch_id',
    'PATH',
    'Pathology Duplicate',
    'Should be rejected - duplicate billing_category_code',
    FALSE,
    :'admin_user_id'
);

ROLLBACK TO SAVEPOINT sp_duplicate_billing_category_code;

SELECT billing_category_code, COUNT(*)
FROM billing_category_master
WHERE organization_id = :'organization_id'
  AND branch_id = :'branch_id'
  AND billing_category_code = 'PATH'
GROUP BY billing_category_code;


INSERT INTO container_type_master
(
    organization_id,
    branch_id,
    container_name,
    description,
    is_active,
    created_by
)
VALUES
(:'organization_id',:'branch_id','Lavender Top','EDTA Tube',TRUE,:'admin_user_id'),
(:'organization_id',:'branch_id','Red Top','Plain Tube',TRUE,:'admin_user_id'),
(:'organization_id',:'branch_id','Yellow Top','Gel Separator Tube',TRUE,:'admin_user_id'),
(:'organization_id',:'branch_id','Blue Top','Sodium Citrate Tube',TRUE,:'admin_user_id'),
(:'organization_id',:'branch_id','Grey Top','Fluoride Tube',TRUE,:'admin_user_id')
ON CONFLICT (organization_id,branch_id,container_name)
DO NOTHING;

-- MD012: View Container Type (retrieve by name)
SELECT container_name, description, is_active
FROM container_type_master
WHERE organization_id = :'organization_id'
  AND branch_id = :'branch_id'
  AND container_name = 'Lavender Top';

-- MD013: Update Container Type
UPDATE container_type_master
SET description = 'EDTA Tube - Updated',
    updated_by = :'admin_user_id',
    updated_at = CURRENT_TIMESTAMP
WHERE organization_id = :'organization_id'
  AND branch_id = :'branch_id'
  AND container_name = 'Lavender Top';

SELECT container_name, description
FROM container_type_master
WHERE organization_id = :'organization_id'
  AND branch_id = :'branch_id'
  AND container_name = 'Lavender Top';

-- MD014: Activate/Deactivate Container Type
UPDATE container_type_master
SET is_active = FALSE,
    updated_by = :'admin_user_id',
    updated_at = CURRENT_TIMESTAMP
WHERE organization_id = :'organization_id'
  AND branch_id = :'branch_id'
  AND container_name = 'Grey Top';

SELECT container_name, is_active
FROM container_type_master
WHERE organization_id = :'organization_id'
  AND branch_id = :'branch_id'
  AND container_name = 'Grey Top';

UPDATE container_type_master
SET is_active = TRUE,
    updated_by = :'admin_user_id',
    updated_at = CURRENT_TIMESTAMP
WHERE organization_id = :'organization_id'
  AND branch_id = :'branch_id'
  AND container_name = 'Grey Top';

-- MD015: Prevent Duplicate Container Name
SAVEPOINT sp_duplicate_container_name;

INSERT INTO container_type_master
(
    organization_id,
    branch_id,
    container_name,
    description,
    is_active,
    created_by
)
VALUES
(
    :'organization_id',
    :'branch_id',
    'Lavender Top',
    'Should be rejected - duplicate container_name',
    TRUE,
    :'admin_user_id'
);

ROLLBACK TO SAVEPOINT sp_duplicate_container_name;

SELECT container_name, COUNT(*)
FROM container_type_master
WHERE organization_id = :'organization_id'
  AND branch_id = :'branch_id'
  AND container_name = 'Lavender Top'
GROUP BY container_name;



-- SAMPLE TYPE MASTER


INSERT INTO sample_type_master
(
    organization_id,
    branch_id,
    sample_code,
    sample_name,
    print_name,
    description,
    container_type,
    container_color,
    minimum_volume,
    volume_unit,
    storage_temperature,
    is_active,
    created_by
)
VALUES
(:'organization_id',:'branch_id','WB','Whole Blood','Whole Blood',
'Whole Blood Sample','Lavender Top','Purple',2,'mL','2-8°C',TRUE,:'admin_user_id'),

(:'organization_id',:'branch_id','SER','Serum','Serum',
'Serum Sample','Yellow Top','Yellow',2,'mL','2-8°C',TRUE,:'admin_user_id'),

(:'organization_id',:'branch_id','PLA','Plasma','Plasma',
'Plasma Sample','Blue Top','Blue',2,'mL','2-8°C',TRUE,:'admin_user_id'),

(:'organization_id',:'branch_id','URN','Urine','Urine',
'Urine Sample','Sterile Container','Transparent',10,'mL','Room Temperature',TRUE,:'admin_user_id')

ON CONFLICT (organization_id,branch_id,sample_code)
DO NOTHING;

-- PERFORMING LAB MASTER

INSERT INTO performing_lab_master
(
    organization_id,
    branch_id,
    lab_code,
    lab_name,
    legal_name,
    city,
    state,
    country,
    lab_type,
    is_default,
    is_result_lab,
    is_active,
    created_by
)
VALUES
(
:'organization_id',
:'branch_id',
'MAIN',
'Main Laboratory',
'Main Laboratory',
'Pune',
'Maharashtra',
'India',
'Private',
TRUE,
TRUE,
TRUE,
:'admin_user_id'
)
ON CONFLICT (organization_id,branch_id,lab_code)
DO NOTHING;



-- TEST CATEGORY MASTER


INSERT INTO test_category_master
(
    organization_id,
    branch_id,
    category_code,
    category_name,
    description,
    display_order,
    is_active,
    created_by
)
VALUES
(:'organization_id',:'branch_id','HEM','Hematology','Hematology Tests',1,TRUE,:'admin_user_id'),
(:'organization_id',:'branch_id','BIO','Biochemistry','Biochemistry Tests',2,TRUE,:'admin_user_id'),
(:'organization_id',:'branch_id','IMM','Immunology','Immunology Tests',3,TRUE,:'admin_user_id'),
(:'organization_id',:'branch_id','SER','Serology','Serology Tests',4,TRUE,:'admin_user_id'),
(:'organization_id',:'branch_id','MIC','Microbiology','Microbiology Tests',5,TRUE,:'admin_user_id')
ON CONFLICT (organization_id,branch_id,category_code)
DO NOTHING;

-- Test Master
INSERT INTO test_master
(
    organization_id,
    branch_id,
    department_id,
    test_category_id,
    billing_category_id,
    sample_type_id,
    performing_lab_id,
    test_code,
    test_name,
    display_name,
    print_name,
    short_code,
    selling_price,
    cost_price,
    cprr,
    test_type,
    tat_minutes,
    is_active,
    created_by
)
SELECT
    o.id,
    :'branch_id',
    d.id,
    tc.id,
    bc.id,
    st.id,
    pl.id,
    'CBC001',
    'Complete Blood Count',
    'Complete Blood Count',
    'Complete Blood Count',
    'CBC',
    350,
    200,
    0,
    'LAB',
    60,
    TRUE,
    :'admin_user_id'
FROM organizations o
JOIN department_master d
    ON d.organization_id = o.id
   AND d.branch_id = :'branch_id'
   AND d.department_code = 'HEM'
JOIN test_category_master tc
    ON tc.organization_id = o.id
   AND tc.branch_id = :'branch_id'
   AND tc.category_code = 'HEM'
JOIN billing_category_master bc
    ON bc.organization_id = o.id
   AND bc.branch_id = :'branch_id'
   AND bc.billing_category_code = 'PATH'
JOIN sample_type_master st
    ON st.organization_id = o.id
   AND st.branch_id = :'branch_id'
   AND st.sample_code = 'WB'
JOIN performing_lab_master pl
    ON pl.organization_id = o.id
   AND pl.branch_id = :'branch_id'
   AND pl.lab_code = 'MAIN'
WHERE o.organization_code = 'LAB002'
ON CONFLICT (organization_id, branch_id, test_code)
DO NOTHING;

-- TEST PARAMETER MAPPING

INSERT INTO test_parameter_mapping
(
    organization_id,
    branch_id,
    test_id,
    parameter_id,
    display_order,
    unit,
    reference_range,
    is_mandatory,
    created_by
)
SELECT
    o.id,
    :'branch_id',
    tm.id,
    pm.id,
    CASE pm.parameter_code
        WHEN 'HGB' THEN 1
        WHEN 'WBC' THEN 2
        WHEN 'RBC' THEN 3
        WHEN 'HCT' THEN 4
        WHEN 'PLT' THEN 5
        WHEN 'MCV' THEN 6
        WHEN 'MCH' THEN 7
        WHEN 'MCHC' THEN 8
    END,
    pm.unit,
    pm.default_reference_range,
    TRUE,
    :'admin_user_id'
FROM organizations o
JOIN test_master tm
    ON tm.organization_id = o.id
   AND tm.branch_id = :'branch_id'
   AND tm.test_code = 'CBC001'
JOIN parameter_master pm
    ON pm.organization_id = o.id
   AND pm.branch_id = :'branch_id'
WHERE o.organization_code = 'LAB002'
ON CONFLICT (organization_id, branch_id, test_id, parameter_id)
DO NOTHING;

COMMIT;


SELECT department_code, department_name
FROM department_master
ORDER BY department_code;

SELECT billing_category_code, billing_category_name
FROM billing_category_master
ORDER BY billing_category_code;

SELECT parameter_code, parameter_name
FROM parameter_master
ORDER BY parameter_code;

SELECT
    tm.test_code,
    pm.parameter_code,
    pm.parameter_name
FROM test_parameter_mapping tpm
JOIN test_master tm ON tm.id = tpm.test_id
JOIN parameter_master pm ON pm.id = tpm.parameter_id
ORDER BY tpm.display_order;
