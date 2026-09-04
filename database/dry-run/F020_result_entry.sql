-- INSERT INTO result_entry
-- (
--     organization_id,
--     accession_test_id,
--     result_status,
--     entered_at,
--     entered_by,
--     remarks,
--     created_by
-- )
-- SELECT
--     at.organization_id,
--     at.id,
--     'PENDING',
--     CURRENT_TIMESTAMP,
--     (SELECT id FROM users LIMIT 1),
--     'Dry Run Result Entry',
--     (SELECT id FROM users LIMIT 1)
-- FROM accession_tests at
-- LIMIT 1
-- ON CONFLICT (organization_id, accession_test_id)
-- DO NOTHING;



-- SELECT
--     re.id,
--     am.accession_number,
--     tm.test_name,
--     re.result_status,
--     re.entered_at,
--     re.remarks
-- FROM result_entry re
-- JOIN accession_tests at
--     ON at.id = re.accession_test_id
-- JOIN accession_master am
--     ON am.id = at.accession_id
-- JOIN test_master tm
--     ON tm.id = at.test_id;

-- UPDATE

UPDATE result_entry
SET
    result_status = 'IN_PROGRESS',
    remarks = 'Updated Dry Run',
    updated_at = CURRENT_TIMESTAMP,
    updated_by = (SELECT id FROM users LIMIT 1)
WHERE accession_test_id =
(
    SELECT id
    FROM accession_tests
    LIMIT 1
);



SELECT
    result_status,
    remarks
FROM result_entry
WHERE accession_test_id =
(
    SELECT id
    FROM accession_tests
    LIMIT 1
);

-- DELETE (Keep Commented)

-- DELETE FROM result_entry
-- WHERE accession_test_id =
-- (
--     SELECT id
--     FROM accession_tests
--     LIMIT 1
-- );