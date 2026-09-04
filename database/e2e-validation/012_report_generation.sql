BEGIN;

-- Create Report
WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        am.branch_id,
        am.id AS accession_id,
        u.id AS admin_user_id
    FROM organizations o
    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'
    JOIN accession_master am
        ON am.organization_id = o.id
       AND am.accession_number = 'ACC0001'
    WHERE o.organization_code = 'LAB002'
)

INSERT INTO report_master
(
    organization_id,
    branch_id,
    accession_id,
    report_number,
    report_status,
    generated_at,
    generated_by,
    created_by
)
SELECT
    organization_id,
    branch_id,
    accession_id,
    'RPT-ACC0001',
    'GENERATED',
    CURRENT_TIMESTAMP,
    admin_user_id,
    admin_user_id
FROM ctx
ON CONFLICT (organization_id, branch_id, accession_id)
DO NOTHING;


-- Update Accession Report Status
WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        am.branch_id,
        am.id AS accession_id,
        u.id AS admin_user_id
    FROM organizations o
    JOIN users u
        ON u.organization_id = o.id
       AND u.username='admin'
    JOIN accession_master am
        ON am.organization_id=o.id
       AND am.accession_number='ACC0001'
    WHERE o.organization_code='LAB002'
)

UPDATE accession_tests at
SET
    report_status='READY',
    updated_at=CURRENT_TIMESTAMP,
    updated_by=ctx.admin_user_id
FROM ctx
WHERE at.accession_id=ctx.accession_id
  AND at.report_status<>'READY';


-- Verification
SELECT
    o.organization_code,
    am.accession_number,
    rm.report_number,
    rm.report_status,
    at.report_status,
    rm.generated_at,
    u.username AS generated_by
FROM report_master rm
JOIN organizations o
    ON o.id=rm.organization_id
JOIN accession_master am
    ON am.id=rm.accession_id
JOIN accession_tests at
    ON at.accession_id=am.id
LEFT JOIN users u
    ON u.id=rm.generated_by
WHERE o.organization_code='LAB002'
  AND am.accession_number='ACC0001';


SELECT
'Report Generation E2E Validation Completed Successfully'
AS status;

COMMIT;