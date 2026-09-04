INSERT INTO billing_tests
(
    organization_id,
    branch_id,
    billing_id,
    test_id,
    sample_type_id,
    performing_lab_id,
    quantity,
    rate,
    discount_amount,
    concession_amount,
    net_amount,
    tat_minutes,
    barcode,
    status,
    remarks
)

SELECT
    o.id,
    b.id,
    bm.id,
    tm.id,
    st.id,
    pl.id,
    1,
    350,
    0,
    0,
    350,
    120,
    'BC00000001',
    'Pending',
    'First Test Billing'

FROM organizations o
JOIN branches b
ON b.organization_id = o.id

JOIN billing_master bm
ON bm.organization_id = o.id
AND bm.branch_id = b.id

JOIN test_master tm
ON tm.organization_id = o.id
AND tm.branch_id = b.id

JOIN sample_type_master st
ON st.organization_id = o.id
AND st.branch_id = b.id

JOIN performing_lab_master pl
ON pl.organization_id = o.id
AND pl.branch_id = b.id

WHERE o.organization_code = 'DEMO-LAB 2'
  AND b.branch_code = 'PUNE-01'
LIMIT 1;

SELECT * FROM billing_tests;
