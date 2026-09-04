-- Verify Before Update

SELECT
    qc_level,
    lot_number,
    manufacturer,
    mean_value,
    standard_deviation,
    acceptable_min,
    acceptable_max,
    status
FROM qc_master
LIMIT 1;

-- Update QC Material

UPDATE qc_master
SET
    manufacturer = 'Bio-Rad Updated',
    mean_value = 15.250,
    standard_deviation = 0.850,
    acceptable_min = 14.400,
    acceptable_max = 16.100,
    remarks = 'QC Material Updated - Dry Run',
    updated_at = CURRENT_TIMESTAMP,
    updated_by = (SELECT id FROM users LIMIT 1)
WHERE id =
(
    SELECT id
    FROM qc_master
    LIMIT 1
);

-- Verify

SELECT
    manufacturer,
    mean_value,
    standard_deviation,
    acceptable_min,
    acceptable_max,
    remarks
FROM qc_master
WHERE id =
(
    SELECT id
    FROM qc_master
    LIMIT 1
);

-- Verify Before Update

SELECT
    qc_level,
    lot_number,
    status
FROM qc_master
LIMIT 1;

-- Deactivate QC Material

UPDATE qc_master
SET
    status = 'INACTIVE',
    remarks = 'QC Material Deactivated - Dry Run',
    updated_at = CURRENT_TIMESTAMP,
    updated_by = (SELECT id FROM users LIMIT 1)
WHERE id =
(
    SELECT id
    FROM qc_master
    LIMIT 1
);

-- Verify

SELECT
    qc_level,
    lot_number,
    status
FROM qc_master
WHERE id =
(
    SELECT id
    FROM qc_master
    LIMIT 1
);

-- Activate QC Material

UPDATE qc_master
SET
    status = 'ACTIVE',
    remarks = 'QC Material Activated - Dry Run',
    updated_at = CURRENT_TIMESTAMP,
    updated_by = (SELECT id FROM users LIMIT 1)
WHERE id =
(
    SELECT id
    FROM qc_master
    LIMIT 1
);

-- Verify

SELECT
    qc_level,
    lot_number,
    status
FROM qc_master
WHERE id =
(
    SELECT id
    FROM qc_master
    LIMIT 1
);

-- Expected:
-- Duplicate QC Material should fail because of
-- UNIQUE (
-- organization_id,
-- branch_id,
-- instrument_id,
-- test_id,
-- parameter_id,
-- qc_level,
-- lot_number
-- )

INSERT INTO qc_master
(
    organization_id,
    branch_id,
    instrument_id,
    test_id,
    parameter_id,
    qc_level,
    lot_number,
    manufacturer,
    mean_value,
    standard_deviation,
    acceptable_min,
    acceptable_max,
    created_by
)
SELECT
    organization_id,
    branch_id,
    instrument_id,
    test_id,
    parameter_id,
    qc_level,
    lot_number,
    manufacturer,
    mean_value,
    standard_deviation,
    acceptable_min,
    acceptable_max,
    (SELECT id FROM users LIMIT 1)
FROM qc_master
LIMIT 1;

-- Expected:
-- Duplicate QC Material should fail because of


INSERT INTO qc_master
(
    organization_id,
    branch_id,
    instrument_id,
    test_id,
    parameter_id,
    qc_level,
    lot_number,
    manufacturer,
    mean_value,
    standard_deviation,
    acceptable_min,
    acceptable_max,
    created_by
)
SELECT
    organization_id,
    branch_id,
    instrument_id,
    test_id,
    parameter_id,
    qc_level,
    lot_number,
    manufacturer,
    mean_value,
    standard_deviation,
    acceptable_min,
    acceptable_max,
    (SELECT id FROM users LIMIT 1)
FROM qc_master
LIMIT 1;

-- Verify Before Update

SELECT
    actual_value,
    z_score,
    result_status,
    rule_triggered,
    remarks
FROM qc_run_log
LIMIT 1;

-- Update QC Result

UPDATE qc_run_log
SET
    actual_value = actual_value + 0.200,
    z_score = 0.850,
    remarks = 'QC Result Updated - Dry Run',
    updated_at = CURRENT_TIMESTAMP,
    updated_by = (SELECT id FROM users LIMIT 1)
ORDER BY created_at DESC
LIMIT 1

-- Verify

SELECT
    actual_value,
    z_score,
    remarks
FROM qc_run_log
WHERE id =
(
    SELECT id
    FROM qc_run_log
    LIMIT 1
);

-- Verify Before Update

SELECT
    result_status,
    rule_triggered
FROM qc_run_log
LIMIT 1;

-- Accept QC Run

UPDATE qc_run_log
SET
    result_status = 'PASS',
    rule_triggered = NULL,
    remarks = 'QC Accepted - Dry Run',
    updated_at = CURRENT_TIMESTAMP,
    updated_by = (SELECT id FROM users LIMIT 1)
WHERE id =
(
    SELECT id
    FROM qc_run_log
    LIMIT 1
);

-- Verify

SELECT
    result_status,
    rule_triggered,
    remarks
FROM qc_run_log
WHERE id =
(
    SELECT id
    FROM qc_run_log
    LIMIT 1
);

-- Verify Before Update

SELECT
    result_status,
    rule_triggered
FROM qc_run_log
LIMIT 1;

-- Reject QC Run

UPDATE qc_run_log
SET
    result_status = 'FAIL',
    rule_triggered = '1-2S',
    remarks = 'QC Rejected - Dry Run',
    updated_at = CURRENT_TIMESTAMP,
    updated_by = (SELECT id FROM users LIMIT 1)
WHERE id =
(
    SELECT id
    FROM qc_run_log
    ORDER BY created_at DESC
    LIMIT 1
);

SELECT
    result_status,
    rule_triggered,
    remarks
FROM qc_run_log
WHERE id =
(
    SELECT id
    FROM qc_run_log
    ORDER BY created_at DESC
    LIMIT 1
);