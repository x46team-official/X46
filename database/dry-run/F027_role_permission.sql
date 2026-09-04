INSERT INTO role_permission (
    organization_id,
    branch_id,
    role_id,
    module_name,
    can_create,
    can_view,
    can_update,
    can_delete,
    can_authorize,
    can_print,
    can_export,
    created_by
)
SELECT
    r.organization_id,
    r.branch_id,
    r.id,
    'Patient Registration',
    TRUE,
    TRUE,
    TRUE,
    FALSE,
    FALSE,
    TRUE,
    TRUE,
    u.id
FROM roles r
JOIN users u
    ON u.organization_id = r.organization_id
   AND u.branch_id = r.branch_id
LIMIT 1;
