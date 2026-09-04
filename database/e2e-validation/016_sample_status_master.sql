
-- 016_sample_status_master.sql

BEGIN;

SELECT id AS organization_id
FROM organizations
WHERE organization_code = 'LAB002'
\gset

SELECT id AS branch_id
FROM branches
WHERE organization_id = :'organization_id'
  AND branch_code = 'PUNE002'
\gset

SELECT id AS admin_user_id
FROM users
WHERE organization_id = :'organization_id'
  AND username = 'admin'
\gset

SELECT id AS accession_test_id, sample_status AS original_sample_status
FROM accession_tests
WHERE organization_id = :'organization_id'
  AND branch_id = :'branch_id'
ORDER BY created_at
LIMIT 1
\gset


SELECT sample_status_code, sample_status_name, sort_order, is_terminal
FROM sample_status_master
WHERE organization_id = :'organization_id'
  AND branch_id = :'branch_id'
ORDER BY sort_order;

UPDATE accession_tests
SET sample_status = 'PENDING', updated_by = :'admin_user_id', updated_at = CURRENT_TIMESTAMP
WHERE id = :'accession_test_id';

SELECT sample_status FROM accession_tests WHERE id = :'accession_test_id';


UPDATE accession_tests
SET sample_status = 'COLLECTED', updated_by = :'admin_user_id', updated_at = CURRENT_TIMESTAMP
WHERE id = :'accession_test_id';

SELECT sample_status FROM accession_tests WHERE id = :'accession_test_id';


UPDATE accession_tests
SET sample_status = 'RECEIVED', updated_by = :'admin_user_id', updated_at = CURRENT_TIMESTAMP
WHERE id = :'accession_test_id';

SELECT sample_status FROM accession_tests WHERE id = :'accession_test_id';


UPDATE accession_tests
SET sample_status = 'IN_TRANSIT', updated_by = :'admin_user_id', updated_at = CURRENT_TIMESTAMP
WHERE id = :'accession_test_id';

SELECT sample_status FROM accession_tests WHERE id = :'accession_test_id';


UPDATE accession_tests
SET sample_status = 'RECOLLECTION_REQUESTED', updated_by = :'admin_user_id', updated_at = CURRENT_TIMESTAMP
WHERE id = :'accession_test_id';

SELECT sample_status FROM accession_tests WHERE id = :'accession_test_id';


SAVEPOINT sp_invalid_sample_status;

UPDATE accession_tests
SET sample_status = 'NOT_A_REAL_STATUS'
WHERE id = :'accession_test_id';

ROLLBACK TO SAVEPOINT sp_invalid_sample_status;


SELECT sample_status FROM accession_tests WHERE id = :'accession_test_id';


-- alter existing demo/e2e data.
UPDATE accession_tests
SET sample_status = :'original_sample_status', updated_by = :'admin_user_id', updated_at = CURRENT_TIMESTAMP
WHERE id = :'accession_test_id';

SELECT sample_status FROM accession_tests WHERE id = :'accession_test_id';

COMMIT;
