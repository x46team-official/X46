
-- F001 PATIENT REGISTRATION - PHASE 2
-- Clinical History (Optimized)


CREATE TABLE clinical_master
(
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    branch_id UUID NOT NULL
        REFERENCES branches(id),

    clinical_type VARCHAR(30) NOT NULL,
    -- DISEASE
    -- SYMPTOM
    -- ALLERGY
    -- CONDITION

    clinical_code VARCHAR(50),

    clinical_name VARCHAR(200) NOT NULL,

    description TEXT,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID REFERENCES users(id),

    UNIQUE (organization_id, branch_id, clinical_type, clinical_name)
);



CREATE TABLE patient_clinical_history
(
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    branch_id UUID NOT NULL
        REFERENCES branches(id),

    patient_id UUID NOT NULL
        REFERENCES patients(id),

    registration_id UUID
        REFERENCES patient_registrations(id),

    clinical_id UUID NOT NULL
        REFERENCES clinical_master(id),

    severity VARCHAR(30),

    duration_value INTEGER,

    duration_unit VARCHAR(20),

    status VARCHAR(30),

    diagnosed_date DATE,

    notes TEXT,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID REFERENCES users(id)
);


-- INDEXES


CREATE INDEX idx_clinical_master_org
ON clinical_master(organization_id);

CREATE INDEX idx_clinical_master_org_branch
ON clinical_master(organization_id, branch_id);

CREATE INDEX idx_patient_clinical_patient
ON patient_clinical_history(patient_id);

CREATE INDEX idx_patient_clinical_org_branch
ON patient_clinical_history(organization_id, branch_id);

CREATE INDEX idx_patient_clinical_registration
ON patient_clinical_history(registration_id);

CREATE INDEX idx_patient_clinical_clinical
ON patient_clinical_history(clinical_id);
