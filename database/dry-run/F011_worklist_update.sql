-- Verify Before Update

SELECT
    worklist_code,
    worklist_name,
    description,
    is_active
FROM worklist_master
LIMIT 1;

-- Update Worklist Details

UPDATE worklist_master
SET
    worklist_name = 'Updated Worklist',
    description = 'Updated during Dry Run',
    estimated_tat_minutes = 180,
    updated_at = CURRENT_TIMESTAMP,
    updated_by = (SELECT id FROM users LIMIT 1)
WHERE id =
(
    SELECT id
    FROM worklist_master
    LIMIT 1
);

-- Verify After Update

SELECT
    worklist_code,
    worklist_name,
    description,
    estimated_tat_minutes
FROM worklist_master
WHERE id =
(
    SELECT id
    FROM worklist_master
    LIMIT 1
);

-- Verify Before Update

SELECT
    worklist_code,
    is_active
FROM worklist_master
LIMIT 1;

-- Deactivate

UPDATE worklist_master
SET
    is_active = FALSE,
    updated_at = CURRENT_TIMESTAMP,
    updated_by = (SELECT id FROM users LIMIT 1)
WHERE id =
(
    SELECT id
    FROM worklist_master
    LIMIT 1
);

-- Verify

SELECT
    worklist_code,
    is_active
FROM worklist_master
WHERE id =
(
    SELECT id
    FROM worklist_master
    LIMIT 1
);

-- Activate Again

UPDATE worklist_master
SET
    is_active = TRUE,
    updated_at = CURRENT_TIMESTAMP,
    updated_by = (SELECT id FROM users LIMIT 1)
WHERE id =
(
    SELECT id
    FROM worklist_master
    LIMIT 1
);

-- Verify

SELECT
    worklist_code,
    is_active
FROM worklist_master
WHERE id =
(
    SELECT id
    FROM worklist_master
    LIMIT 1
);

-- Expected:
-- Duplicate Worklist Code should fail because of
-- UNIQUE (organization_id, branch_id, worklist_code)

INSERT INTO worklist_master
(
    organization_id,
    branch_id,
    department_id,
    worklist_code,
    worklist_name,
    description,
    created_by
)
SELECT
    organization_id,
    branch_id,
    department_id,
    worklist_code,
    'Duplicate Worklist',
    'Duplicate Validation',
    (SELECT id FROM users LIMIT 1)
FROM worklist_master
LIMIT 1;

-- Verify Before Update

SELECT
    worksheet_code,
    worksheet_name,
    description,
    is_active
FROM worksheet_master
LIMIT 1;

-- Update Worksheet

UPDATE worksheet_master
SET
    worksheet_name = 'Updated Worksheet',
    description = 'Updated during Dry Run',
    updated_at = CURRENT_TIMESTAMP,
    updated_by = (SELECT id FROM users LIMIT 1)
WHERE id =
(
    SELECT id
    FROM worksheet_master
    LIMIT 1
);

-- Verify

SELECT
    worksheet_code,
    worksheet_name,
    description
FROM worksheet_master
WHERE id =
(
    SELECT id
    FROM worksheet_master
    LIMIT 1
);