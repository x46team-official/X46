INSERT INTO sample_collection (
    organization_id,
    branch_id,
    accession_test_id,
    collector_id,
    collection_location,
    sample_condition,
    quantity,
    quantity_unit,
    temperature,
    collection_status,
    remarks,
    created_by
)
SELECT
    at.organization_id,
    at.branch_id,
    at.id,
    u.id,
    'Main Collection Center',
    'GOOD',
    5,
    'mL',
    24.5,
    'COLLECTED',
    'Dry Run Sample Collection',
    u.id
FROM accession_tests at
JOIN users u
    ON u.organization_id = at.organization_id
   AND u.branch_id = at.branch_id
LIMIT 1;

SELECT * FROM sample_collection;
