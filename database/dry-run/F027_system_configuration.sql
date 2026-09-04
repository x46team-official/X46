INSERT INTO system_configuration (
    organization_id,
    branch_id,
    config_key,
    config_value,
    description,
    created_by
)
SELECT
    o.id,
    b.id,
    'REPORT_HEADER',
    'ABC Diagnostic Centre',
    'Default report header',
    u.id
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
JOIN users u
    ON u.organization_id = o.id
   AND u.branch_id = b.id
WHERE o.organization_code = 'DEMO-LAB 2'
  AND b.branch_code = 'PUNE-01'
LIMIT 1;
