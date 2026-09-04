INSERT INTO test_master
(
    organization_id,
    branch_id,
    department_id,
    test_category_id,
    billing_category_id,
    sample_type_id,
    performing_lab_id,
    outsource_center_id,
    worksheet_id,
    worklist_id,

    test_code,
    test_name,
    display_name,
    print_name,
    short_code,

    selling_price,
    cost_price,
    cprr,

    test_method,
    test_type,
    tat_minutes,
    machine_test_code,
    consumption_group,

    auto_approval,
    automatically_authorize,
    nabl_accredited,
    mark_as_profile,
    two_step_verification,
    authorize_only_by_authorizer,
    outsource_test,
    notify_accession,

    description
)

SELECT

    o.id,
    b.id,
    d.id,
    tc.id,
    bc.id,
    st.id,
    pl.id,
    oc.id,
    ws.id,
    wl.id,

    'CBC001',
    'Complete Blood Count',
    'CBC',
    'Complete Blood Count',
    'CBC',

    350,
    150,
    0,

    'Automated Cell Counter',
    'Pathology',
    120,
    'XN1000-CBC',
    'Hematology',

    TRUE,
    FALSE,
    TRUE,
    FALSE,
    FALSE,
    FALSE,
    FALSE,
    TRUE,

    'Default CBC Test'

FROM organizations o
JOIN branches b
ON b.organization_id = o.id

JOIN department_master d
ON d.organization_id = o.id
AND d.branch_id = b.id

JOIN test_category_master tc
ON tc.organization_id = o.id
AND tc.branch_id = b.id

JOIN billing_category_master bc
ON bc.organization_id = o.id
AND bc.branch_id = b.id

JOIN sample_type_master st
ON st.organization_id = o.id
AND st.branch_id = b.id

JOIN performing_lab_master pl
ON pl.organization_id = o.id
AND pl.branch_id = b.id

JOIN outsource_center_master oc
ON oc.organization_id = o.id
AND oc.branch_id = b.id

JOIN worksheet_master ws
ON ws.organization_id = o.id
AND ws.branch_id = b.id

JOIN worklist_master wl
ON wl.organization_id = o.id
AND wl.branch_id = b.id

WHERE o.organization_code = 'DEMO-LAB 2'
  AND b.branch_code = 'PUNE-01'
LIMIT 1;

SELECT * FROM test_master;
