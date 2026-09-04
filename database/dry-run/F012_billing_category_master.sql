INSERT INTO billing_category_master (
    organization_id,
    branch_id,
    billing_category_code,
    billing_category_name,
    description,
    is_default
)
SELECT
    o.id,
    b.id,
    'PATH',
    'Pathology',
    'Default Pathology Billing Category',
    TRUE
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
WHERE o.organization_code = 'DEMO-LAB'
  AND b.branch_code = 'PUNE-01';

SELECT * FROM billing_category_master;
