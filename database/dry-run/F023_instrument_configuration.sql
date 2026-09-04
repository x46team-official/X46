INSERT INTO instrument_configuration (
    organization_id,
    branch_id,
    instrument_id,
    communication_protocol,
    connection_type,
    interface_mode,
    ip_address,
    port,
    com_port,
    baud_rate,
    parity,
    data_bits,
    stop_bits,
    driver_name,
    workstation_name,
    status,
    remarks,
    created_by
)
SELECT
    i.organization_id,
    i.branch_id,
    i.id,
    'HL7',
    'TCP/IP',
    'BIDIRECTIONAL',
    '127.0.0.1',
    '1000',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    'x46 Middleware',
    'LAB-WS-01',
    'ACTIVE',
    'Dry Run Configuration',
    u.id
FROM instrument_master i
JOIN users u
    ON u.organization_id = i.organization_id
   AND u.branch_id = i.branch_id
WHERE i.instrument_code = 'SYSMEX_XN550'
LIMIT 1;
