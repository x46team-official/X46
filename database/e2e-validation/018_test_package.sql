BEGIN;


-- CREATE TEST PACKAGE MASTER (One Time)


WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        b.id AS branch_id,
        u.id AS admin_user_id,
        bcm.id AS billing_category_id
    FROM organizations o

    JOIN branches b
        ON b.organization_id = o.id
       AND b.branch_code = 'PUNE002'

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    JOIN billing_category_master bcm
        ON bcm.organization_id = o.id
       AND bcm.billing_category_code = 'PKG'

    WHERE o.organization_code = 'LAB002'
)

INSERT INTO test_package_master
(
    organization_id,
    branch_id,
    billing_category_id,
    package_code,
    package_name,
    display_name,
    selling_price,
    cost_price,
    tat_minutes,
    description,
    created_by
)
SELECT
    organization_id,
    branch_id,
    billing_category_id,
    'PKG001',
    'Basic Health Package',
    'Basic Health Package',
    550.00,
    0,
    480,
    'E2E Validation Package - CBC + Bilirubin + Creatinine',
    admin_user_id
FROM ctx
WHERE NOT EXISTS
(
    SELECT 1
    FROM test_package_master tpm
    WHERE tpm.organization_id = ctx.organization_id
      AND tpm.branch_id = ctx.branch_id
      AND tpm.package_code = 'PKG001'
);


-- ADD MEMBER TESTS TO PACKAGE (One Time)


WITH ctx AS
(
    SELECT
        tpm.id AS package_id,
        tpm.organization_id,
        tpm.branch_id,
        u.id AS admin_user_id,
        tm.id AS test_id
    FROM test_package_master tpm

    JOIN organizations o
        ON o.id = tpm.organization_id

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    JOIN test_master tm
        ON tm.organization_id = o.id
       AND tm.test_code = 'CBC001'

    WHERE o.organization_code = 'LAB002'
      AND tpm.package_code = 'PKG001'
)

INSERT INTO test_package_test_mapping
(
    organization_id,
    branch_id,
    package_id,
    test_id,
    display_order,
    created_by
)
SELECT
    organization_id,
    branch_id,
    package_id,
    test_id,
    1,
    admin_user_id
FROM ctx
WHERE NOT EXISTS
(
    SELECT 1
    FROM test_package_test_mapping m
    WHERE m.package_id = ctx.package_id
      AND m.test_id = ctx.test_id
);


WITH ctx AS
(
    SELECT
        tpm.id AS package_id,
        tpm.organization_id,
        tpm.branch_id,
        u.id AS admin_user_id,
        tm.id AS test_id
    FROM test_package_master tpm

    JOIN organizations o
        ON o.id = tpm.organization_id

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    JOIN test_master tm
        ON tm.organization_id = o.id
       AND tm.test_code = 'BILIRUBIN'

    WHERE o.organization_code = 'LAB002'
      AND tpm.package_code = 'PKG001'
)

INSERT INTO test_package_test_mapping
(
    organization_id,
    branch_id,
    package_id,
    test_id,
    display_order,
    created_by
)
SELECT
    organization_id,
    branch_id,
    package_id,
    test_id,
    2,
    admin_user_id
FROM ctx
WHERE NOT EXISTS
(
    SELECT 1
    FROM test_package_test_mapping m
    WHERE m.package_id = ctx.package_id
      AND m.test_id = ctx.test_id
);


WITH ctx AS
(
    SELECT
        tpm.id AS package_id,
        tpm.organization_id,
        tpm.branch_id,
        u.id AS admin_user_id,
        tm.id AS test_id
    FROM test_package_master tpm

    JOIN organizations o
        ON o.id = tpm.organization_id

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    JOIN test_master tm
        ON tm.organization_id = o.id
       AND tm.test_code = 'CREATININE'

    WHERE o.organization_code = 'LAB002'
      AND tpm.package_code = 'PKG001'
)

INSERT INTO test_package_test_mapping
(
    organization_id,
    branch_id,
    package_id,
    test_id,
    display_order,
    created_by
)
SELECT
    organization_id,
    branch_id,
    package_id,
    test_id,
    3,
    admin_user_id
FROM ctx
WHERE NOT EXISTS
(
    SELECT 1
    FROM test_package_test_mapping m
    WHERE m.package_id = ctx.package_id
      AND m.test_id = ctx.test_id
);


-- BILL THE PACKAGE FOR REG001 (New Bill BILL0003)


WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        pr.branch_id,
        pr.id AS registration_id,
        u.id AS created_by,
        bcm.id AS billing_category_id,
        tpm.selling_price
    FROM organizations o

    JOIN patient_registrations pr
      ON pr.organization_id = o.id

    JOIN users u
      ON u.id = pr.created_by

    JOIN billing_category_master bcm
      ON bcm.organization_id = o.id
     AND bcm.billing_category_code = 'PKG'

    JOIN test_package_master tpm
      ON tpm.organization_id = o.id
     AND tpm.package_code = 'PKG001'

    WHERE o.organization_code = 'LAB002'
      AND pr.registration_number = 'REG001'
)

INSERT INTO billing_master
(
    organization_id,
    branch_id,
    patient_registration_id,
    bill_number,
    bill_date,
    billing_category_id,
    total_amount,
    discount_amount,
    concession_amount,
    additional_amount,
    payable_amount,
    paid_amount,
    balance_amount,
    payment_status,
    remarks,
    created_by
)
SELECT
    organization_id,
    branch_id,
    registration_id,
    'BILL0003',
    CURRENT_TIMESTAMP,
    billing_category_id,
    selling_price,
    0,
    0,
    0,
    selling_price,
    0,
    selling_price,
    'Pending',
    'E2E Validation - Package Billing',
    created_by
FROM ctx
ON CONFLICT (organization_id, branch_id, bill_number)
DO NOTHING;


-- EXPAND PACKAGE INTO BILLING TEST LINE ITEMS (One Per Member Test)


WITH pkg AS
(
    SELECT
        bm.id AS billing_id,
        bm.organization_id,
        bm.branch_id,
        bm.created_by,
        tpm.id AS package_id,
        tpm.selling_price AS package_price,
        (
            SELECT SUM(tm2.selling_price)
            FROM test_package_test_mapping m
            JOIN test_master tm2
              ON tm2.id = m.test_id
            WHERE m.package_id = tpm.id
              AND m.is_active
        ) AS total_test_price
    FROM billing_master bm

    JOIN organizations o
      ON o.id = bm.organization_id

    JOIN test_package_master tpm
      ON tpm.organization_id = o.id
     AND tpm.package_code = 'PKG001'

    WHERE o.organization_code = 'LAB002'
      AND bm.bill_number = 'BILL0003'
),

ctx AS
(
    SELECT
        pkg.billing_id,
        pkg.organization_id,
        pkg.branch_id,
        pkg.created_by,
        pkg.package_id,
        tm.id AS test_id,
        tm.sample_type_id,
        tm.performing_lab_id,
        tm.tat_minutes,
        tm.selling_price AS test_price,
        -- proportional allocation of the package price across member
        -- tests by their individual selling_price, so every line item
        -- carries a non-negative discount and the net amounts sum to
        -- the package's selling_price
        ROUND(pkg.package_price * tm.selling_price / pkg.total_test_price, 2) AS allocated_price
    FROM pkg

    JOIN test_package_test_mapping tptm
      ON tptm.package_id = pkg.package_id
     AND tptm.is_active

    JOIN test_master tm
      ON tm.id = tptm.test_id
)

INSERT INTO billing_tests
(
    organization_id,
    branch_id,
    billing_id,
    package_id,
    test_id,
    sample_type_id,
    performing_lab_id,
    quantity,
    rate,
    discount_amount,
    concession_amount,
    net_amount,
    tat_minutes,
    status,
    created_by
)
SELECT
    organization_id,
    branch_id,
    billing_id,
    package_id,
    test_id,
    sample_type_id,
    performing_lab_id,
    1,
    test_price,
    ROUND(test_price - allocated_price, 2),
    0,
    allocated_price,
    tat_minutes,
    'Pending',
    created_by
FROM ctx
WHERE NOT EXISTS
(
    SELECT 1
    FROM billing_tests bt
    WHERE bt.billing_id = ctx.billing_id
      AND bt.test_id = ctx.test_id
);


-- CREATE ACCESSION FOR THE PACKAGE BILL (ACC0004)


WITH acc_ctx AS
(
    SELECT
        bm.organization_id,
        bm.branch_id,
        bm.id AS billing_id,
        bm.patient_registration_id,
        u.id AS admin_user_id
    FROM billing_master bm
    JOIN organizations o
      ON o.id = bm.organization_id
    JOIN users u
      ON u.organization_id = bm.organization_id
     AND u.username = 'admin'
    WHERE o.organization_code = 'LAB002'
      AND bm.bill_number = 'BILL0003'
)

INSERT INTO accession_master
(
    organization_id,
    branch_id,
    billing_id,
    patient_registration_id,
    accession_number,
    accession_date,
    priority,
    status,
    remarks,
    created_by
)
SELECT
    organization_id,
    branch_id,
    billing_id,
    patient_registration_id,
    'ACC0004',
    CURRENT_TIMESTAMP,
    'NORMAL',
    'PENDING',
    'E2E Validation - Package Accession',
    admin_user_id
FROM acc_ctx
ON CONFLICT (organization_id, branch_id, accession_number)
DO NOTHING;


-- CREATE ACCESSION TESTS FOR EACH PACKAGE LINE ITEM


WITH ctx AS
(
    SELECT
        am.id AS accession_id,
        am.organization_id,
        am.branch_id,
        bt.id AS billing_test_id,
        bt.test_id,
        bt.sample_type_id,
        bt.performing_lab_id,
        u.id AS admin_user_id
    FROM accession_master am
    JOIN billing_master bm
      ON bm.id = am.billing_id
    JOIN organizations o
      ON o.id = am.organization_id
    JOIN billing_tests bt
      ON bt.billing_id = bm.id
     AND bt.package_id IS NOT NULL
    JOIN users u
      ON u.organization_id = am.organization_id
     AND u.username = 'admin'
    WHERE o.organization_code = 'LAB002'
      AND am.accession_number = 'ACC0004'
)

INSERT INTO accession_tests
(
    organization_id,
    branch_id,
    accession_id,
    billing_test_id,
    test_id,
    sample_type_id,
    performing_lab_id,
    barcode,
    barcode_status,
    print_count,
    sample_status,
    collection_status,
    authorization_status,
    report_status,
    remarks,
    created_by
)
SELECT
    organization_id,
    branch_id,
    accession_id,
    billing_test_id,
    test_id,
    sample_type_id,
    performing_lab_id,
    'BC' || to_char(CURRENT_TIMESTAMP, 'YYYYMMDDHH24MISSMS') || '-' || substr(billing_test_id::text, 1, 4),
    'GENERATED',
    0,
    'PENDING',
    'NOT_COLLECTED',
    'PENDING',
    'PENDING',
    'Awaiting sample collection - Package',
    admin_user_id
FROM ctx
WHERE NOT EXISTS
(
    SELECT 1
    FROM accession_tests at
    WHERE at.accession_id = ctx.accession_id
      AND at.billing_test_id = ctx.billing_test_id
);

COMMIT;


-- VERIFY PACKAGE MASTER + MEMBER TESTS


SELECT
    o.organization_code,
    tpm.package_code,
    tpm.package_name,
    tpm.selling_price,
    tm.test_code,
    tm.test_name,
    tptm.display_order
FROM test_package_test_mapping tptm
JOIN test_package_master tpm
  ON tpm.id = tptm.package_id
JOIN organizations o
  ON o.id = tpm.organization_id
JOIN test_master tm
  ON tm.id = tptm.test_id
WHERE o.organization_code = 'LAB002'
  AND tpm.package_code = 'PKG001'
ORDER BY tptm.display_order;


-- VERIFY PACKAGE BILL EXPANSION


SELECT
    o.organization_code,
    bm.bill_number,
    bm.payable_amount AS package_total,
    tpm.package_code,
    tm.test_code,
    bt.rate AS test_rate,
    bt.discount_amount,
    bt.net_amount
FROM billing_tests bt
JOIN billing_master bm
  ON bm.id = bt.billing_id
JOIN organizations o
  ON o.id = bm.organization_id
JOIN test_package_master tpm
  ON tpm.id = bt.package_id
JOIN test_master tm
  ON tm.id = bt.test_id
WHERE o.organization_code = 'LAB002'
  AND bm.bill_number = 'BILL0003'
ORDER BY tm.test_code;


-- VERIFY PACKAGE ACCESSION TESTS


SELECT
    o.organization_code,
    am.accession_number,
    tm.test_code,
    at.barcode,
    at.sample_status,
    at.collection_status
FROM accession_tests at
JOIN accession_master am
  ON am.id = at.accession_id
JOIN organizations o
  ON o.id = am.organization_id
JOIN test_master tm
  ON tm.id = at.test_id
WHERE o.organization_code = 'LAB002'
  AND am.accession_number = 'ACC0004'
ORDER BY tm.test_code;


-- STATUS


SELECT
    'Test Package E2E Validation Completed Successfully' AS status;
