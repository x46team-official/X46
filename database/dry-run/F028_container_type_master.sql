INSERT INTO container_type_master (
    organization_id,
    branch_id,
    container_name,
    description,
    created_by
)
SELECT
    o.id,
    b.id,
    v.container_name,
    v.description,
    u.id
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
JOIN users u
    ON u.organization_id = o.id
   AND u.branch_id = b.id
CROSS JOIN (
    VALUES
        ('Vacutainer', 'Standard blood collection tube'),
        ('Plain Tube', 'Serum collection tube'),
        ('Urine Container', 'Sterile urine collection container')
) AS v(container_name, description)
WHERE o.organization_code = 'DEMO-LAB 2'
  AND b.branch_code = 'PUNE-01';
