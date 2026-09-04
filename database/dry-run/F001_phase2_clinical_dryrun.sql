
-- F001 PATIENT REGISTRATION - PHASE 2 DRY RUN
-- Clinical History: Disease, Symptom, Condition
--
-- NOTE: Rewritten against the CURRENT schema (database/schema/003_patient_clinical_data.sql).
-- The previous version of this file targeted disease_master, patient_diseases,
-- symptom_master, registration_symptoms, medical_condition_master and
-- patient_medical_conditions. None of those tables exist anymore -- they were
-- replaced by the generic clinical_master (clinical_type = DISEASE/SYMPTOM/
-- ALLERGY/CONDITION) + patient_clinical_history pair.
--
-- registration_clinical_history (free-text clinical notes on a registration)
-- also no longer exists in the current schema and has no replacement table.
-- That section has been removed rather than invented -- reporting it here as
-- requested: if free-text clinical history capture is still required, a new
-- table/column needs to be added to the schema first.


BEGIN;

-- 1. SHOW AVAILABLE DUMMY CONTEXT

SELECT
    p.id AS patient_id,
    p.first_name,
    p.last_name,
    p.organization_id
FROM patients p
JOIN organizations o
    ON o.id = p.organization_id
WHERE o.organization_code = 'DEMO-LAB 2'
ORDER BY p.created_at DESC;

SELECT
    pr.id AS registration_id,
    pr.registration_number,
    pr.patient_id,
    pr.organization_id,
    pr.created_by
FROM patient_registrations pr
JOIN organizations o
    ON o.id = pr.organization_id
WHERE o.organization_code = 'DEMO-LAB 2'
ORDER BY pr.created_at DESC;


-- 2. INSERT DISEASE INTO CLINICAL_MASTER
-- Uses the organization/branch of the most recent registration


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
    'DIS-DRYRUN-001',
    'Dry Run Diabetes',
    'Dummy disease created for F001 Phase 2 validation',
    ctx.created_by
FROM ctx
ON CONFLICT (organization_id, branch_id, clinical_type, clinical_name)
DO NOTHING;


-- 3. LINK DISEASE TO PATIENT


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
    WHERE o.organization_code = 'DEMO-LAB 2 2'
    ORDER BY pr.created_at DESC
    LIMIT 1
)
INSERT INTO patient_clinical_history (
    organization_id,
    branch_id,
    patient_id,
    registration_id,
    clinical_id,
    diagnosed_date,
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
    CURRENT_DATE,
    'ACTIVE',
    'Dummy patient disease link for dry run',
    ctx.created_by
FROM ctx
JOIN clinical_master cm
    ON cm.organization_id = ctx.organization_id
   AND cm.branch_id = ctx.branch_id
   AND cm.clinical_type = 'DISEASE'
   AND cm.clinical_name = 'Dry Run Diabetes'
WHERE NOT EXISTS (
    SELECT 1
    FROM patient_clinical_history pch
    WHERE pch.patient_id = ctx.patient_id
      AND pch.clinical_id = cm.id
);


-- 4. VERIFY DISEASE WITH JOINS


SELECT
    p.first_name,
    p.last_name,
    cm.clinical_code,
    cm.clinical_name,
    pch.diagnosed_date,
    pch.status,
    pch.notes
FROM patient_clinical_history pch
JOIN patients p
    ON p.id = pch.patient_id
JOIN clinical_master cm
    ON cm.id = pch.clinical_id
WHERE cm.clinical_type = 'DISEASE'
  AND cm.clinical_name = 'Dry Run Diabetes';


-- 5. UPDATE PATIENT DISEASE STATUS


WITH ctx AS (
    SELECT
        pr.patient_id,
        pr.organization_id,
        pr.branch_id
    FROM patient_registrations pr
    JOIN organizations o
        ON o.id = pr.organization_id
    WHERE o.organization_code = 'DEMO-LAB'
    ORDER BY pr.created_at DESC
    LIMIT 1
)
UPDATE patient_clinical_history pch
SET
    status = 'CONTROLLED',
    notes = 'Updated during F001 Phase 2 dry run',
    updated_at = CURRENT_TIMESTAMP,
    updated_by = ctx_join.created_by
FROM (
    SELECT
        ctx.patient_id,
        cm.id AS clinical_id,
        pr.created_by
    FROM ctx
    JOIN clinical_master cm
        ON cm.organization_id = ctx.organization_id
       AND cm.branch_id = ctx.branch_id
       AND cm.clinical_type = 'DISEASE'
       AND cm.clinical_name = 'Dry Run Diabetes'
    JOIN patient_registrations pr
        ON pr.patient_id = ctx.patient_id
    ORDER BY pr.created_at DESC
    LIMIT 1
) ctx_join
WHERE pch.patient_id = ctx_join.patient_id
  AND pch.clinical_id = ctx_join.clinical_id;


-- 6. INSERT SYMPTOM INTO CLINICAL_MASTER


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
    'SYMPTOM',
    'SYM-DRYRUN-001',
    'Dry Run Fever',
    'Dummy symptom created for F001 Phase 2 validation',
    ctx.created_by
FROM ctx
ON CONFLICT (organization_id, branch_id, clinical_type, clinical_name)
DO NOTHING;


-- 7. LINK SYMPTOM TO REGISTRATION


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
    WHERE o.organization_code = 'DEMO-LAB 2 2'
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
    ctx.organization_id,
    ctx.branch_id,
    ctx.patient_id,
    ctx.registration_id,
    cm.id,
    'MODERATE',
    3,
    'DAY',
    'ACTIVE',
    'Dummy symptom link for dry run',
    ctx.created_by
FROM ctx
JOIN clinical_master cm
    ON cm.organization_id = ctx.organization_id
   AND cm.branch_id = ctx.branch_id
   AND cm.clinical_type = 'SYMPTOM'
   AND cm.clinical_name = 'Dry Run Fever'
WHERE NOT EXISTS (
    SELECT 1
    FROM patient_clinical_history pch
    WHERE pch.registration_id = ctx.registration_id
      AND pch.clinical_id = cm.id
);


-- 8. VERIFY SYMPTOM WITH REGISTRATION


SELECT
    pr.registration_number,
    p.first_name,
    p.last_name,
    cm.clinical_name,
    pch.severity,
    pch.duration_value,
    pch.duration_unit
FROM patient_clinical_history pch
JOIN patient_registrations pr
    ON pr.id = pch.registration_id
JOIN patients p
    ON p.id = pr.patient_id
JOIN clinical_master cm
    ON cm.id = pch.clinical_id
WHERE cm.clinical_type = 'SYMPTOM'
  AND cm.clinical_name = 'Dry Run Fever';


-- 9. INSERT MEDICAL CONDITION INTO CLINICAL_MASTER


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
    WHERE o.organization_code = 'DEMO-LAB 2 2'
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
    'CONDITION',
    'MC-DRYRUN-001',
    'Dry Run Hypertension',
    'Dummy medical condition for F001 Phase 2 validation',
    ctx.created_by
FROM ctx
ON CONFLICT (organization_id, branch_id, clinical_type, clinical_name)
DO NOTHING;


-- 10. LINK MEDICAL CONDITION TO PATIENT


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
    diagnosed_date,
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
    CURRENT_DATE,
    'ACTIVE',
    'Dummy condition link for dry run',
    ctx.created_by
FROM ctx
JOIN clinical_master cm
    ON cm.organization_id = ctx.organization_id
   AND cm.branch_id = ctx.branch_id
   AND cm.clinical_type = 'CONDITION'
   AND cm.clinical_name = 'Dry Run Hypertension'
WHERE NOT EXISTS (
    SELECT 1
    FROM patient_clinical_history pch
    WHERE pch.patient_id = ctx.patient_id
      AND pch.clinical_id = cm.id
);


-- 11. VERIFY MEDICAL CONDITION


SELECT
    p.first_name,
    p.last_name,
    cm.clinical_code,
    cm.clinical_name,
    pch.status,
    pch.notes
FROM patient_clinical_history pch
JOIN patients p
    ON p.id = pch.patient_id
JOIN clinical_master cm
    ON cm.id = pch.clinical_id
WHERE cm.clinical_type = 'CONDITION'
  AND cm.clinical_name = 'Dry Run Hypertension';


COMMIT;


-- Verification
-- 12. FINAL F001 PHASE 2 SUMMARY
-- Expected: one row per patient/registration with all three dry-run
-- clinical entries (DISEASE, SYMPTOM, CONDITION) attached

SELECT
    p.id AS patient_id,
    p.first_name,
    p.last_name,
    pr.registration_number,
    cm.clinical_type,
    cm.clinical_name,
    pch.status,
    pch.severity
FROM patients p
JOIN patient_registrations pr
    ON pr.patient_id = p.id
JOIN patient_clinical_history pch
    ON pch.patient_id = p.id
JOIN clinical_master cm
    ON cm.id = pch.clinical_id
WHERE cm.clinical_name IN (
    'Dry Run Diabetes',
    'Dry Run Fever',
    'Dry Run Hypertension'
)
ORDER BY cm.clinical_type;
