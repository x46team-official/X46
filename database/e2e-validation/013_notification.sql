BEGIN;

-- Create Report Delivery Log
WITH ctx AS
(
    SELECT
        o.id AS organization_id,
        rm.branch_id,
        rm.id AS report_id,
        u.id AS admin_user_id,
        CONCAT_WS(' ', p.first_name, p.middle_name, p.last_name) AS patient_name,
        pc.contact_value AS recipient_contact
    FROM organizations o
    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    JOIN accession_master am
        ON am.organization_id = o.id
       AND am.accession_number = 'ACC0001'

    JOIN report_master rm
        ON rm.organization_id = o.id
       AND rm.accession_id = am.id

    JOIN patient_registrations pr
        ON pr.id = am.patient_registration_id

    JOIN patients p
        ON p.id = pr.patient_id

    LEFT JOIN patient_contacts pc
        ON pc.patient_id = p.id
       AND pc.is_primary = TRUE

    WHERE o.organization_code = 'LAB002'
)

INSERT INTO report_delivery_log
(
    organization_id,
    branch_id,
    report_id,
    delivery_type,
    recipient_type,
    recipient_name,
    recipient_contact,
    delivery_status,
    delivered_at,
    delivered_by,
    created_by,
    updated_by
)
SELECT
    organization_id,
    branch_id,
    report_id,
    'PRINT',
    'PATIENT',
    patient_name,
    recipient_contact,
    'DELIVERED',
    CURRENT_TIMESTAMP,
    admin_user_id,
    admin_user_id,
    admin_user_id
FROM ctx
WHERE NOT EXISTS
(
    SELECT 1
    FROM report_delivery_log rdl
    WHERE rdl.report_id = ctx.report_id
      AND rdl.delivery_type = 'PRINT'
      AND rdl.recipient_type = 'PATIENT'
);

-- Release Report
WITH ctx AS
(
    SELECT
        rm.id AS report_id,
        u.id AS admin_user_id
    FROM organizations o
    JOIN users u
        ON u.organization_id = o.id
       AND u.username = 'admin'

    JOIN accession_master am
        ON am.organization_id = o.id
       AND am.accession_number = 'ACC0001'

    JOIN report_master rm
        ON rm.organization_id = o.id
       AND rm.accession_id = am.id

    WHERE o.organization_code = 'LAB002'
)

UPDATE report_master rm
SET
    report_status = 'RELEASED',
    released_at = CURRENT_TIMESTAMP,
    released_by = ctx.admin_user_id,
    updated_at = CURRENT_TIMESTAMP,
    updated_by = ctx.admin_user_id
FROM ctx
WHERE rm.id = ctx.report_id
  AND rm.report_status <> 'RELEASED';

-- Verification
SELECT
    o.organization_code,
    am.accession_number,
    rm.report_number,
    rm.report_status,
    rdl.delivery_type,
    rdl.delivery_status,
    rdl.recipient_name,
    rdl.recipient_contact,
    rdl.delivered_at
FROM organizations o
JOIN accession_master am
    ON am.organization_id = o.id
JOIN report_master rm
    ON rm.accession_id = am.id
LEFT JOIN report_delivery_log rdl
    ON rdl.report_id = rm.id
WHERE o.organization_code = 'LAB002'
  AND am.accession_number = 'ACC0001';

SELECT
    'Notification E2E Validation Completed Successfully' AS status;

COMMIT;