INSERT INTO department_master (
    organization_id,
    branch_id,
    department_code,
    department_name
)
SELECT
    o.id,
    b.id,
    'HEMATOLOGY',
    'Hematology'
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
WHERE o.organization_code = 'DEMO-LAB 2'
  AND b.branch_code = 'PUNE-01';
