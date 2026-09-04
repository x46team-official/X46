INSERT INTO menu_permission (
    organization_id,
    branch_id,
    role_id,
    menu_name,
    is_visible,
    display_order,
    created_by
)
SELECT
    r.organization_id,
    r.branch_id,
    r.id,
    'Dashboard',
    TRUE,
    1,
    u.id
FROM roles r
JOIN users u
    ON u.organization_id = r.organization_id
   AND u.branch_id = r.branch_id
LIMIT 1;

SELECT *
FROM menu_permission
WHERE deleted_at IS NULL;
