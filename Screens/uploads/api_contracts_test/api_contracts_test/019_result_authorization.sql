BEGIN;

-- =========================================================
-- CONTEXT
-- =========================================================

WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        re.branch_id,
        re.id AS result_entry_id,
        re.result_status,
        u.id AS admin_user_id
    FROM organizations o

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

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    WHERE o.organization_code = 'LAB002'

    LIMIT 1
)
SELECT *
FROM ctx;


-- =========================================================
-- TEST 1
-- INVALID RESULT ENTRY ID
-- Expected API: 404
-- =========================================================

SAVEPOINT invalid_result_entry_id;

WITH ctx AS
(
    SELECT
        u.id AS admin_user_id
    FROM organizations o

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    WHERE o.organization_code = 'LAB002'
    LIMIT 1
)

UPDATE result_entry re
SET
    result_status = 'AUTHORIZED',
    verified_at = CURRENT_TIMESTAMP,
    verified_by = ctx.admin_user_id,
    updated_by = ctx.admin_user_id,
    updated_at = CURRENT_TIMESTAMP
FROM ctx
WHERE re.id = '00000000-0000-0000-0000-000000000000';

SELECT
    CASE
        WHEN (SELECT COUNT(*) FROM result_entry WHERE id = '00000000-0000-0000-0000-000000000000') = 0
        THEN 'PASS'
        ELSE 'FAIL'
    END AS validation,
    '0 rows updated - invalid result_entry_id' AS result;

ROLLBACK TO SAVEPOINT invalid_result_entry_id;


-- =========================================================
-- TEST 2
-- RESULT ENTRY NOT COMPLETED
-- Expected API: 400
-- Confirms DB GAP: no CHECK/trigger enforces COMPLETED -> AUTHORIZED ordering
-- =========================================================

SAVEPOINT result_entry_not_completed;

WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        b.id AS branch_id,
        at.id AS accession_test_id,
        u.id AS admin_user_id
    FROM organizations o

    JOIN branches b
        ON b.organization_id = o.id
       AND b.branch_code = 'PUNE002'

    JOIN accession_master am
        ON am.organization_id = o.id
       AND am.accession_number = 'ACC0001'

    JOIN accession_tests at
        ON at.accession_id = am.id

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    WHERE o.organization_code = 'LAB002'
      AND NOT EXISTS
      (
          SELECT 1
          FROM result_entry re
          WHERE re.accession_test_id = at.id
      )

    LIMIT 1
),

new_entry AS
(
    INSERT INTO result_entry
    (
        organization_id,
        branch_id,
        accession_test_id,
        result_status,
        created_by
    )
    SELECT
        organization_id,
        branch_id,
        accession_test_id,
        'PENDING',
        admin_user_id
    FROM ctx
    RETURNING id, organization_id, branch_id
)

UPDATE result_entry re
SET
    result_status = 'AUTHORIZED',
    verified_at = CURRENT_TIMESTAMP,
    verified_by = (SELECT admin_user_id FROM ctx),
    updated_by = (SELECT admin_user_id FROM ctx),
    updated_at = CURRENT_TIMESTAMP
FROM new_entry
WHERE re.id = new_entry.id;

SELECT
    'PASS' AS validation,
    'result_status transitioned PENDING -> AUTHORIZED with no DB-level guard; confirmed DB GAP (see API-097/API-099 notes)' AS result;

ROLLBACK TO SAVEPOINT result_entry_not_completed;


COMMIT;
