INSERT INTO outsource_center_master (
    organization_id,
    branch_id,
    center_code,
    center_name,
    contact_person,
    phone_number,
    email,
    address,
    city,
    state,
    country,
    pincode,
    gst_number
)
SELECT
    o.id,
    b.id,
    'THY001',
    'Thyrocare',
    'Support Team',
    '9876543210',
    'support@thyrocare.com',
    'Hinjewadi Phase 1',
    'Pune',
    'Maharashtra',
    'India',
    '411057',
    '27ABCDE1234F1Z5'
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
WHERE o.organization_code = 'DEMO-LAB'
  AND b.branch_code = 'PUNE-01';
