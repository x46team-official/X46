BEGIN;


-- CREATE CLIENT ORGANIZATION (One Time)


WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        b.id AS branch_id,
        u.id AS admin_user_id
    FROM organizations o

    JOIN branches b
        ON b.organization_id = o.id
       AND b.branch_code = 'PUNE002'

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    WHERE o.organization_code = 'LAB002'
)

INSERT INTO client_organization_master
(
    organization_id,
    branch_id,
    client_code,
    client_name,
    contact_person,
    phone_number,
    city,
    created_by
)
SELECT
    organization_id,
    branch_id,
    'RGHPMC',
    'RGH PMC',
    'Front Desk',
    '+91 9800000001',
    'Pune',
    admin_user_id
FROM ctx
WHERE NOT EXISTS
(
    SELECT 1
    FROM client_organization_master com
    WHERE com.organization_id = ctx.organization_id
      AND com.branch_id = ctx.branch_id
      AND com.client_code = 'RGHPMC'
);


-- CREATE REFERRAL (One Time)


WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        b.id AS branch_id,
        u.id AS admin_user_id
    FROM organizations o

    JOIN branches b
        ON b.organization_id = o.id
       AND b.branch_code = 'PUNE002'

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    WHERE o.organization_code = 'LAB002'
)

INSERT INTO referral_master
(
    organization_id,
    branch_id,
    referral_code,
    referral_name,
    referral_type,
    city,
    created_by
)
SELECT
    organization_id,
    branch_id,
    'CANTHOSP',
    'Cantonment Hospital',
    'HOSPITAL',
    'Pune',
    admin_user_id
FROM ctx
WHERE NOT EXISTS
(
    SELECT 1
    FROM referral_master rm
    WHERE rm.organization_id = ctx.organization_id
      AND rm.branch_id = ctx.branch_id
      AND rm.referral_code = 'CANTHOSP'
);


-- CREATE AGENT (One Time)


WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        b.id AS branch_id,
        u.id AS admin_user_id
    FROM organizations o

    JOIN branches b
        ON b.organization_id = o.id
       AND b.branch_code = 'PUNE002'

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    WHERE o.organization_code = 'LAB002'
)

INSERT INTO agent_master
(
    organization_id,
    branch_id,
    agent_code,
    agent_name,
    created_by
)
SELECT
    organization_id,
    branch_id,
    'SANIYA',
    'Saniya',
    admin_user_id
FROM ctx
WHERE NOT EXISTS
(
    SELECT 1
    FROM agent_master am
    WHERE am.organization_id = ctx.organization_id
      AND am.branch_id = ctx.branch_id
      AND am.agent_code = 'SANIYA'
);


-- LINK REG001 TO CLIENT ORGANIZATION, REFERRAL AND AGENT


WITH ctx AS
(
    SELECT
        pr.id AS registration_id,
        com.id AS client_id,
        rm.id AS referral_id,
        am.id AS agent_id
    FROM patient_registrations pr

    JOIN organizations o
        ON o.id = pr.organization_id

    JOIN client_organization_master com
        ON com.organization_id = o.id
       AND com.client_code = 'RGHPMC'

    JOIN referral_master rm
        ON rm.organization_id = o.id
       AND rm.referral_code = 'CANTHOSP'

    JOIN agent_master am
        ON am.organization_id = o.id
       AND am.agent_code = 'SANIYA'

    WHERE o.organization_code = 'LAB002'
      AND pr.registration_number = 'REG001'
)

UPDATE patient_registrations pr
SET
    client_id = ctx.client_id,
    referral_doctor_id = ctx.referral_id,
    agent_id = ctx.agent_id
FROM ctx
WHERE pr.id = ctx.registration_id
AND
(
       pr.client_id IS DISTINCT FROM ctx.client_id
    OR pr.referral_doctor_id IS DISTINCT FROM ctx.referral_id
    OR pr.agent_id IS DISTINCT FROM ctx.agent_id
);


-- APPLY TDS AND WRITE-OFF TO BILL0001


WITH ctx AS
(
    SELECT
        bm.id AS billing_id,
        u.id AS admin_user_id
    FROM billing_master bm

    JOIN organizations o
        ON o.id = bm.organization_id

    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    WHERE o.organization_code = 'LAB002'
      AND bm.bill_number = 'BILL0001'
)

UPDATE billing_master bm
SET
    tds_amount = 5.50,
    write_off_amount = 10.00,
    write_off_reason = 'E2E Validation - goodwill write-off',
    written_off_by = ctx.admin_user_id,
    written_off_at = CURRENT_TIMESTAMP,
    updated_by = ctx.admin_user_id,
    updated_at = CURRENT_TIMESTAMP
FROM ctx
WHERE bm.id = ctx.billing_id
AND
(
       bm.tds_amount IS DISTINCT FROM 5.50
    OR bm.write_off_amount IS DISTINCT FROM 10.00
);


-- RECORD BANK/CHEQUE DETAIL ON THE FIRST PAYMENT AGAINST BILL0001


WITH ctx AS
(
    SELECT
        p.id AS payment_id
    FROM payment p

    JOIN billing_master bm
        ON bm.id = p.billing_master_id

    JOIN organizations o
        ON o.id = bm.organization_id

    WHERE o.organization_code = 'LAB002'
      AND bm.bill_number = 'BILL0001'

    ORDER BY p.payment_date
    LIMIT 1
)

UPDATE payment p
SET
    bank_name = 'HDFC Bank',
    cheque_number = 'CHQ123456',
    updated_at = CURRENT_TIMESTAMP
FROM ctx
WHERE p.id = ctx.payment_id
AND
(
       p.bank_name IS DISTINCT FROM 'HDFC Bank'
    OR p.cheque_number IS DISTINCT FROM 'CHQ123456'
);

COMMIT;


-- VERIFY CLIENT / REFERRAL / AGENT LINKAGE


SELECT
    o.organization_code,
    pr.registration_number,
    com.client_code,
    com.client_name,
    rm.referral_code,
    rm.referral_name,
    rm.referral_type,
    am.agent_code,
    am.agent_name
FROM patient_registrations pr
JOIN organizations o
    ON o.id = pr.organization_id
LEFT JOIN client_organization_master com
    ON com.id = pr.client_id
LEFT JOIN referral_master rm
    ON rm.id = pr.referral_doctor_id
LEFT JOIN agent_master am
    ON am.id = pr.agent_id
WHERE o.organization_code = 'LAB002'
  AND pr.registration_number = 'REG001';


-- VERIFY TDS / WRITE-OFF ON BILL0001


SELECT
    o.organization_code,
    bm.bill_number,
    bm.payable_amount,
    bm.tds_amount,
    bm.write_off_amount,
    bm.write_off_reason,
    bm.written_off_at IS NOT NULL AS is_written_off
FROM billing_master bm
JOIN organizations o
    ON o.id = bm.organization_id
WHERE o.organization_code = 'LAB002'
  AND bm.bill_number = 'BILL0001';


-- VERIFY BANK/CHEQUE DETAIL ON THE PAYMENT


SELECT
    o.organization_code,
    bm.bill_number,
    p.amount_paid,
    p.payment_mode,
    p.bank_name,
    p.cheque_number
FROM payment p
JOIN billing_master bm
    ON bm.id = p.billing_master_id
JOIN organizations o
    ON o.id = bm.organization_id
WHERE o.organization_code = 'LAB002'
  AND bm.bill_number = 'BILL0001'
  AND p.bank_name IS NOT NULL;


-- STATUS


SELECT
    'Finance Master Data E2E Validation Completed Successfully' AS status;
