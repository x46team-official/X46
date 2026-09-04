INSERT INTO instrument_test_mapping (
    organization_id,
    branch_id,
    instrument_id,
    test_id,
    parameter_id,
    machine_test_code,
    machine_parameter_code,
    display_order,
    is_active,
    remarks,
    created_by
)
SELECT
    im.organization_id,
    im.branch_id,
    im.id,
    tm.id,
    pm.id,
    'CBC',
    'HGB',
    1,
    TRUE,
    'Dry Run Mapping',
    u.id
FROM instrument_master im
JOIN test_master tm
    ON tm.organization_id = im.organization_id
   AND tm.branch_id = im.branch_id
JOIN parameter_master pm
    ON pm.organization_id = im.organization_id
   AND pm.branch_id = im.branch_id
JOIN users u
    ON u.organization_id = im.organization_id
   AND u.branch_id = im.branch_id
WHERE im.instrument_code = 'SYSMEX_XN550'
LIMIT 1;
