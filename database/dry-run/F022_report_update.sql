-- Verify Before Update

SELECT
    report_number,
    version_no,
    report_status,
    remarks
FROM report_master
LIMIT 1;

-- Update Report Details

UPDATE report_master
SET
    version_no = version_no + 1,
    remarks = 'Report Updated - Dry Run',
    updated_at = CURRENT_TIMESTAMP,
    updated_by = (SELECT id FROM users LIMIT 1)
WHERE id =
(
    SELECT id
    FROM report_master
    LIMIT 1
);

-- Verify After Update

SELECT
    report_number,
    version_no,
    report_status,
    remarks
FROM report_master
WHERE id =
(
    SELECT id
    FROM report_master
    LIMIT 1
);

-- Verify Before Update

SELECT
    report_number,
    report_status
FROM report_master
LIMIT 1;

-- Cancel Report

UPDATE report_master
SET
    report_status = 'CANCELLED',
    remarks = 'Report Cancelled - Dry Run',
    updated_at = CURRENT_TIMESTAMP,
    updated_by = (SELECT id FROM users LIMIT 1)
WHERE id =
(
    SELECT id
    FROM report_master
    LIMIT 1
);

-- Verify

SELECT
    report_number,
    report_status,
    remarks
FROM report_master
WHERE id =
(
    SELECT id
    FROM report_master
    LIMIT 1
);

-- Verify Before Update

SELECT
    report_number,
    version_no,
    printed_at
FROM report_master
LIMIT 1;

-- Reprint Report

UPDATE report_master
SET
    version_no = version_no + 1,
    printed_at = CURRENT_TIMESTAMP,
    printed_by = (SELECT id FROM users LIMIT 1),
    updated_at = CURRENT_TIMESTAMP,
    updated_by = (SELECT id FROM users LIMIT 1)
WHERE id =
(
    SELECT id
    FROM report_master
    LIMIT 1
);

-- Verify

SELECT
    report_number,
    version_no,
    printed_at
FROM report_master
WHERE id =
(
    SELECT id
    FROM report_master
    LIMIT 1
);

-- Verify Before Update

SELECT
    delivery_type,
    recipient_type,
    recipient_name,
    delivery_status
FROM report_delivery_log
LIMIT 1;

-- Update Delivery Status

UPDATE report_delivery_log
SET
    delivery_status = 'DELIVERED',
    delivered_at = CURRENT_TIMESTAMP,
    delivered_by = (SELECT id FROM users LIMIT 1),
    remarks = 'Report Delivered - Dry Run',
    updated_at = CURRENT_TIMESTAMP,
    updated_by = (SELECT id FROM users LIMIT 1)
WHERE id =
(
    SELECT id
    FROM report_delivery_log
    LIMIT 1
);

-- Verify

SELECT
    delivery_type,
    recipient_type,
    recipient_name,
    delivery_status,
    delivered_at
FROM report_delivery_log
WHERE id =
(
    SELECT id
    FROM report_delivery_log
    LIMIT 1
);