INSERT INTO qc_master (
    organization_id,
    branch_id,
    instrument_id,
    test_id,
    parameter_id,
    qc_level,
    lot_number,
    manufacturer,
    mean_value,
    standard_deviation,
    acceptable_min,
    acceptable_max,
    expiry_date,
    status,
    remarks,
    created_by
)
SELECT
    im.organization_id,
    im.branch_id,
    im.id,
    tm.id,
    pm.id,
    'LEVEL_1',
    'QC24001',
    'Bio-Rad',
    13.500,
    0.200,
    13.100,
    13.900,
    CURRENT_DATE + INTERVAL '180 days',
    'ACTIVE',
    'Dry Run QC Material',
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
