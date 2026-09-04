
-- F001 PATIENT REGISTRATION DRY RUN


BEGIN;

-- DR001: INSERT NEW PATIENT
-- Receptionist registers patient


INSERT INTO patients (
    organization_id,
    branch_id,
    patient_type,
    first_name,
    middle_name,
    last_name,
    gender,
    date_of_birth,
    patient_category,
    created_by,
    updated_by
)
SELECT
    o.id,
    b.id,
    'GENERAL',
    'Rahul',
    'Kumar',
    'Sharma',
    'MALE',
    DATE '1995-06-15',
    'REGULAR',
    u.id,
    u.id
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
JOIN users u
    ON u.organization_id = o.id
WHERE o.organization_code = 'DEMO-LAB 2'
  AND b.branch_code = 'PUNE-01'
  AND u.username = 'receptionist01';



-- DR002: INSERT MRN


INSERT INTO patient_identifiers (
    organization_id,
    branch_id,
    patient_id,
    identifier_type,
    identifier_value,
    is_primary
)
SELECT
    p.organization_id,
    p.branch_id,
    p.id,
    'MRN',
    'MRN-2026-0001',
    TRUE
FROM patients p
WHERE p.first_name = 'Rahul'
  AND p.last_name = 'Sharma';



-- DR003: INSERT CONTACT


INSERT INTO patient_contacts (
    organization_id,
    branch_id,
    patient_id,
    contact_type,
    contact_value,
    belongs_to,
    whatsapp_consent,
    is_primary,
    created_by,
    updated_by
)
SELECT
    p.organization_id,
    p.branch_id,
    p.id,
    'PHONE',
    '9876543210',
    'SELF',
    TRUE,
    TRUE,
    u.id,
    u.id
FROM patients p
JOIN organizations o
    ON o.id = p.organization_id
JOIN users u
    ON u.organization_id = o.id
WHERE p.first_name = 'Rahul'
  AND p.last_name = 'Sharma'
  AND u.username = 'receptionist01';



-- DR004: INSERT ADDRESS


INSERT INTO patient_addresses (
    organization_id,
    branch_id,
    patient_id,
    address_type,
    address_line1,
    city,
    district,
    state,
    country,
    pincode,
    is_primary,
    created_by,
    updated_by
)
SELECT
    p.organization_id,
    p.branch_id,
    p.id,
    'HOME',
    'Demo Address',
    'Pune',
    'Pune',
    'Maharashtra',
    'India',
    '411001',
    TRUE,
    u.id,
    u.id
FROM patients p
JOIN organizations o
    ON o.id = p.organization_id
JOIN users u
    ON u.organization_id = o.id
WHERE p.first_name = 'Rahul'
  AND p.last_name = 'Sharma'
  AND u.username = 'receptionist01';



-- DR005: CREATE REGISTRATION / VISIT


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
    'REG-2026-0001',
    'REGISTERED',
    u.id
FROM patients p
JOIN organizations o
    ON o.id = p.organization_id
JOIN branches b
    ON b.organization_id = o.id
JOIN users u
    ON u.organization_id = o.id
WHERE o.organization_code = 'DEMO-LAB 2'
  AND b.branch_code = 'PUNE-01'
  AND u.username = 'receptionist01'
  AND p.first_name = 'Rahul'
  AND p.last_name = 'Sharma';



-- DR006: AUDIT PATIENT CREATION


INSERT INTO audit_logs (
    organization_id,
    branch_id,
    user_id,
    action_type,
    entity_type,
    entity_id,
    new_values
)
SELECT
    o.id,
    b.id,
    u.id,
    'CREATE',
    'PATIENT',
    p.id,
    jsonb_build_object(
        'first_name', p.first_name,
        'last_name', p.last_name,
        'created_by_username', u.username
    )
FROM patients p
JOIN organizations o
    ON o.id = p.organization_id
JOIN branches b
    ON b.organization_id = o.id
JOIN users u
    ON u.organization_id = o.id
WHERE o.organization_code = 'DEMO-LAB 2'
  AND b.branch_code = 'PUNE-01'
  AND u.username = 'receptionist01'
  AND p.first_name = 'Rahul'
  AND p.last_name = 'Sharma';


COMMIT;



-- DR007: READ COMPLETE PATIENT


SELECT
    p.id AS patient_id,

    pi.identifier_value AS mrn,

    p.first_name,
    p.middle_name,
    p.last_name,

    p.gender,
    p.date_of_birth,

    pc.contact_value AS phone,
    pc.whatsapp_consent,

    pa.address_line1,
    pa.city,
    pa.state,
    pa.pincode,

    pr.registration_number,
    pr.registration_status,

    o.organization_name,
    b.branch_name,

    u.username AS created_by_user

FROM patients p

LEFT JOIN patient_identifiers pi
    ON pi.patient_id = p.id
   AND pi.is_primary = TRUE

LEFT JOIN patient_contacts pc
    ON pc.patient_id = p.id
   AND pc.is_primary = TRUE

LEFT JOIN patient_addresses pa
    ON pa.patient_id = p.id
   AND pa.is_primary = TRUE

LEFT JOIN patient_registrations pr
    ON pr.patient_id = p.id

JOIN organizations o
    ON o.id = p.organization_id

LEFT JOIN branches b
    ON b.id = pr.branch_id

LEFT JOIN users u
    ON u.id = p.created_by

WHERE pi.identifier_value = 'MRN-2026-0002';



-- DR008: UPDATE PATIENT CONTACT


UPDATE patient_contacts pc
SET
    contact_value = '9999999999',
    updated_at = CURRENT_TIMESTAMP,
    updated_by = (
        SELECT u.id
        FROM users u
        JOIN organizations o
            ON o.id = u.organization_id
        WHERE o.organization_code = 'DEMO-LAB 2'
          AND u.username = 'receptionist01'
    )
WHERE pc.patient_id = (
    SELECT pi.patient_id
    FROM patient_identifiers pi
    WHERE pi.identifier_type = 'MRN'
      AND pi.identifier_value = 'MRN-2026-0002'
);


-- Verify update
SELECT
    pi.identifier_value AS mrn,
    pc.contact_value AS updated_phone,
    pc.updated_at,
    u.username AS updated_by_user
FROM patient_contacts pc
JOIN patient_identifiers pi
    ON pi.patient_id = pc.patient_id
LEFT JOIN users u
    ON u.id = pc.updated_by
WHERE pi.identifier_value = 'MRN-2026-0002';


-- 
-- DR009: SECOND REGISTRATION
-- Proves same patient can return again
-- 

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
    'REG-2026-0002',
    'REGISTERED',
    u.id
FROM patients p
JOIN organizations o
    ON o.id = p.organization_id
JOIN branches b
    ON b.organization_id = o.id
JOIN users u
    ON u.organization_id = o.id
JOIN patient_identifiers pi
    ON pi.patient_id = p.id
WHERE o.organization_code = 'DEMO-LAB 2'
  AND b.branch_code = 'PUNE-01'
  AND u.username = 'receptionist01'
  AND pi.identifier_value = 'MRN-2026-0002';


-- Verify multiple registrations
SELECT
    pi.identifier_value AS mrn,
    pr.registration_number,
    pr.registered_at,
    pr.registration_status
FROM patient_registrations pr
JOIN patient_identifiers pi
    ON pi.patient_id = pr.patient_id
WHERE pi.identifier_value = 'MRN-2026-0002'
ORDER BY pr.registered_at;


-- 
-- DR010: DEACTIVATE PATIENT

UPDATE patients
SET
    is_active = FALSE,
    updated_at = CURRENT_TIMESTAMP,
    updated_by = (
        SELECT u.id
        FROM users u
        JOIN organizations o
            ON o.id = u.organization_id
        WHERE o.organization_code = 'DEMO-LAB 2'
          AND u.username = 'receptionist01'
    )
WHERE id = (
    SELECT patient_id
    FROM patient_identifiers
    WHERE identifier_value = 'MRN-2026-0002'
);


-- Verify deactivation
SELECT
    pi.identifier_value AS mrn,
    p.first_name,
    p.last_name,
    p.is_active,
    p.updated_at
FROM patients p
JOIN patient_identifiers pi
    ON pi.patient_id = p.id
WHERE pi.identifier_value = 'MRN-2026-0002';


INSERT INTO patient_trf
(
    organization_id,
    branch_id,
    patient_id,
    registration_id,
    trf_number,
    trf_file_url,
    uploaded_by,
    remarks
)
SELECT
    pr.organization_id,
    pr.branch_id,
    pr.patient_id,
    pr.id,
    'TRF001',
    'https://example.com/trf001.pdf',
    (SELECT id FROM users LIMIT 1),
    'Dry Run TRF'
FROM patient_registrations pr
LIMIT 1;