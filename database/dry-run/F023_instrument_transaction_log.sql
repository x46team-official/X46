INSERT INTO instrument_transaction_log (
    organization_id,
    branch_id,
    instrument_id,
    accession_test_id,
    sample_barcode,
    message_type,
    protocol,
    direction,
    raw_message,
    parsed_data,
    processing_status,
    error_message,
    created_by
)
SELECT
    i.organization_id,
    i.branch_id,
    i.id,
    at.id,
    'BC-000001',
    'RESULT',
    'HL7',
    'INBOUND',
    'MSH|^~\&|XN550|LAB|LIMS||202607221230||ORU^R01|0001|P|2.3',
    '{"WBC":"6.8","RBC":"4.75","HGB":"14.2"}'::jsonb,
    'RECEIVED',
    NULL,
    u.id
FROM instrument_master i
JOIN accession_tests at
    ON at.organization_id = i.organization_id
   AND at.branch_id = i.branch_id
JOIN users u
    ON u.organization_id = i.organization_id
   AND u.branch_id = i.branch_id
WHERE i.instrument_code = 'SYSMEX_XN550'
LIMIT 1;
