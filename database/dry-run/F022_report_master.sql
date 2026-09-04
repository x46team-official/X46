INSERT INTO report_master (
    organization_id,
    branch_id,
    accession_id,
    report_number,
    report_status,
    generated_at,
    generated_by,
    remarks,
    created_by
)
SELECT
    am.organization_id,
    am.branch_id,
    am.id,
    'RPT' || TO_CHAR(CURRENT_TIMESTAMP, 'YYMMDDHH24MISS'),
    'GENERATED',
    CURRENT_TIMESTAMP,
    (SELECT id FROM users LIMIT 1),
    'Dry Run Report',
    (SELECT id FROM users LIMIT 1)
FROM accession_master am
LIMIT 1
ON CONFLICT (organization_id, branch_id, accession_id)
DO NOTHING;
