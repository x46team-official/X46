INSERT INTO accession_master (
    organization_id,
    branch_id,
    billing_id,
    patient_registration_id,
    accession_number,
    priority,
    status,
    remarks,
    created_by
)
SELECT
    bm.organization_id,
    bm.branch_id,
    bm.id,
    bm.patient_registration_id,
    'ACC-000001',
    'NORMAL',
    'PENDING',
    'Dry Run Accession',
    u.id
FROM billing_master bm
JOIN users u
    ON u.organization_id = bm.organization_id
   AND u.branch_id = bm.branch_id
LIMIT 1;

SELECT * FROM accession_master;
