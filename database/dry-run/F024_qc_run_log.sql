INSERT INTO qc_run_log (
    organization_id,
    branch_id,
    qc_master_id,
    instrument_id,
    actual_value,
    z_score,
    result_status,
    rule_triggered,
    remarks,
    created_by
)
SELECT
    qm.organization_id,
    qm.branch_id,
    qm.id,
    qm.instrument_id,
    13.450,
    -0.250,
    'PASS',
    NULL,
    'Daily QC Run',
    u.id
FROM qc_master qm
JOIN users u
    ON u.organization_id = qm.organization_id
   AND u.branch_id = qm.branch_id
WHERE qm.lot_number = 'QC24001'
LIMIT 1;
