-- Verify Before Update

SELECT
    accession_number,
    priority,
    status,
    remarks
FROM accession_master
LIMIT 1;

-- Update Status

UPDATE accession_master
SET
    status = 'PROCESSING',
    remarks = 'Status Updated - Dry Run',
    updated_at = CURRENT_TIMESTAMP,
    updated_by = (SELECT id FROM users LIMIT 1)
WHERE id =
(
    SELECT id
    FROM accession_master
    LIMIT 1
);

-- Verify After Update

SELECT
    accession_number,
    status,
    remarks
FROM accession_master
WHERE id =
(
    SELECT id
    FROM accession_master
    LIMIT 1
);

-- Verify Before Update

SELECT
    accession_number,
    priority
FROM accession_master
LIMIT 1;

-- Update Priority

UPDATE accession_master
SET
    priority = 'URGENT',
    remarks = 'Priority Updated - Dry Run',
    updated_at = CURRENT_TIMESTAMP,
    updated_by = (SELECT id FROM users LIMIT 1)
WHERE id =
(
    SELECT id
    FROM accession_master
    LIMIT 1
);

-- Verify After Update

SELECT
    accession_number,
    priority,
    remarks
FROM accession_master
WHERE id =
(
    SELECT id
    FROM accession_master
    LIMIT 1
);

SELECT
    accession_id,
    test_id,
    barcode,
    barcode_status,
    remarks
FROM accession_tests
LIMIT 1;

UPDATE accession_tests
SET
    barcode_status = 'PRINTED',
    remarks = 'Barcode Printed - Dry Run',
    updated_at = CURRENT_TIMESTAMP,
    updated_by = (SELECT id FROM users LIMIT 1)
WHERE id =
(
    SELECT id
    FROM accession_tests
    LIMIT 1
);

SELECT
    barcode,
    barcode_status,
    remarks
FROM accession_tests
WHERE id =
(
    SELECT id
    FROM accession_tests
    LIMIT 1
);


-- Verify Before Update

SELECT
    accession_id,
    test_id,
    authorization_status,
    remarks
FROM accession_tests
LIMIT 1;

-- Update Authorization Status

UPDATE accession_tests
SET
    authorization_status = 'AUTHORIZED',
    remarks = 'Result Authorized - Dry Run',
    updated_at = CURRENT_TIMESTAMP,
    updated_by = (SELECT id FROM users LIMIT 1)
WHERE id =
(
    SELECT id
    FROM accession_tests
    LIMIT 1
);

-- Verify After Update

SELECT
    accession_id,
    test_id,
    authorization_status,
    remarks
FROM accession_tests
WHERE id =
(
    SELECT id
    FROM accession_tests
    LIMIT 1
);


-- Verify Before Update

SELECT
    accession_id,
    test_id,
    report_status,
    remarks
FROM accession_tests
LIMIT 1;

-- Update Report Status

UPDATE accession_tests
SET
    report_status = 'READY',
    remarks = 'Report Ready - Dry Run',
    updated_at = CURRENT_TIMESTAMP,
    updated_by = (SELECT id FROM users LIMIT 1)
WHERE id =
(
    SELECT id
    FROM accession_tests
    LIMIT 1
);

-- Verify After Update

SELECT
    accession_id,
    test_id,
    report_status,
    remarks
FROM accession_tests
WHERE id =
(
    SELECT id
    FROM accession_tests
    LIMIT 1
);