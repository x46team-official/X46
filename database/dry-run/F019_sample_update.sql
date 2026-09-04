-- Verify Before Update

SELECT
    collection_location,
    remarks
FROM sample_collection
LIMIT 1;

-- Update

UPDATE sample_collection
SET
    collection_location = 'ICU - Bed 12',
    remarks = 'Collection Details Updated - Dry Run',
    updated_at = CURRENT_TIMESTAMP,
    updated_by = (SELECT id FROM users LIMIT 1)
WHERE id =
(
    SELECT id
    FROM sample_collection
    LIMIT 1
);

-- Verify

SELECT
    collection_location,
    remarks
FROM sample_collection
WHERE id =
(
    SELECT id
    FROM sample_collection
    LIMIT 1
);


-- Verify Before Update

SELECT
    sample_condition
FROM sample_collection
LIMIT 1;

-- Update

UPDATE sample_collection
SET
    sample_condition = 'HEMOLYZED',
    remarks = 'Sample Condition Updated - Dry Run',
    updated_at = CURRENT_TIMESTAMP,
    updated_by = (SELECT id FROM users LIMIT 1)
WHERE id =
(
    SELECT id
    FROM sample_collection
    LIMIT 1
);

-- Verify

SELECT
    sample_condition,
    remarks
FROM sample_collection
WHERE id =
(
    SELECT id
    FROM sample_collection
    LIMIT 1
);

-- Verify Before Update

SELECT
    quantity,
    quantity_unit
FROM sample_collection
LIMIT 1;

-- Update

UPDATE sample_collection
SET
    quantity = 5.00,
    quantity_unit = 'ml',
    remarks = 'Quantity Updated - Dry Run',
    updated_at = CURRENT_TIMESTAMP,
    updated_by = (SELECT id FROM users LIMIT 1)
WHERE id =
(
    SELECT id
    FROM sample_collection
    LIMIT 1
);

-- Verify

SELECT
    quantity,
    quantity_unit,
    remarks
FROM sample_collection
WHERE id =
(
    SELECT id
    FROM sample_collection
    LIMIT 1
);

-- Verify Before Update

SELECT
    temperature
FROM sample_collection
LIMIT 1;

-- Update

UPDATE sample_collection
SET
    temperature = 4.5,
    remarks = 'Temperature Updated - Dry Run',
    updated_at = CURRENT_TIMESTAMP,
    updated_by = (SELECT id FROM users LIMIT 1)
WHERE id =
(
    SELECT id
    FROM sample_collection
    LIMIT 1
);

-- Verify

SELECT
    temperature,
    remarks
FROM sample_collection
WHERE id =
(
    SELECT id
    FROM sample_collection
    LIMIT 1
);

-- Insert Sample Tracking

INSERT INTO sample_tracking
(
    organization_id,
    branch_id,
    sample_collection_id,
    tracking_status,
    location,
    remarks,
    tracked_by,
    created_by
)
SELECT
    organization_id,
    branch_id,
    id,
    'RECEIVED',
    'Main Laboratory',
    'Tracking Created - Dry Run',
    (SELECT id FROM users LIMIT 1),
    (SELECT id FROM users LIMIT 1)
FROM sample_collection
LIMIT 1;

-- Verify

SELECT
    tracking_status,
    location,
    remarks,
    tracked_at
FROM sample_tracking
ORDER BY tracked_at DESC
LIMIT 1;


-- Verify Before Update

SELECT
    tracking_status,
    location,
    remarks
FROM sample_tracking
ORDER BY tracked_at DESC
LIMIT 1;

-- Update

UPDATE sample_tracking
SET
    tracking_status = 'PROCESSING',
    location = 'Biochemistry Laboratory',
    remarks = 'Tracking Updated - Dry Run',
    updated_at = CURRENT_TIMESTAMP,
    updated_by = (SELECT id FROM users LIMIT 1)
WHERE id =
(
    SELECT id
    FROM sample_tracking
    ORDER BY tracked_at DESC
    LIMIT 1
);

-- Verify

SELECT
    tracking_status,
    location,
    remarks
FROM sample_tracking
WHERE id =
(
    SELECT id
    FROM sample_tracking
    ORDER BY tracked_at DESC
    LIMIT 1
);