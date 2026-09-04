INSERT INTO worklist_master
(
    organization_id,
    branch_id,
    department_id,
    worklist_code,
    worklist_name,
    description,
    sort_order,
    estimated_tat_minutes,
    allow_generate_worklist,
    allow_generate_worksheet,
    allow_print,
    allow_export,
    is_default
)

SELECT
    o.id,
    b.id,
    d.id,
    'HEM001',
    'Hematology Worklist',
    'Default hematology worklist',
    'ASC',
    120,
    TRUE,
    TRUE,
    TRUE,
    TRUE,
    TRUE
FROM organizations o
JOIN branches b
ON b.organization_id = o.id
JOIN department_master d
ON d.organization_id = o.id
AND d.branch_id = b.id
WHERE o.organization_code = 'DEMO-LAB'
  AND b.branch_code = 'PUNE-01'
LIMIT 1;

SELECT * FROM worklist_master;
