BEGIN;

SELECT id AS organization_id
FROM organizations
WHERE organization_code = 'LAB002'
\gset

SELECT id AS branch_id
FROM branches
WHERE organization_id = :'organization_id'
  AND branch_code = 'PUNE002'
\gset

SELECT id as admin_user_id
from users
where organization_id =:'organization_id'
and username='admin'
\gset

INSERT INTO department_master
(
    organization_id,
    branch_id,
    department_name,
    department_code,
    description,
    is_active,
    created_by
)
VALUES
(
    :'organization_id',
    :'branch_id',
    'Pathology',
    'PATH',
    'Pathology Department',
    TRUE,
    :'admin_user_id'
)
ON CONFLICT (organization_id, branch_id, department_name)
DO NOTHING;

COMMIT;
