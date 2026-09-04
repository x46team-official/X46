
BEGIN;

WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        at.branch_id,
        u.id AS collector_id,
        am.id AS accession_id,
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

INSERT INTO sample_collection
(
    organization_id,
    branch_id,
    accession_test_id,
    collector_id,
    collection_datetime,
    collection_location,
    sample_condition,
    quantity,
    quantity_unit,
    collection_status,
    remarks,
    created_by
)
SELECT
    ctx.organization_id,
    ctx.branch_id,
    ctx.accession_test_id,
    ctx.collector_id,
    CURRENT_TIMESTAMP,
    'Sample Collection Center',
    'GOOD',
    5,
    'mL',
    'COLLECTED',
    'E2E Sample Collection Validation',
    ctx.collector_id
FROM ctx
where NOT EXISTS
(
    SELECT 1
    FROM  sample_collection sc
    where sc.accession_test_id = ctx.accession_test_id
);

-- Update Accession Test Status

WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        at.branch_id,
        u.id AS collector_id,
        am.id AS accession_id,
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

UPDATE accession_tests at
SET
    sample_status = 'COLLECTED',
    collection_status = 'COLLECTED',
    updated_by = ctx.collector_id,
    updated_at = CURRENT_TIMESTAMP
FROM ctx
WHERE at.id = ctx.accession_test_id
AND
(
       at.sample_status <> 'COLLECTED'
    OR at.collection_status <> 'COLLECTED'
);

COMMIT;


-- Verification : Sample Collection

SELECT
    o.organization_code,
    am.accession_number,
    tm.test_code,
    tm.test_name,
    sc.collection_datetime,
    sc.collection_location,
    sc.sample_condition,
    sc.quantity,
    sc.quantity_unit,
    sc.collection_status,
    u.username AS collector
FROM sample_collection sc

JOIN accession_tests at
    ON at.id = sc.accession_test_id

JOIN accession_master am
    ON am.id = at.accession_id

JOIN test_master tm
    ON tm.id = at.test_id

JOIN organizations o
    ON o.id = sc.organization_id

LEFT JOIN users u
    ON u.id = sc.collector_id

WHERE o.organization_code = 'LAB002'
  AND am.accession_number = 'ACC0001';


-- Verification : Accession Test

SELECT
    o.organization_code,
    am.accession_number,
    at.barcode,
    at.sample_status,
    at.collection_status,
    at.authorization_status,
    at.report_status
FROM accession_tests at

JOIN accession_master am
    ON am.id = at.accession_id

JOIN organizations o
    ON o.id = at.organization_id

WHERE o.organization_code = 'LAB002'
  AND am.accession_number = 'ACC0001';


-- Status

SELECT
    'Sample Collection E2E Validation Completed Successfully' AS status;