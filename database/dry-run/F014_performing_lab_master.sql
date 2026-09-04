INSERT INTO performing_lab_master (
    organization_id,
    branch_id,
    lab_code,
    lab_name,
    alternate_name,
    legal_name,
    contact_person,
    phone_number,
    email,
    address,
    city,
    state,
    country,
    pincode,
    gst_number,
    lab_type,
    is_default
)
SELECT
    o.id,
    b.id,
    'MAIN',
    'Main Laboratory',
    'Main Lab',
    'Main Laboratory Pvt Ltd',
    'Lab Manager',
    '9876543210',
    'lab@x46.com',
    'Yerwada',
    'Pune',
    'Maharashtra',
    'India',
    '411045',
    '27ABCDE1234F1Z5',
    'Internal',
    TRUE
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
WHERE o.organization_code = 'DEMO-LAB'
  AND b.branch_code = 'PUNE-01';

SELECT * FROM performing_lab_master;
