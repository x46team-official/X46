INSERT INTO result_authorization (
    organization_id,
    branch_id,
    result_entry_id,
    authorization_status,
    remarks,
    created_by
)
SELECT
    re.organization_id,
    re.branch_id,
    re.id,
    'PENDING',
    'Dry Run Authorization',
    u.id
FROM result_entry re
JOIN users u
    ON u.organization_id = re.organization_id
   AND u.branch_id = re.branch_id
LIMIT 1
ON CONFLICT (organization_id, branch_id, result_entry_id)
DO NOTHING;

SELECT * FROM result_authorization;
