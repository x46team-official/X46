-- INSERT INTO dashboard_cache
-- (
--   organization_id,
--   branch_id,
--   dashboard_key,
--   dashboard_value,
--   created_by

-- )

-- select 
--   o.id,
--   b.id,
--   'TODAY SUMMARY',
--   '{
--   "today_patients": 42,
--         "today_tests": 136,
--         "pending_results": 18,
--         "authorized_reports": 95,
--         "today_collection": 85600
--   }'::jsonb,
--   u.id
-- FROM organizations o
-- JOIN branches b
--  on b.organization_id =o.id

--  CROSS JOIN users u

--  LIMIT 1;


 UPDATE dashboard_cache
SET
    dashboard_value = '{
        "today_patients": 45,
        "today_tests": 142,
        "pending_results": 15,
        "authorized_reports": 102,
        "today_collection": 91200
    }'::jsonb,
    generated_at = CURRENT_TIMESTAMP,
    updated_at = CURRENT_TIMESTAMP
WHERE dashboard_key = 'TODAY SUMMARY'
AND deleted_at IS NULL;