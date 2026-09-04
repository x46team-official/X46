
-- 017_payment_mode_master.sql

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

SELECT id AS payment_id, payment_mode AS original_payment_mode
FROM payment
WHERE organization_id = :'organization_id'
  AND branch_id = :'branch_id'
ORDER BY created_at
LIMIT 1
\gset


SELECT payment_mode_code, payment_mode_name, sort_order
FROM payment_mode_master
WHERE organization_id = :'organization_id'
  AND branch_id = :'branch_id'
ORDER BY sort_order;

UPDATE payment
SET payment_mode = 'CASH', updated_by = :'admin_user_id', updated_at = CURRENT_TIMESTAMP
WHERE id = :'payment_id';

SELECT payment_mode FROM payment WHERE id = :'payment_id';


UPDATE payment
SET payment_mode = 'CARD', updated_by = :'admin_user_id', updated_at = CURRENT_TIMESTAMP
WHERE id = :'payment_id';

SELECT payment_mode FROM payment WHERE id = :'payment_id';


UPDATE payment
SET payment_mode = 'UPI', updated_by = :'admin_user_id', updated_at = CURRENT_TIMESTAMP
WHERE id = :'payment_id';

SELECT payment_mode FROM payment WHERE id = :'payment_id';


UPDATE payment
SET payment_mode = 'WALLET', updated_by = :'admin_user_id', updated_at = CURRENT_TIMESTAMP
WHERE id = :'payment_id';

SELECT payment_mode FROM payment WHERE id = :'payment_id';


UPDATE payment
SET payment_mode = 'CORPORATE_CREDIT', updated_by = :'admin_user_id', updated_at = CURRENT_TIMESTAMP
WHERE id = :'payment_id';

SELECT payment_mode FROM payment WHERE id = :'payment_id';

SAVEPOINT sp_invalid_payment_mode;

UPDATE payment
SET payment_mode = 'BITCOIN'
WHERE id = :'payment_id';

ROLLBACK TO SAVEPOINT sp_invalid_payment_mode;

-- Verify the invalid update was rejected (mode still CORPORATE_CREDIT)
SELECT payment_mode FROM payment WHERE id = :'payment_id';

-- Restore original mode so this validation script does not permanently
-- alter existing demo/e2e data.
UPDATE payment
SET payment_mode = :'original_payment_mode', updated_by = :'admin_user_id', updated_at = CURRENT_TIMESTAMP
WHERE id = :'payment_id';

SELECT payment_mode FROM payment WHERE id = :'payment_id';

COMMIT;
