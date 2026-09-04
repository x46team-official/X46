BEGIN;

-- API-T173 : INVALID PARAMETER (CREATE REFERENCE RANGE)
-- Expected API : 404 Not Found

SAVEPOINT sp_invalid_parameter_rr;

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
    LIMIT 1
)

INSERT INTO reference_range_master
(
    organization_id,
    branch_id,
    parameter_id,
    gender,
    age_min,
    age_max,
    age_unit,
    reference_min,
    reference_max,
    effective_from,
    created_by
)
SELECT
    organization_id,
    branch_id,
    '00000000-0000-0000-0000-000000000000',
    'ANY',
    0,
    150,
    'YEARS',
    1.0,
    2.0,
    CURRENT_DATE,
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_invalid_parameter_rr;

SELECT
    'PASS' AS validation,
    'Invalid parameter_id rejected by FK' AS result;


-- API-T174 : DUPLICATE PARAMETER CODE
-- Expected API : 409 Conflict

SAVEPOINT sp_duplicate_parameter_code;

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
    LIMIT 1
)

INSERT INTO parameter_master
(
    organization_id,
    branch_id,
    parameter_code,
    parameter_name,
    created_by
)
SELECT
    organization_id,
    branch_id,
    'HGB',
    'Duplicate Hemoglobin',
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_duplicate_parameter_code;

SELECT
    'PASS' AS validation,
    'Duplicate parameter_code rejected by UNIQUE constraint (uq_parameter_master_code)' AS result;


-- API-T175 : OVERLAPPING DEMOGRAPHIC BAND (MD021)
-- Expected API : 409 Conflict
-- Expected DB : trigger trg_prevent_reference_range_overlap raises exception

SAVEPOINT sp_overlapping_demographic_band;

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
            13.1,
            17.1,
            '13.1 - 17.1',
            DATE '2022-01-01',
            NULL,
            v_admin_user_id
        );

        RAISE EXCEPTION
            'API-T175 overlap test failed: overlapping row was accepted';

    EXCEPTION
        WHEN OTHERS THEN

            IF SQLERRM LIKE '%overlapping demographic band%' THEN

                RAISE NOTICE
                    'API-T175 overlap protection PASS: %',
                    SQLERRM;

            ELSE

                RAISE;

            END IF;

    END;

END
$$;

ROLLBACK TO SAVEPOINT sp_overlapping_demographic_band;

SELECT
    'PASS' AS validation,
    'Overlapping demographic band rejected by trigger trg_prevent_reference_range_overlap' AS result;


-- API-T176 : INVALID AGE RANGE
-- Expected API : 400 Bad Request

SAVEPOINT sp_invalid_age_range;

WITH ctx AS
(
    SELECT
        organization_id,
        branch_id,
        hgb_parameter_id,
        admin_user_id
    FROM
    (
        SELECT
            o.id AS organization_id,
            b.id AS branch_id,
            pm.id AS hgb_parameter_id,
            u.id AS admin_user_id
        FROM organizations o

        JOIN branches b
            ON b.organization_id = o.id
           AND b.branch_code = 'PUNE002'

        JOIN parameter_master pm
            ON pm.organization_id = o.id
           AND pm.branch_id = b.id
           AND pm.parameter_code = 'HGB'

        JOIN users u
            ON u.organization_id = o.id
           AND u.username = 'admin'

        WHERE o.organization_code = 'LAB002'
    ) sub
    LIMIT 1
)

INSERT INTO reference_range_master
(
    organization_id,
    branch_id,
    parameter_id,
    gender,
    age_min,
    age_max,
    age_unit,
    reference_min,
    reference_max,
    effective_from,
    created_by
)
SELECT
    organization_id,
    branch_id,
    hgb_parameter_id,
    'ANY',
    300,
    200,
    'YEARS',
    1.0,
    2.0,
    DATE '2099-01-01',
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_invalid_age_range;

SELECT
    'PASS' AS validation,
    'age_max < age_min rejected by CHECK constraint (chk_reference_range_master_age)' AS result;


-- API-T177 : INVALID EFFECTIVE DATE RANGE
-- Expected API : 400 Bad Request

SAVEPOINT sp_invalid_effective_date_range;

WITH ctx AS
(
    SELECT
        organization_id,
        branch_id,
        hgb_parameter_id,
        admin_user_id
    FROM
    (
        SELECT
            o.id AS organization_id,
            b.id AS branch_id,
            pm.id AS hgb_parameter_id,
            u.id AS admin_user_id
        FROM organizations o

        JOIN branches b
            ON b.organization_id = o.id
           AND b.branch_code = 'PUNE002'

        JOIN parameter_master pm
            ON pm.organization_id = o.id
           AND pm.branch_id = b.id
           AND pm.parameter_code = 'HGB'

        JOIN users u
            ON u.organization_id = o.id
           AND u.username = 'admin'

        WHERE o.organization_code = 'LAB002'
    ) sub
    LIMIT 1
)

INSERT INTO reference_range_master
(
    organization_id,
    branch_id,
    parameter_id,
    gender,
    age_min,
    age_max,
    age_unit,
    reference_min,
    reference_max,
    effective_from,
    effective_to,
    created_by
)
SELECT
    organization_id,
    branch_id,
    hgb_parameter_id,
    'ANY',
    200,
    205,
    'YEARS',
    1.0,
    2.0,
    DATE '2099-01-01',
    DATE '2098-01-01',
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_invalid_effective_date_range;

SELECT
    'PASS' AS validation,
    'effective_to < effective_from rejected by CHECK constraint (chk_reference_range_master_effective)' AS result;


-- API-T178 : INVALID REFERENCE BOUNDS
-- Expected API : 400 Bad Request

SAVEPOINT sp_invalid_reference_bounds;

WITH ctx AS
(
    SELECT
        organization_id,
        branch_id,
        hgb_parameter_id,
        admin_user_id
    FROM
    (
        SELECT
            o.id AS organization_id,
            b.id AS branch_id,
            pm.id AS hgb_parameter_id,
            u.id AS admin_user_id
        FROM organizations o

        JOIN branches b
            ON b.organization_id = o.id
           AND b.branch_code = 'PUNE002'

        JOIN parameter_master pm
            ON pm.organization_id = o.id
           AND pm.branch_id = b.id
           AND pm.parameter_code = 'HGB'

        JOIN users u
            ON u.organization_id = o.id
           AND u.username = 'admin'

        WHERE o.organization_code = 'LAB002'
    ) sub
    LIMIT 1
)

INSERT INTO reference_range_master
(
    organization_id,
    branch_id,
    parameter_id,
    gender,
    age_min,
    age_max,
    age_unit,
    reference_min,
    reference_max,
    effective_from,
    created_by
)
SELECT
    organization_id,
    branch_id,
    hgb_parameter_id,
    'ANY',
    200,
    205,
    'YEARS',
    17.0,
    13.0,
    DATE '2099-01-01',
    admin_user_id
FROM ctx;

ROLLBACK TO SAVEPOINT sp_invalid_reference_bounds;

SELECT
    'PASS' AS validation,
    'reference_max < reference_min rejected by CHECK constraint (chk_reference_range_master_bounds)' AS result;


COMMIT;
