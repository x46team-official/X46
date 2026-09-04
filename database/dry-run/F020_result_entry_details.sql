INSERT INTO result_entry_details (
    organization_id,
    branch_id,
    result_entry_id,
    parameter_id,
    result_value,
    result_flag,
    remarks,
    created_by
)
SELECT
    re.organization_id,
    re.branch_id,
    re.id,
    pm.id,
    '13.8',
    'NORMAL',
    'Dry Run Result',
    u.id
FROM result_entry re
JOIN parameter_master pm
    ON pm.organization_id = re.organization_id
   AND pm.branch_id = re.branch_id
JOIN users u
    ON u.organization_id = re.organization_id
   AND u.branch_id = re.branch_id
WHERE pm.parameter_code = 'HGB'
LIMIT 1
ON CONFLICT (result_entry_id, parameter_id)
DO NOTHING;

SELECT *
FROM result_entry_details red
JOIN parameter_master pm
    ON pm.id = red.parameter_id;
