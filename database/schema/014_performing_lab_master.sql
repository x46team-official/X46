CREATE TABLE performing_lab_master (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL REFERENCES organizations(id),

    branch_id UUID NOT NULL REFERENCES branches(id),

    lab_code VARCHAR(30) NOT NULL,
    lab_name VARCHAR(100) NOT NULL,
    alternate_lab_name VARCHAR(150),
    legal_name VARCHAR(150),

    contact_person_name VARCHAR(100),
    contact_person_email VARCHAR(100),
    alternate_contact_person_name VARCHAR(100),
    email VARCHAR(150),

    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    pincode VARCHAR(20),
    gstin_number VARCHAR(30),

    lab_type VARCHAR(50) DEFAULT 'Private',
    is_default BOOLEAN DEFAULT FALSE,
    is_result_lab BOOLEAN DEFAULT FALSE,

    auto_email_report BOOLEAN DEFAULT FALSE,
    auto_sms_report BOOLEAN DEFAULT FALSE,
    auto_whatsapp_report BOOLEAN DEFAULT FALSE,

    remarks TEXT,
    is_active BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID REFERENCES users(id),

    CONSTRAINT uq_performing_lab_code
        UNIQUE (organization_id, branch_id, lab_code),

    CONSTRAINT uq_performing_lab_name
        UNIQUE (organization_id, branch_id, lab_name)
);

CREATE INDEX idx_performing_lab_org
ON performing_lab_master(organization_id);

CREATE INDEX idx_performing_lab_org_branch
ON performing_lab_master(organization_id, branch_id);

CREATE INDEX idx_lab_code
ON performing_lab_master(lab_code);

CREATE INDEX idx_lab_name
ON performing_lab_master(lab_name);

CREATE INDEX idx_lab_city
ON performing_lab_master(city);

CREATE INDEX idx_lab_active
ON performing_lab_master(is_active);

INSERT INTO performing_lab_master
(
    organization_id,
    branch_id,
    lab_code,
    lab_name,
    alternate_lab_name,
    legal_name,
    contact_person_name,
    contact_person_email,
    alternate_contact_person_name,
    email,
    address,
    city,
    state,
    country,
    pincode,
    gstin_number,
    lab_type,
    is_default
)

SELECT
    o.id,
    b.id,
    'MAIN',
    'Main Laboratory',
    'Main Lab',
    'Main Laboratory Pvt Ltd',
    'Lab Manager',
    'manager@x46.com',
    'Assistant Manager',
    'lab@x46.com',
    'Yerwada',
    'Pune',
    'Maharashtra',
    'India',
    '411045',
    '27ABCDE1234F1Z5',
    'Internal',
    TRUE
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
LIMIT 1;

SELECT * FROM performing_lab_master;
