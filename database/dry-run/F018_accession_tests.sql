INSERT INTO accession_tests (
    organization_id,
    branch_id,
    accession_id,
    billing_test_id,
    test_id,
    sample_type_id,
    performing_lab_id,
    worksheet_id,
    worklist_id,
    barcode,
    created_by
)
SELECT
    bt.organization_id,
    bt.branch_id,
    am.id,
    bt.id,
    bt.test_id,
    bt.sample_type_id,
    bt.performing_lab_id,
    tm.worksheet_id,
    tm.worklist_id,
    'BC000001',
    u.id
FROM billing_tests bt
JOIN accession_master am
    ON am.billing_id = bt.billing_id
   AND am.branch_id = bt.branch_id
JOIN test_master tm
    ON tm.id = bt.test_id
   AND tm.branch_id = bt.branch_id
JOIN users u
    ON u.organization_id = bt.organization_id
   AND u.branch_id = bt.branch_id
LIMIT 1;

SELECT * FROM accession_tests;
