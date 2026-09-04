INSERT INTO sample_tracking (
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
    sc.organization_id,
    sc.branch_id,
    sc.id,
    'COLLECTED',
    'Main Collection Center',
    'Sample Collected',
    u.id,
    u.id
FROM sample_collection sc
JOIN users u
    ON u.organization_id = sc.organization_id
   AND u.branch_id = sc.branch_id
LIMIT 1;

SELECT * FROM sample_tracking;
