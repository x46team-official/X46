INSERT INTO worksheet_master (
    organization_id,
    branch_id,
    worksheet_code,
    worksheet_name,
    description
)
SELECT
    o.id,
    b.id,
    'WS001',
    'Routine Worksheet',
    'Default worksheet for daily processing'
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
WHERE o.organization_code = 'DEMO-LAB'
  AND b.branch_code = 'PUNE-01';
