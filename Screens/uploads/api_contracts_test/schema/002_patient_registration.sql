
-- F001 PATIENT REGISTRATION - PHASE 1
-- Covers R001, R002, R003, R004, R005, R014
-- 

-- Basic patient record
CREATE TABLE patients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    branch_id UUID NOT NULL
        REFERENCES branches(id),

    patient_type VARCHAR(50),

    first_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    last_name VARCHAR(100),

    gender VARCHAR(30),
    date_of_birth DATE,

    patient_category VARCHAR(100),

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID REFERENCES users(id)
);


-- MRN / Patient ID / Passport
CREATE TABLE patient_identifiers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    branch_id UUID NOT NULL
        REFERENCES branches(id),

    patient_id UUID NOT NULL
        REFERENCES patients(id),

    identifier_type VARCHAR(50) NOT NULL,
    identifier_value VARCHAR(200) NOT NULL,

    is_primary BOOLEAN NOT NULL DEFAULT FALSE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_patient_identifier
        UNIQUE (
            organization_id,
            branch_id,
            identifier_type,
            identifier_value
        )
);


-- Multiple phone/email contacts
CREATE TABLE patient_contacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    branch_id UUID NOT NULL
        REFERENCES branches(id),

    patient_id UUID NOT NULL
        REFERENCES patients(id),

    contact_type VARCHAR(30) NOT NULL,
    contact_value VARCHAR(255) NOT NULL,

    belongs_to VARCHAR(100),

    whatsapp_consent BOOLEAN NOT NULL DEFAULT FALSE,

    is_primary BOOLEAN NOT NULL DEFAULT FALSE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID REFERENCES users(id),

    CONSTRAINT uq_patient_contact
        UNIQUE (
            organization_id,
            branch_id,
            contact_type,
            contact_value
        )
);

-- Multiple addresses
CREATE TABLE patient_addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    branch_id UUID NOT NULL
        REFERENCES branches(id),

    patient_id UUID NOT NULL
        REFERENCES patients(id),

    address_type VARCHAR(50),

    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),

    city VARCHAR(100),
    district VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    pincode VARCHAR(20),

    is_primary BOOLEAN NOT NULL DEFAULT FALSE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID REFERENCES users(id)
);


-- Same patient can register multiple times
CREATE TABLE patient_registrations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    branch_id UUID NOT NULL
        REFERENCES branches(id),

    patient_id UUID NOT NULL
        REFERENCES patients(id),

    registration_number VARCHAR(100) NOT NULL,

    registration_status VARCHAR(50)
        NOT NULL DEFAULT 'REGISTERED',

    registered_at TIMESTAMPTZ
        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    created_by UUID NOT NULL
        REFERENCES users(id),

    created_at TIMESTAMPTZ
        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    UNIQUE (organization_id, branch_id, registration_number)
);

-- ==========================================
-- Patient Photos
-- ==========================================

CREATE TABLE patient_photos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL REFERENCES organizations(id),

    branch_id UUID NOT NULL REFERENCES branches(id),

    patient_id UUID NOT NULL REFERENCES patients(id),

    photo_url TEXT NOT NULL,

    is_primary BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    created_by UUID REFERENCES users(id)
);

-- ==========================================
-- Patient TRF
-- ==========================================

CREATE TABLE patient_trf (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL REFERENCES organizations(id),

    branch_id UUID NOT NULL REFERENCES branches(id),

    patient_id UUID NOT NULL REFERENCES patients(id),

    registration_id UUID NOT NULL REFERENCES patient_registrations(id),

    trf_number VARCHAR(50),

    trf_file_url TEXT NOT NULL,

    uploaded_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    uploaded_by UUID REFERENCES users(id),

    remarks TEXT,

    is_active BOOLEAN DEFAULT TRUE
);

-- Search indexes useful for F001/F002
CREATE INDEX idx_patients_org
ON patients(organization_id);

CREATE INDEX idx_patients_org_branch
ON patients(organization_id, branch_id);

CREATE INDEX idx_patients_name
ON patients(first_name, last_name);

CREATE INDEX idx_patients_dob
ON patients(date_of_birth);

CREATE INDEX idx_patient_identifier_org
ON patient_identifiers(organization_id);

CREATE INDEX idx_patient_identifier_org_branch
ON patient_identifiers(organization_id, branch_id);

CREATE INDEX idx_patient_identifier_value
ON patient_identifiers(identifier_value);

CREATE INDEX idx_patient_contact_org
ON patient_contacts(organization_id);

CREATE INDEX idx_patient_contact_org_branch
ON patient_contacts(organization_id, branch_id);

CREATE INDEX idx_patient_contact_value
ON patient_contacts(contact_value);

CREATE INDEX idx_patient_address_org
ON patient_addresses(organization_id);

CREATE INDEX idx_patient_address_org_branch
ON patient_addresses(organization_id, branch_id);

CREATE INDEX idx_patient_registration_patient
ON patient_registrations(patient_id);

CREATE INDEX idx_patient_registration_org
ON patient_registrations(organization_id);

CREATE INDEX idx_patient_registration_org_branch
ON patient_registrations(organization_id, branch_id);

CREATE INDEX idx_patient_registration_created_by
ON patient_registrations(created_by);

CREATE INDEX idx_patient_photos_org
ON patient_photos(organization_id);

CREATE INDEX idx_patient_photos_org_branch
ON patient_photos(organization_id, branch_id);

CREATE INDEX idx_patient_photos_patient
ON patient_photos(patient_id);

CREATE INDEX idx_patient_trf_org
ON patient_trf(organization_id);

CREATE INDEX idx_patient_trf_org_branch
ON patient_trf(organization_id, branch_id);

CREATE INDEX idx_patient_trf_patient
ON patient_trf(patient_id);

CREATE INDEX idx_patient_trf_registration
ON patient_trf(registration_id);
