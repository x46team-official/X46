INSERT INTO appointment_type_master (
    organization_id,
    branch_id,
    appointment_type_code,
    appointment_type_name
)
SELECT
    o.id,
    b.id,
    'walkin',
    'Walk-in'
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
WHERE o.organization_code = 'DEMO-LAB 2'
  AND b.branch_code = 'PUNE-01'
LIMIT 1;

INSERT INTO appointments (
    organization_id,
    branch_id,
    patient_id,
    registration_id,
    appointment_type_id,
    appointment_number,
    appointment_date,
    appointment_time,
    created_by
)
SELECT
    pr.organization_id,
    pr.branch_id,
    pr.patient_id,
    pr.id,
    atm.id,
    'APT-0001',
    CURRENT_DATE,
    CURRENT_TIME,
    pr.created_by
FROM patient_registrations pr
JOIN appointment_type_master atm
    ON atm.organization_id = pr.organization_id
   AND atm.branch_id = pr.branch_id
LIMIT 1;

INSERT INTO appointment_tests (
    organization_id,
    branch_id,
    appointment_id,
    test_code,
    test_name,
    department
)
SELECT
    a.organization_id,
    a.branch_id,
    a.id,
    'CBC',
    'Complete Blood Count',
    'Hematology'
FROM appointments a
LIMIT 1;

INSERT INTO appointment_assignments (
    organization_id,
    branch_id,
    appointment_id,
    assigned_to,
    assignment_role
)
SELECT
    a.organization_id,
    a.branch_id,
    a.id,
    u.id,
    'Technician'
FROM appointments a
JOIN users u
    ON u.organization_id = a.organization_id
   AND u.branch_id = a.branch_id
LIMIT 1;

UPDATE appointments
SET appointment_status = 'COMPLETED'
WHERE appointment_number = 'APT-0001';

INSERT INTO appointment_status_history (
    organization_id,
    branch_id,
    appointment_id,
    status,
    remarks,
    created_by
)
SELECT
    a.organization_id,
    a.branch_id,
    a.id,
    'COMPLETED',
    'Appointment completed successfully',
    u.id
FROM appointments a
JOIN users u
    ON u.organization_id = a.organization_id
   AND u.branch_id = a.branch_id
WHERE a.appointment_number = 'APT-0001'
LIMIT 1;

SELECT
    a.appointment_number,
    p.first_name,
    p.last_name,
    at.test_name,
    aa.assignment_role,
    ash.status
FROM appointments a
JOIN patients p
    ON p.id = a.patient_id
LEFT JOIN appointment_tests at
    ON at.appointment_id = a.id
LEFT JOIN appointment_assignments aa
    ON aa.appointment_id = a.id
LEFT JOIN appointment_status_history ash
    ON ash.appointment_id = a.id
WHERE a.appointment_number = 'APT-0001';
