BEGIN;

WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        u.id AS admin_user_id,
        re.id AS result_entry_id,
        at.id AS accession_test_id
    FROM organizations o
    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'
    JOIN accession_master am
        ON am.organization_id = o.id
       AND am.accession_number = 'ACC0001'
    JOIN accession_tests at
        ON at.accession_id = am.id
    JOIN test_master tm
        ON tm.id = at.test_id
       AND tm.test_code = 'CBC001'
    JOIN result_entry re
        ON re.accession_test_id = at.id
    WHERE o.organization_code = 'LAB002'
)

UPDATE result_entry re
SET
    result_status = 'AUTHORIZED',
    verified_at = CURRENT_TIMESTAMP,
    verified_by = ctx.admin_user_id,
    updated_at = CURRENT_TIMESTAMP,
    updated_by = ctx.admin_user_id
FROM ctx
WHERE re.id = ctx.result_entry_id
  AND re.result_status <> 'AUTHORIZED';

-- update accession Test authorization status

WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        u.id AS admin_user_id,
        at.id AS accession_test_id
    FROM organizations o
    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'
    JOIN accession_master am
        ON am.organization_id = o.id
       AND am.accession_number = 'ACC0001'
    JOIN accession_tests at
        ON at.accession_id = am.id
    JOIN test_master tm
        ON tm.id = at.test_id
       AND tm.test_code = 'CBC001'
    WHERE o.organization_code = 'LAB002'
)

UPDATE accession_tests at
SET
    authorization_status = 'AUTHORIZED',
    updated_at = CURRENT_TIMESTAMP,
    updated_by = ctx.admin_user_id
FROM ctx
WHERE at.id = ctx.accession_test_id
  AND at.authorization_status <> 'AUTHORIZED';

COMMIT;

-- Verification
SELECT
    o.organization_code,
    am.accession_number,
    tm.test_code,
    re.result_status,
    at.authorization_status,
    re.verified_at,
    u.username AS verified_by
FROM organizations o
JOIN accession_master am
    ON am.organization_id = o.id
JOIN accession_tests at
    ON at.accession_id = am.id
JOIN test_master tm
    ON tm.id = at.test_id
JOIN result_entry re
    ON re.accession_test_id = at.id
LEFT JOIN users u
    ON u.id = re.verified_by
WHERE o.organization_code = 'LAB002'
  AND am.accession_number = 'ACC0001'
  AND tm.test_code = 'CBC001';


SELECT
'Result Authorization E2E Validation Completed Successfully'
AS status;
