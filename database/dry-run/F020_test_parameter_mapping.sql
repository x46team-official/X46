INSERT INTO parameter_master (
    organization_id,
    branch_id,
    parameter_code,
    parameter_name,
    data_type,
    result_type,
    decimal_places,
    remarks,
    created_by
)
SELECT
    o.id,
    b.id,
    'HGB',
    'Hemoglobin',
    'NUMERIC',
    'NUMERIC',
    2,
    'Dry Run Parameter',
    u.id
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
JOIN users u
    ON u.organization_id = o.id
   AND u.branch_id = b.id
WHERE o.organization_code = 'DEMO-LAB 2'
  AND b.branch_code = 'PUNE-01'
LIMIT 1
ON CONFLICT (organization_id, branch_id, parameter_code)
DO NOTHING;
