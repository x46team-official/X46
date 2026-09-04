BEGIN;



-- Create Result Entry

WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        at.branch_id,
        u.id AS admin_user_id,
        at.id AS accession_test_id
    FROM organizations o

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    JOIN accession_master am
        ON am.organization_id = o.id

    JOIN accession_tests at
        ON at.accession_id = am.id

    WHERE o.organization_code = 'LAB002'
      AND am.accession_number = 'ACC0001'
)

INSERT INTO result_entry
(
    organization_id,
    branch_id,
    accession_test_id,
    result_status,
    entered_at,
    entered_by,
    created_by
)
SELECT
    organization_id,
    branch_id,
    accession_test_id,
    'COMPLETED',
    CURRENT_TIMESTAMP,
    admin_user_id,
    admin_user_id
FROM ctx
WHERE NOT EXISTS
(
    SELECT 1
    FROM result_entry re
    WHERE re.organization_id = ctx.organization_id
      AND re.branch_id = ctx.branch_id
      AND re.accession_test_id = ctx.accession_test_id
);


-- Insert Result Details

WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        re.branch_id,
        u.id AS admin_user_id,
        re.id AS result_entry_id,
        tpm.parameter_id
    FROM organizations o

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    JOIN accession_master am
        ON am.organization_id = o.id

    JOIN accession_tests at
        ON at.accession_id = am.id

    JOIN result_entry re
        ON re.accession_test_id = at.id

    JOIN test_parameter_mapping tpm
        ON tpm.test_id = at.test_id

    WHERE o.organization_code = 'LAB002'
      AND am.accession_number = 'ACC0001'
)

INSERT INTO result_entry_details
(
    organization_id,
    branch_id,
    result_entry_id,
    parameter_id,
    result_value,
    result_flag,
    created_by
)
SELECT
    organization_id,
    branch_id,
    result_entry_id,
    parameter_id,
    '10',
    'NORMAL',
    admin_user_id
FROM ctx
WHERE NOT EXISTS
(
    SELECT 1
    FROM result_entry_details red
    WHERE red.result_entry_id = ctx.result_entry_id
      AND red.parameter_id = ctx.parameter_id
);


-- Update Result Entry

WITH ctx AS
(
    SELECT
        re.id AS result_entry_id,
        u.id AS admin_user_id
    FROM organizations o

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    JOIN accession_master am
        ON am.organization_id = o.id

    JOIN accession_tests at
        ON at.accession_id = am.id

    JOIN result_entry re
        ON re.accession_test_id = at.id

    WHERE o.organization_code = 'LAB002'
      AND am.accession_number = 'ACC0001'
)

UPDATE result_entry re
SET
    result_status = 'COMPLETED',
    entered_at = CURRENT_TIMESTAMP,
    entered_by = ctx.admin_user_id,
    updated_at = CURRENT_TIMESTAMP,
    updated_by = ctx.admin_user_id
FROM ctx
WHERE re.id = ctx.result_entry_id
  AND re.result_status <> 'COMPLETED';


-- Update Accession Test

WITH ctx AS
(
    SELECT
        at.id AS accession_test_id,
        u.id AS admin_user_id
    FROM organizations o

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    JOIN accession_master am
        ON am.organization_id = o.id

    JOIN accession_tests at
        ON at.accession_id = am.id

    WHERE o.organization_code = 'LAB002'
      AND am.accession_number = 'ACC0001'
)

UPDATE accession_tests at
SET
    sample_status = 'COMPLETED',
    updated_at = CURRENT_TIMESTAMP,
    updated_by = ctx.admin_user_id
FROM ctx
WHERE at.id = ctx.accession_test_id
  AND at.sample_status <> 'COMPLETED';

-- --adding parameters 
-- INSERT INTO parameter_master
-- (
--     organization_id,
--     parameter_code,
--     parameter_name,
--     unit,
--     default_reference_range,
--     created_by
-- )
-- SELECT
--     o.id,
--     'HGB',
--     'Hemoglobin',
--     'g/dL',
--     '13.0 - 17.0',
--     u.id
-- FROM organizations o
-- JOIN users u
--     ON u.organization_id = o.id
--    AND u.username = 'admin'
-- WHERE o.organization_code = 'LAB002'
-- AND NOT EXISTS
-- (
--     SELECT 1
--     FROM parameter_master pm
--     WHERE pm.organization_id = o.id
--       AND pm.parameter_code = 'HGB'
-- );

-- INSERT INTO test_parameter_mapping
-- (
--     organization_id,
--     test_id,
--     parameter_id,
--     display_order,
--     unit,
--     reference_range,
--     is_mandatory,
--     created_by
-- )
-- SELECT
--     o.id,
--     tm.id,
--     pm.id,
--     1,
--     'g/dL',
--     '13.0 - 17.0',
--     true,
--     u.id
-- FROM organizations o
-- JOIN users u
--     ON u.organization_id = o.id
--    AND u.username = 'admin'
-- JOIN test_master tm
--     ON tm.organization_id = o.id
--    AND tm.test_code = 'CBC001'
-- JOIN parameter_master pm
--     ON pm.organization_id = o.id
--    AND pm.parameter_code = 'HGB'
-- WHERE o.organization_code = 'LAB002'
-- AND NOT EXISTS
-- (
--     SELECT 1
--     FROM test_parameter_mapping tpm
--     WHERE tpm.organization_id = o.id
--       AND tpm.test_id = tm.id
--       AND tpm.parameter_id = pm.id
-- );

COMMIT;


-- Verification : Result Entry

SELECT
    o.organization_code,
    am.accession_number,
    tm.test_code,
    tm.test_name,
    re.result_status,
    COUNT(red.id) AS parameter_count
FROM result_entry re

JOIN accession_tests at
    ON at.id = re.accession_test_id

JOIN accession_master am
    ON am.id = at.accession_id

JOIN organizations o
    ON o.id = re.organization_id

JOIN test_master tm
    ON tm.id = at.test_id

LEFT JOIN result_entry_details red
    ON red.result_entry_id = re.id

WHERE o.organization_code = 'LAB002'
  AND am.accession_number = 'ACC0001'

GROUP BY
    o.organization_code,
    am.accession_number,
    tm.test_code,
    tm.test_name,
    re.result_status;


-- Verification : Parameter Results

SELECT
    pm.parameter_code,
    pm.parameter_name,
    red.result_value,
    red.result_flag
FROM result_entry_details red

JOIN parameter_master pm
    ON pm.id = red.parameter_id

JOIN result_entry re
    ON re.id = red.result_entry_id

JOIN accession_tests at
    ON at.id = re.accession_test_id

JOIN accession_master am
    ON am.id = at.accession_id

JOIN organizations o
    ON o.id = re.organization_id

WHERE o.organization_code = 'LAB002'
  AND am.accession_number = 'ACC0001'

ORDER BY pm.parameter_code;


-- Status

SELECT
'Result Entry E2E Validation Completed Successfully' AS status;


