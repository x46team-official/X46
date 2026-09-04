
BEGIN;

-- 1. INSERT DEDICATED CLINICAL MASTER TEST ROW (idempotent by clinical_code)

WITH ctx AS (
    SELECT
        pr.patient_id,
        pr.organization_id,
        pr.branch_id,
        pr.created_by
    FROM patient_registrations pr
    JOIN organizations o
        ON o.id = pr.organization_id
    WHERE o.organization_code = 'DEMO-LAB 2'
    ORDER BY pr.created_at DESC
    LIMIT 1
)
INSERT INTO clinical_master (
    organization_id,
    branch_id,
    clinical_type,
    clinical_code,
    clinical_name,
    description,
    created_by
)
SELECT
    ctx.organization_id,
    ctx.branch_id,
    'DISEASE',
    'CH-UPD-TEST-001',
    'Dry Run Update Test Disease',
    'Dummy clinical master row for CH008/CH009 dry run',
    ctx.created_by
FROM ctx
WHERE NOT EXISTS (
    SELECT 1
    FROM clinical_master cm
    WHERE cm.organization_id = ctx.organization_id
      AND cm.branch_id = ctx.branch_id
      AND cm.clinical_code = 'CH-UPD-TEST-001'
);


-- 2. LINK TEST ROW TO PATIENT (patient_clinical_history), needed for CH003/CH004

WITH ctx AS (
    SELECT
        pr.id AS registration_id,
        pr.patient_id,
        pr.organization_id,
        pr.branch_id,
        pr.created_by
    FROM patient_registrations pr
    JOIN organizations o
        ON o.id = pr.organization_id
    WHERE o.organization_code = 'DEMO-LAB 2'
    ORDER BY pr.created_at DESC
    LIMIT 1
)
INSERT INTO patient_clinical_history (
    organization_id,
    branch_id,
    patient_id,
    registration_id,
    clinical_id,
    status,
    notes,
    created_by
)
SELECT
    ctx.organization_id,
    ctx.branch_id,
    ctx.patient_id,
    ctx.registration_id,
    cm.id,
    'ACTIVE',
    'Dummy clinical history link for CH003/CH004 dry run',
    ctx.created_by
FROM ctx
JOIN clinical_master cm
    ON cm.organization_id = ctx.organization_id
   AND cm.branch_id = ctx.branch_id
   AND cm.clinical_code = 'CH-UPD-TEST-001'
WHERE NOT EXISTS (
    SELECT 1
    FROM patient_clinical_history pch
    WHERE pch.patient_id = ctx.patient_id
      AND pch.clinical_id = cm.id
);


-- 3. CH008: UPDATE CLINICAL MASTER (rename + description)

WITH ctx AS (
    SELECT o.id AS organization_id
    FROM organizations o
    WHERE o.organization_code = 'DEMO-LAB 2'
)
UPDATE clinical_master cm
SET
    clinical_name = 'Dry Run Update Test Disease - Updated',
    description = 'Updated during CH008 dry run',
    updated_at = CURRENT_TIMESTAMP
FROM ctx
WHERE cm.organization_id = ctx.organization_id
  AND cm.clinical_code = 'CH-UPD-TEST-001';


-- 4. CH009: DEACTIVATE CLINICAL MASTER

WITH ctx AS (
    SELECT o.id AS organization_id
    FROM organizations o
    WHERE o.organization_code = 'DEMO-LAB 2'
)
UPDATE clinical_master cm
SET
    is_active = FALSE,
    updated_at = CURRENT_TIMESTAMP
FROM ctx
WHERE cm.organization_id = ctx.organization_id
  AND cm.clinical_code = 'CH-UPD-TEST-001';


-- 5. CH009: REACTIVATE CLINICAL MASTER
-- Proves the same UPDATE path toggles both directions

WITH ctx AS (
    SELECT o.id AS organization_id
    FROM organizations o
    WHERE o.organization_code = 'DEMO-LAB 2'
)
UPDATE clinical_master cm
SET
    is_active = TRUE,
    updated_at = CURRENT_TIMESTAMP
FROM ctx
WHERE cm.organization_id = ctx.organization_id
  AND cm.clinical_code = 'CH-UPD-TEST-001';


-- 6. CH003: UPDATE CLINICAL HISTORY

WITH ctx AS (
    SELECT
        pr.patient_id,
        o.id AS organization_id
    FROM patient_registrations pr
    JOIN organizations o
        ON o.id = pr.organization_id
    WHERE o.organization_code = 'DEMO-LAB'
    ORDER BY pr.created_at DESC
    LIMIT 1
)
UPDATE patient_clinical_history pch
SET
    status = 'RESOLVED',
    notes = 'Updated during CH003 dry run',
    updated_at = CURRENT_TIMESTAMP
FROM ctx
JOIN clinical_master cm
    ON cm.organization_id = ctx.organization_id
   AND cm.clinical_code = 'CH-UPD-TEST-001'
WHERE pch.patient_id = ctx.patient_id
  AND pch.clinical_id = cm.id;


-- 7. CH004: SOFT-DELETE CLINICAL HISTORY (is_active = FALSE)

WITH ctx AS (
    SELECT
        pr.patient_id,
        o.id AS organization_id
    FROM patient_registrations pr
    JOIN organizations o
        ON o.id = pr.organization_id
    WHERE o.organization_code = 'DEMO-LAB 2'
    ORDER BY pr.created_at DESC
    LIMIT 1
)
UPDATE patient_clinical_history pch
SET
    is_active = FALSE,
    updated_at = CURRENT_TIMESTAMP
FROM ctx
JOIN clinical_master cm
    ON cm.organization_id = ctx.organization_id
   AND cm.clinical_code = 'CH-UPD-TEST-001'
WHERE pch.patient_id = ctx.patient_id
  AND pch.clinical_id = cm.id;


COMMIT;


-- Verification

-- CH008: expect clinical_name = 'Dry Run Update Test Disease - Updated'
SELECT
    cm.clinical_code,
    cm.clinical_name,
    cm.description,
    cm.is_active,
    cm.updated_at
FROM clinical_master cm
WHERE cm.clinical_code = 'CH-UPD-TEST-001';

-- CH009: expect is_active = TRUE (reactivated in step 5)
SELECT
    cm.clinical_code,
    cm.is_active
FROM clinical_master cm
WHERE cm.clinical_code = 'CH-UPD-TEST-001';

-- CH003/CH004: expect status = 'RESOLVED' and is_active = FALSE
SELECT
    p.first_name,
    p.last_name,
    cm.clinical_code,
    pch.status,
    pch.notes,
    pch.is_active,
    pch.updated_at
FROM patient_clinical_history pch
JOIN patients p
    ON p.id = pch.patient_id
JOIN clinical_master cm
    ON cm.id = pch.clinical_id
WHERE cm.clinical_code = 'CH-UPD-TEST-001';
