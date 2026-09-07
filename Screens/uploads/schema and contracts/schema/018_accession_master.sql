-- Module : Accession Master
-- 018_accession_master.sql

CREATE TABLE accession_master
(
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    branch_id UUID NOT NULL
        REFERENCES branches(id),

    billing_id UUID NOT NULL
        REFERENCES billing_master(id),

    patient_registration_id UUID NOT NULL
        REFERENCES patient_registrations(id),

    accession_number VARCHAR(30) NOT NULL,

    accession_date TIMESTAMPTZ NOT NULL
        DEFAULT CURRENT_TIMESTAMP,

    priority VARCHAR(20) NOT NULL
        DEFAULT 'NORMAL'
        CHECK (priority IN ('NORMAL', 'URGENT', 'STAT')),

    status VARCHAR(30) NOT NULL
        DEFAULT 'PENDING'
        CHECK (
            status IN (
                'PENDING',
                'PARTIALLY_COLLECTED',
                'COLLECTED',
                'PROCESSING',
                'COMPLETED',
                'CANCELLED'
            )
        ),

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL
        DEFAULT CURRENT_TIMESTAMP,

    created_by UUID
        REFERENCES users(id),

    updated_at TIMESTAMPTZ NOT NULL
        DEFAULT CURRENT_TIMESTAMP,

    updated_by UUID
        REFERENCES users(id),

    is_active BOOLEAN NOT NULL
        DEFAULT TRUE,

    CONSTRAINT uq_accession_number
        UNIQUE (organization_id, branch_id, accession_number)
);



CREATE INDEX idx_accession_number
    ON accession_master(accession_number);

CREATE INDEX idx_accession_patient
    ON accession_master(patient_registration_id);

CREATE INDEX idx_accession_billing
    ON accession_master(billing_id);

CREATE INDEX idx_accession_status
    ON accession_master(status);

CREATE INDEX idx_accession_org_status
    ON accession_master(organization_id, status);

CREATE INDEX idx_accession_org_branch
    ON accession_master(organization_id, branch_id);

CREATE INDEX idx_accession_org_date
    ON accession_master(organization_id, accession_date);

CREATE INDEX idx_accession_org_patient
    ON accession_master(organization_id, patient_registration_id);

CREATE INDEX idx_accession_org_number
    ON accession_master(organization_id, accession_number);

CREATE INDEX idx_accession_org_billing
    ON accession_master(organization_id, billing_id);
