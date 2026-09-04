INSERT INTO instrument_master (
    organization_id,
    branch_id,
    department_id,
    instrument_code,
    instrument_name,
    manufacture,
    model,
    serial_number,
    analyzer_type,
    status,
    remarks,
    created_by
)
SELECT
    d.organization_id,
    d.branch_id,
    d.id,
    'SYSMEX_XN550',
    'SYSMEX_XN550',
    'SYSMEX',
    'XN-500',
    'SYSMEX_XN550-0011',
    'HEMATOLOGY',
    'ACTIVE',
    'DRY-run',
    u.id
FROM department_master d
CROSS JOIN users u
WHERE d.department_name = 'Hematology'
LIMIT 1
ON CONFLICT (organization_id, branch_id, instrument_code)
DO NOTHING;

SELECT * FROM instrument_master;
