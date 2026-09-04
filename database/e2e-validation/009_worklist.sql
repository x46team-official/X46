BEGIN;


-- Create Worklist Master (One Time)

WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        d.branch_id,
        u.id AS admin_user_id,
        d.id AS department_id
    FROM organizations o

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    JOIN department_master d
        ON d.organization_id = o.id

    WHERE o.organization_code = 'LAB002'
      AND d.department_code = 'HEM'
)

INSERT INTO worklist_master
(
    organization_id,
    branch_id,
    department_id,
    worklist_code,
    worklist_name,
    description,
    estimated_tat_minutes,
    created_by
)
SELECT
    organization_id,
    branch_id,
    department_id,
    'WL001',
    'Hematology Worklist',
    'E2E Validation Worklist',
    60,
    admin_user_id
FROM ctx
WHERE NOT EXISTS
(
    SELECT 1
    FROM worklist_master wm
    WHERE wm.organization_id = ctx.organization_id
      AND wm.branch_id = ctx.branch_id
      AND wm.worklist_code = 'WL001'
);


-- Create Worksheet Master (One Time)

WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        b.id AS branch_id,
        u.id AS admin_user_id
    FROM organizations o

    JOIN branches b
        ON b.organization_id = o.id
       AND b.branch_code = 'PUNE002'

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    WHERE o.organization_code = 'LAB002'
)

INSERT INTO worksheet_master
(
    organization_id,
    branch_id,
    worksheet_code,
    worksheet_name,
    description,
    created_by
)
SELECT
    organization_id,
    branch_id,
    'WS001',
    'Daily Hematology Worksheet',
    'E2E Validation Worksheet',
    admin_user_id
FROM ctx
WHERE NOT EXISTS
(
    SELECT 1
    FROM worksheet_master ws
    WHERE ws.organization_id = ctx.organization_id
      AND ws.branch_id = ctx.branch_id
      AND ws.worksheet_code = 'WS001'
);


-- Assign Sample to Worklist

WITH ctx AS
(
    SELECT
        at.id AS accession_test_id,
        u.id AS admin_user_id,
        wm.id AS worklist_id,
        ws.id AS worksheet_id
    FROM organizations o

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    JOIN accession_master am
        ON am.organization_id = o.id

    JOIN accession_tests at
        ON at.accession_id = am.id

    JOIN worklist_master wm
        ON wm.organization_id = o.id
       AND wm.worklist_code = 'WL001'

    JOIN worksheet_master ws
        ON ws.organization_id = o.id
       AND ws.worksheet_code = 'WS001'

    WHERE o.organization_code = 'LAB002'
      AND am.accession_number = 'ACC0001'
)

UPDATE accession_tests at
SET
    worklist_id = ctx.worklist_id,
    worksheet_id = ctx.worksheet_id,
    sample_status = 'PROCESSING',
    updated_by = ctx.admin_user_id,
    updated_at = CURRENT_TIMESTAMP
FROM ctx
WHERE at.id = ctx.accession_test_id
AND
(
       at.worklist_id IS DISTINCT FROM ctx.worklist_id
    OR at.worksheet_id IS DISTINCT FROM ctx.worksheet_id
    OR at.sample_status <> 'PROCESSING'
);

COMMIT;


-- Verification : Worklist Assignment

SELECT
    o.organization_code,
    am.accession_number,
    tm.test_code,
    tm.test_name,
    wm.worklist_code,
    wm.worklist_name,
    ws.worksheet_code,
    ws.worksheet_name,
    at.sample_status
FROM accession_tests at

JOIN accession_master am
    ON am.id = at.accession_id

JOIN organizations o
    ON o.id = at.organization_id

JOIN test_master tm
    ON tm.id = at.test_id

LEFT JOIN worklist_master wm
    ON wm.id = at.worklist_id

LEFT JOIN worksheet_master ws
    ON ws.id = at.worksheet_id

WHERE o.organization_code = 'LAB002'
  AND am.accession_number = 'ACC0001';


-- Status

SELECT
    'Worklist Assignment E2E Validation Completed Successfully' AS status;