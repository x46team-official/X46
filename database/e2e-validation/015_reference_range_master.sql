
-- 015_reference_range_master.sql
-- Demographic-Banded Reference Range Validation

BEGIN;

-- ORGANIZATION

SELECT id AS organization_id
FROM organizations
WHERE organization_code = 'LAB002'
LIMIT 1
\gset

SELECT id AS branch_id
FROM branches
WHERE organization_id = :'organization_id'
  AND branch_code = 'PUNE002'
LIMIT 1
\gset

SELECT id AS admin_user_id
FROM users
WHERE organization_id = :'organization_id'
  AND username = 'admin'
LIMIT 1
\gset


-- HEMOGLOBIN PARAMETER

SELECT id AS hgb_parameter_id
FROM parameter_master
WHERE organization_id = :'organization_id'
  AND branch_id = :'branch_id'
  AND parameter_code = 'HGB'
LIMIT 1
\gset

-- TEST PARAMETER: TOTAL BILIRUBIN

INSERT INTO parameter_master
(
    organization_id,
    branch_id,
    parameter_code,
    parameter_name,
    unit,
    default_reference_range,
    created_by
)
SELECT
    :'organization_id',
    :'branch_id',
    'TBIL',
    'Total Bilirubin',
    'mg/dL',
    '0.3 - 1.2',
    :'admin_user_id'
WHERE NOT EXISTS
(
    SELECT 1
    FROM parameter_master
    WHERE organization_id = :'organization_id'
      AND branch_id = :'branch_id'
      AND parameter_code = 'TBIL'
);


SELECT id AS tbil_parameter_id
FROM parameter_master
WHERE organization_id = :'organization_id'
  AND branch_id = :'branch_id'
  AND parameter_code = 'TBIL'
LIMIT 1
\gset


-- 1. HGB - ADULT MALE CURRENT
-- 18-120 YEARS
-- 13.0 - 17.0

INSERT INTO reference_range_master
(
    organization_id,
    branch_id,
    parameter_id,
    gender,
    age_min,
    age_max,
    age_unit,
    pregnancy_flag,
    reference_min,
    reference_max,
    reference_range,
    critical_low,
    critical_high,
    effective_from,
    effective_to,
    created_by
)
SELECT
    :'organization_id',
    :'branch_id',
    :'hgb_parameter_id',
    'MALE',
    18,
    120,
    'YEARS',
    FALSE,
    13.0,
    17.0,
    '13.0 - 17.0',
    7.0,
    20.0,
    DATE '2020-01-01',
    NULL,
    :'admin_user_id'
WHERE NOT EXISTS
(
    SELECT 1
    FROM reference_range_master r
    WHERE r.organization_id = :'organization_id'
      AND r.branch_id = :'branch_id'
      AND r.parameter_id = :'hgb_parameter_id'
      AND r.gender = 'MALE'
      AND r.age_min = 18
      AND r.age_max = 120
      AND r.age_unit = 'YEARS'
      AND r.pregnancy_flag = FALSE
      AND r.effective_from = DATE '2020-01-01'
);

-- 2. HGB - ADULT MALE HISTORICAL
-- 18-120 YEARS
-- 13.5 - 17.5
-- 2015-2019

INSERT INTO reference_range_master
(
    organization_id,
    branch_id,
    parameter_id,
    gender,
    age_min,
    age_max,
    age_unit,
    pregnancy_flag,
    reference_min,
    reference_max,
    reference_range,
    critical_low,
    critical_high,
    effective_from,
    effective_to,
    created_by
)
SELECT
    :'organization_id',
    :'branch_id',
    :'hgb_parameter_id',
    'MALE',
    18,
    120,
    'YEARS',
    FALSE,
    13.5,
    17.5,
    '13.5 - 17.5',
    7.0,
    20.0,
    DATE '2015-01-01',
    DATE '2019-12-31',
    :'admin_user_id'
WHERE NOT EXISTS
(
    SELECT 1
    FROM reference_range_master r
    WHERE r.organization_id = :'organization_id'
      AND r.branch_id = :'branch_id'
      AND r.parameter_id = :'hgb_parameter_id'
      AND r.gender = 'MALE'
      AND r.age_min = 18
      AND r.age_max = 120
      AND r.age_unit = 'YEARS'
      AND r.pregnancy_flag = FALSE

      -- Effective-date overlap protection
      AND r.effective_from <= DATE '2019-12-31'
      AND (
            r.effective_to IS NULL
            OR r.effective_to >= DATE '2015-01-01'
          )
);



-- 3. HGB - ADULT FEMALE NON-PREGNANT

INSERT INTO reference_range_master
(
    organization_id,
    branch_id,
    parameter_id,
    gender,
    age_min,
    age_max,
    age_unit,
    pregnancy_flag,
    reference_min,
    reference_max,
    reference_range,
    critical_low,
    critical_high,
    effective_from,
    effective_to,
    created_by
)
SELECT
    :'organization_id',
    :'branch_id',
    :'hgb_parameter_id',
    'FEMALE',
    18,
    120,
    'YEARS',
    FALSE,
    12.0,
    15.5,
    '12.0 - 15.5',
    7.0,
    20.0,
    DATE '2020-01-01',
    NULL,
    :'admin_user_id'
WHERE NOT EXISTS
(
    SELECT 1
    FROM reference_range_master r
    WHERE r.organization_id = :'organization_id'
      AND r.branch_id = :'branch_id'
      AND r.parameter_id = :'hgb_parameter_id'
      AND r.gender = 'FEMALE'
      AND r.age_min = 18
      AND r.age_max = 120
      AND r.age_unit = 'YEARS'
      AND r.pregnancy_flag = FALSE
      AND r.effective_from = DATE '2020-01-01'
);



-- 4. HGB - PREGNANCY

INSERT INTO reference_range_master
(
    organization_id,
    branch_id,
    parameter_id,
    gender,
    age_min,
    age_max,
    age_unit,
    pregnancy_flag,
    reference_min,
    reference_max,
    reference_range,
    critical_low,
    critical_high,
    effective_from,
    effective_to,
    created_by
)
SELECT
    :'organization_id',
    :'branch_id',
    :'hgb_parameter_id',
    'FEMALE',
    18,
    45,
    'YEARS',
    TRUE,
    11.0,
    14.0,
    '11.0 - 14.0',
    7.0,
    20.0,
    DATE '2020-01-01',
    NULL,
    :'admin_user_id'
WHERE NOT EXISTS
(
    SELECT 1
    FROM reference_range_master r
    WHERE r.organization_id = :'organization_id'
      AND r.branch_id = :'branch_id'
      AND r.parameter_id = :'hgb_parameter_id'
      AND r.gender = 'FEMALE'
      AND r.age_min = 18
      AND r.age_max = 45
      AND r.age_unit = 'YEARS'
      AND r.pregnancy_flag = TRUE
      AND r.effective_from = DATE '2020-01-01'
);


-- 5. HGB - CHILD

INSERT INTO reference_range_master
(
    organization_id,
    branch_id,
    parameter_id,
    gender,
    age_min,
    age_max,
    age_unit,
    pregnancy_flag,
    reference_min,
    reference_max,
    reference_range,
    critical_low,
    critical_high,
    effective_from,
    effective_to,
    created_by
)
SELECT
    :'organization_id',
    :'branch_id',
    :'hgb_parameter_id',
    'ANY',
    1,
    17,
    'YEARS',
    FALSE,
    11.0,
    14.0,
    '11.0 - 14.0',
    6.0,
    18.0,
    DATE '2020-01-01',
    NULL,
    :'admin_user_id'
WHERE NOT EXISTS
(
    SELECT 1
    FROM reference_range_master r
    WHERE r.organization_id = :'organization_id'
      AND r.branch_id = :'branch_id'
      AND r.parameter_id = :'hgb_parameter_id'
      AND r.gender = 'ANY'
      AND r.age_min = 1
      AND r.age_max = 17
      AND r.age_unit = 'YEARS'
      AND r.pregnancy_flag = FALSE
      AND r.effective_from = DATE '2020-01-01'
);

-- 6. TOTAL BILIRUBIN - NEWBORN
-- 0-28 DAYS

INSERT INTO reference_range_master
(
    organization_id,
    branch_id,
    parameter_id,
    gender,
    age_min,
    age_max,
    age_unit,
    pregnancy_flag,
    reference_min,
    reference_max,
    reference_range,
    critical_low,
    critical_high,
    effective_from,
    effective_to,
    created_by
)
SELECT
    :'organization_id',
    :'branch_id',
    :'tbil_parameter_id',
    'ANY',
    0,
    28,
    'DAYS',
    FALSE,
    1.0,
    12.0,
    '1.0 - 12.0',
    0.0,
    20.0,
    DATE '2020-01-01',
    NULL,
    :'admin_user_id'
WHERE NOT EXISTS
(
    SELECT 1
    FROM reference_range_master r
    WHERE r.organization_id = :'organization_id'
      AND r.branch_id = :'branch_id'
      AND r.parameter_id = :'tbil_parameter_id'
      AND r.gender = 'ANY'
      AND r.age_min = 0
      AND r.age_max = 28
      AND r.age_unit = 'DAYS'
      AND r.pregnancy_flag = FALSE
      AND r.effective_from = DATE '2020-01-01'
);

-- ADULT MALE CURRENT RANGE
-- Expected: 13.0 - 17.0

SELECT
    reference_min,
    reference_max,
    reference_range
FROM reference_range_master
WHERE organization_id = :'organization_id'
  AND branch_id = :'branch_id'
  AND parameter_id = :'hgb_parameter_id'
  AND gender = 'MALE'
  AND pregnancy_flag = FALSE
  AND age_unit = 'YEARS'
  AND 30 BETWEEN age_min AND age_max
  AND effective_from <= CURRENT_DATE
  AND (
        effective_to IS NULL
        OR effective_to >= CURRENT_DATE
      )
ORDER BY effective_from DESC
LIMIT 1;

-- ADULT FEMALE CURRENT RANGE
-- Expected: 12.0 - 15.5

SELECT
    reference_min,
    reference_max,
    reference_range
FROM reference_range_master
WHERE organization_id = :'organization_id'
  AND branch_id = :'branch_id'
  AND parameter_id = :'hgb_parameter_id'
  AND gender = 'FEMALE'
  AND pregnancy_flag = FALSE
  AND age_unit = 'YEARS'
  AND 30 BETWEEN age_min AND age_max
  AND effective_from <= CURRENT_DATE
  AND (
        effective_to IS NULL
        OR effective_to >= CURRENT_DATE
      )
ORDER BY effective_from DESC
LIMIT 1;

-- CHILD RANGE
-- Expected: 11.0 - 14.0

SELECT
    reference_min,
    reference_max,
    reference_range
FROM reference_range_master
WHERE organization_id = :'organization_id'
  AND branch_id = :'branch_id'
  AND parameter_id = :'hgb_parameter_id'
  AND gender = 'ANY'
  AND pregnancy_flag = FALSE
  AND age_unit = 'YEARS'
  AND 8 BETWEEN age_min AND age_max
  AND effective_from <= CURRENT_DATE
  AND (
        effective_to IS NULL
        OR effective_to >= CURRENT_DATE
      )
ORDER BY effective_from DESC
LIMIT 1;

-- PREGNANCY RANGE
-- Expected: 11.0 - 14.0

SELECT
    reference_min,
    reference_max,
    reference_range
FROM reference_range_master
WHERE organization_id = :'organization_id'
  AND branch_id = :'branch_id'
  AND parameter_id = :'hgb_parameter_id'
  AND gender = 'FEMALE'
  AND pregnancy_flag = TRUE
  AND age_unit = 'YEARS'
  AND 28 BETWEEN age_min AND age_max
  AND effective_from <= CURRENT_DATE
  AND (
        effective_to IS NULL
        OR effective_to >= CURRENT_DATE
      )
ORDER BY effective_from DESC
LIMIT 1;


-- NEWBORN BILIRUBIN
-- Expected: 1.0 - 12.0

SELECT
    reference_min,
    reference_max,
    reference_range
FROM reference_range_master
WHERE organization_id = :'organization_id'
  AND branch_id = :'branch_id'
  AND parameter_id = :'tbil_parameter_id'
  AND gender = 'ANY'
  AND pregnancy_flag = FALSE
  AND age_unit = 'DAYS'
  AND 3 BETWEEN age_min AND age_max
  AND effective_from <= CURRENT_DATE
  AND (
        effective_to IS NULL
        OR effective_to >= CURRENT_DATE
      )
ORDER BY effective_from DESC
LIMIT 1;

-- HISTORICAL EFFECTIVE-DATE RANGE
-- Expected: 13.5 - 17.5
-- Date: 2017-06-01

SELECT
    reference_min,
    reference_max,
    reference_range,
    effective_from,
    effective_to
FROM reference_range_master
WHERE organization_id = :'organization_id'
  AND branch_id = :'branch_id'
  AND parameter_id = :'hgb_parameter_id'
  AND gender = 'MALE'
  AND pregnancy_flag = FALSE
  AND age_unit = 'YEARS'
  AND 30 BETWEEN age_min AND age_max
  AND effective_from <= DATE '2017-06-01'
  AND (
        effective_to IS NULL
        OR effective_to >= DATE '2017-06-01'
      )
ORDER BY effective_from DESC
LIMIT 1;

-- This INSERT MUST FAIL.
--
-- NOTE: psql does not perform :'var' substitution inside dollar-quoted
-- ($$ ... $$) bodies, so the IDs are re-resolved here via plain SQL lookups
-- rather than relying on the outer \gset variables.

DO $$
DECLARE
    v_organization_id UUID;
    v_branch_id UUID;
    v_hgb_parameter_id UUID;
    v_admin_user_id UUID;
BEGIN

    SELECT id INTO v_organization_id
    FROM organizations
    WHERE organization_code = 'LAB002';

    SELECT id INTO v_branch_id
    FROM branches
    WHERE organization_id = v_organization_id
      AND branch_code = 'PUNE002';

    SELECT id INTO v_hgb_parameter_id
    FROM parameter_master
    WHERE organization_id = v_organization_id
      AND branch_id = v_branch_id
      AND parameter_code = 'HGB';

    SELECT id INTO v_admin_user_id
    FROM users
    WHERE organization_id = v_organization_id
      AND branch_id = v_branch_id
      AND username = 'admin';

    BEGIN

        INSERT INTO reference_range_master
        (
            organization_id,
            branch_id,
            parameter_id,
            gender,
            age_min,
            age_max,
            age_unit,
            pregnancy_flag,
            reference_min,
            reference_max,
            reference_range,
            critical_low,
            critical_high,
            effective_from,
            effective_to,
            created_by
        )
        VALUES
        (
            v_organization_id,
            v_branch_id,
            v_hgb_parameter_id,
            'MALE',
            18,
            120,
            'YEARS',
            FALSE,
            13.2,
            17.2,
            '13.2 - 17.2',
            7.0,
            20.0,
            DATE '2021-06-01',
            NULL,
            v_admin_user_id
        );

        RAISE EXCEPTION
            'MD021 overlap test failed: overlapping row was accepted';

    EXCEPTION
        WHEN OTHERS THEN

            IF SQLERRM LIKE '%overlapping demographic band%' THEN

                RAISE NOTICE
                    'MD021 overlap protection PASS: %',
                    SQLERRM;

            ELSE

                RAISE;

            END IF;

    END;

END
$$;

-- VERIFY CURRENT MASTER DATA
SELECT
    gender,
    pregnancy_flag,
    age_min,
    age_max,
    age_unit,
    reference_min,
    reference_max,
    effective_from,
    effective_to
FROM reference_range_master
WHERE organization_id = :'organization_id'
  AND branch_id = :'branch_id'
  AND parameter_id = :'hgb_parameter_id'
ORDER BY
    gender,
    pregnancy_flag,
    age_min,
    effective_from;

-- VERIFY ADULT MALE COUNT
--
-- Expected:
-- 2 rows
-- 2015-2019
-- 2020-current


SELECT
    gender,
    pregnancy_flag,
    COUNT(*) AS band_count
FROM reference_range_master
WHERE organization_id = :'organization_id'
  AND branch_id = :'branch_id'
  AND parameter_id = :'hgb_parameter_id'
  AND gender = 'MALE'
  AND pregnancy_flag = FALSE
GROUP BY
    gender,
    pregnancy_flag;

-- VERIFY TOTAL BILIRUBIN


SELECT
    parameter_code,
    parameter_name,
    unit,
    default_reference_range
FROM parameter_master
WHERE organization_id = :'organization_id'
  AND branch_id = :'branch_id'
  AND parameter_code = 'TBIL';


COMMIT;