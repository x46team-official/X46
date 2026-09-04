
-- F002 PATIENT SEARCH DRY RUN


WITH ctx AS (
    SELECT o.id AS organization_id
    FROM organizations o
    WHERE o.organization_code = 'DEMO-LAB 2'
)
SELECT
    p.id,
    p.first_name,
    p.middle_name,
    p.last_name,
    p.gender,
    p.date_of_birth
FROM patients p
JOIN ctx
    ON ctx.organization_id = p.organization_id
WHERE p.first_name ILIKE '%Rahul%'
   OR p.middle_name ILIKE '%Rahul%'
   OR p.last_name ILIKE '%Rahul%';


-- 2. SEARCH BY MRN / PATIENT ID / PASSPORT (organization scoped)

WITH ctx AS (
    SELECT o.id AS organization_id
    FROM organizations o
    WHERE o.organization_code = 'DEMO-LAB 2'
)
SELECT
    p.id,
    p.first_name,
    p.last_name,
    pi.identifier_type,
    pi.identifier_value
FROM patients p
JOIN ctx
    ON ctx.organization_id = p.organization_id
JOIN patient_identifiers pi
    ON pi.patient_id = p.id
   AND pi.organization_id = ctx.organization_id
WHERE pi.identifier_type = 'MRN'
  AND pi.identifier_value ILIKE '%MRN-2026%';


-- 3. SEARCH BY PHONE / CONTACT (organization scoped)

WITH ctx AS (
    SELECT o.id AS organization_id
    FROM organizations o
    WHERE o.organization_code = 'DEMO-LAB 2'
)
SELECT
    p.id,
    p.first_name,
    p.last_name,
    pc.contact_type,
    pc.contact_value,
    pc.belongs_to
FROM patients p
JOIN ctx
    ON ctx.organization_id = p.organization_id
JOIN patient_contacts pc
    ON pc.patient_id = p.id
   AND pc.organization_id = ctx.organization_id
WHERE pc.contact_type = 'PHONE'
  AND pc.contact_value ILIKE '%999%';


-- 4. SEARCH BY DATE OF BIRTH (organization scoped)

WITH ctx AS (
    SELECT o.id AS organization_id
    FROM organizations o
    WHERE o.organization_code = 'DEMO-LAB 2'
)
SELECT
    p.id,
    p.first_name,
    p.last_name,
    p.date_of_birth
FROM patients p
JOIN ctx
    ON ctx.organization_id = p.organization_id
WHERE p.date_of_birth = DATE '1995-06-15';


-- 5. SEARCH BY REGISTRATION NUMBER (organization scoped)

WITH ctx AS (
    SELECT o.id AS organization_id
    FROM organizations o
    WHERE o.organization_code = 'DEMO-LAB 2'
)
SELECT
    p.id,
    p.first_name,
    p.last_name,
    pr.registration_number,
    pr.registration_status,
    pr.registered_at
FROM patients p
JOIN ctx
    ON ctx.organization_id = p.organization_id
JOIN patient_registrations pr
    ON pr.patient_id = p.id
   AND pr.organization_id = ctx.organization_id
WHERE pr.registration_number = 'REG-2026-0001';


-- 6. COMBINED SEARCH RESULT
-- Simulates one patient search screen (name / MRN / phone / registration no.)

WITH ctx AS (
    SELECT o.id AS organization_id
    FROM organizations o
    WHERE o.organization_code = 'DEMO-LAB 2'
)
SELECT DISTINCT
    p.id AS patient_id,
    p.first_name,
    p.middle_name,
    p.last_name,
    p.gender,
    p.date_of_birth,

    pi.identifier_type,
    pi.identifier_value,

    pc.contact_type,
    pc.contact_value,

    pr.registration_number,
    pr.registration_status

FROM patients p
JOIN ctx
    ON ctx.organization_id = p.organization_id

LEFT JOIN patient_identifiers pi
    ON pi.patient_id = p.id
   AND pi.organization_id = ctx.organization_id

LEFT JOIN patient_contacts pc
    ON pc.patient_id = p.id
   AND pc.organization_id = ctx.organization_id

LEFT JOIN patient_registrations pr
    ON pr.patient_id = p.id
   AND pr.organization_id = ctx.organization_id

WHERE
    p.first_name ILIKE '%Rahul%'
    OR p.last_name ILIKE '%Rahul%'
    OR pi.identifier_value ILIKE '%Rahul%'
    OR pc.contact_value ILIKE '%Rahul%'
    OR pr.registration_number ILIKE '%Rahul%'

ORDER BY p.first_name, p.last_name;


-- 7. VERIFY ORGANIZATION ISOLATION
-- Every row returned must belong to the DEMO-LAB organization only
-- Expected: organization_id column is constant across all rows

WITH ctx AS (
    SELECT o.id AS organization_id
    FROM organizations o
    WHERE o.organization_code = 'DEMO-LAB 2'
)
SELECT
    p.id,
    p.first_name,
    p.last_name,
    p.organization_id
FROM patients p
JOIN ctx
    ON ctx.organization_id = p.organization_id
WHERE p.first_name ILIKE '%Rahul%';


-- 8. CHECK QUERY PLAN FOR NAME SEARCH (organization scoped)

WITH ctx AS (
    SELECT o.id AS organization_id
    FROM organizations o
    WHERE o.organization_code = 'DEMO-LAB 2'
)
EXPLAIN ANALYZE
SELECT
    p.id,
    p.first_name,
    p.last_name
FROM patients p
JOIN ctx
    ON ctx.organization_id = p.organization_id
WHERE p.first_name ILIKE '%Rahul%';


-- 9. CHECK QUERY PLAN FOR IDENTIFIER SEARCH (organization scoped)

WITH ctx AS (
    SELECT o.id AS organization_id
    FROM organizations o
    WHERE o.organization_code = 'DEMO-LAB'
)
EXPLAIN ANALYZE
SELECT
    p.id,
    pi.identifier_value
FROM patients p
JOIN ctx
    ON ctx.organization_id = p.organization_id
JOIN patient_identifiers pi
    ON pi.patient_id = p.id
   AND pi.organization_id = ctx.organization_id
WHERE pi.identifier_value = 'MRN-2026-0001';


-- 10. CHECK QUERY PLAN FOR CONTACT SEARCH (organization scoped)

WITH ctx AS (
    SELECT o.id AS organization_id
    FROM organizations o
    WHERE o.organization_code = 'DEMO-LAB'
)
EXPLAIN ANALYZE
SELECT
    p.id,
    pc.contact_value
FROM patients p
JOIN ctx
    ON ctx.organization_id = p.organization_id
JOIN patient_contacts pc
    ON pc.patient_id = p.id
   AND pc.organization_id = ctx.organization_id
WHERE pc.contact_value = '9999999999';
