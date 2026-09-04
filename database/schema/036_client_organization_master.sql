-- Module : Client Organization Management
-- 036_client_organization_master.sql
--
-- The B2B account a patient/bill is attributed to (e.g. a hospital or
-- corporate account sending samples) - referred to as "Organisation" in
-- Finance reports. Distinct from `organizations`, which is the LIMS tenant.

CREATE TABLE client_organization_master
(
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    branch_id UUID NOT NULL
        REFERENCES branches(id),

    client_code VARCHAR(30) NOT NULL,
    client_name VARCHAR(150) NOT NULL,

    contact_person VARCHAR(150),
    phone_number VARCHAR(20),
    email VARCHAR(100),

    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    pincode VARCHAR(20),

    gst_number VARCHAR(30),

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID REFERENCES users(id),

    CONSTRAINT uq_client_organization_code
        UNIQUE (organization_id, branch_id, client_code),

    CONSTRAINT uq_client_organization_name
        UNIQUE (organization_id, branch_id, client_name)
);

CREATE INDEX idx_client_organization_org
ON client_organization_master(organization_id);

CREATE INDEX idx_client_organization_org_branch
ON client_organization_master(organization_id, branch_id);

CREATE INDEX idx_client_organization_code
ON client_organization_master(client_code);

CREATE INDEX idx_client_organization_name
ON client_organization_master(client_name);

CREATE INDEX idx_client_organization_active
ON client_organization_master(is_active);


-- patient_registrations.client_id existed since 006_patient_registration_enhancement.sql
-- with no FK and no master table behind it. Wire it up now.

ALTER TABLE patient_registrations
ADD CONSTRAINT fk_patient_registrations_client
FOREIGN KEY (client_id)
REFERENCES client_organization_master(id);

CREATE INDEX idx_patient_registrations_client
ON patient_registrations(client_id);
