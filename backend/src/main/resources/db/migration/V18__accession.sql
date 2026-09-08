
-- ==== source: database/schema/018_accession_master.sql ====

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

-- ==== source: database/schema/018_accession_tests.sql ====

-- Module : Accession Test
-- 018_accession_test.sql

CREATE TABLE accession_tests
(
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    branch_id UUID NOT NULL
        REFERENCES branches(id),

    accession_id UUID NOT NULL
        REFERENCES accession_master(id)
        ON DELETE CASCADE,

    billing_test_id UUID NOT NULL
        REFERENCES billing_tests(id),

    test_id UUID NOT NULL
        REFERENCES test_master(id),

    sample_type_id UUID
        REFERENCES sample_type_master(id),

    performing_lab_id UUID
        REFERENCES performing_lab_master(id),

    worksheet_id UUID
        REFERENCES worksheet_master(id),

    worklist_id UUID
        REFERENCES worklist_master(id),

    barcode VARCHAR(30),

    barcode_status VARCHAR(20) NOT NULL
        DEFAULT 'GENERATED'
        CHECK
        (
            barcode_status IN
            (
                'GENERATED',
                'PRINTED',
                'REPRINTED',
                'CANCELLED'
            )
        ),

    print_count INTEGER NOT NULL DEFAULT 0,

    last_printed_at TIMESTAMPTZ,

    last_printed_by UUID
        REFERENCES users(id),

    sample_status VARCHAR(30) NOT NULL
        DEFAULT 'PENDING'
        CHECK
        (
            sample_status IN
            (
                'PENDING',
                'COLLECTED',
                'RECEIVED',
                'PROCESSING',
                'COMPLETED',
                'REJECTED'
            )
        ),

    collection_status VARCHAR(30) NOT NULL
        DEFAULT 'NOT_COLLECTED'
        CHECK
        (
            collection_status IN
            (
                'NOT_COLLECTED',
                'COLLECTED',
                'PARTIALLY_COLLECTED'
            )
        ),

    authorization_status VARCHAR(30) NOT NULL
        DEFAULT 'PENDING'
        CHECK
        (
            authorization_status IN
            (
                'PENDING',
                'AUTHORIZED',
                'REJECTED'
            )
        ),

    report_status VARCHAR(30) NOT NULL
        DEFAULT 'PENDING'
        CHECK
        (
            report_status IN
            (
                'PENDING',
                'READY',
                'RELEASED'
            )
        ),

    remarks TEXT,

    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    created_by UUID
        REFERENCES users(id),

    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    updated_by UUID
        REFERENCES users(id),

    is_active BOOLEAN DEFAULT TRUE,

    CONSTRAINT uq_accession_test
        UNIQUE(accession_id, billing_test_id),

    CONSTRAINT uq_accession_tests_barcode
        UNIQUE(organization_id, branch_id, barcode)
);

CREATE INDEX idx_accession_tests_accession
ON accession_tests(accession_id);

CREATE INDEX idx_accession_tests_test
ON accession_tests(test_id);

CREATE INDEX idx_accession_tests_barcode
ON accession_tests(barcode);

CREATE INDEX idx_accession_tests_sample_status
ON accession_tests(sample_status);

CREATE INDEX idx_accession_tests_collection_status
ON accession_tests(collection_status);

CREATE INDEX idx_accession_tests_authorization
ON accession_tests(authorization_status);

CREATE INDEX idx_accession_tests_report
ON accession_tests(report_status);

CREATE INDEX idx_accession_tests_org_accession
ON accession_tests(organization_id, accession_id);

CREATE INDEX idx_accession_tests_org_branch
ON accession_tests(organization_id, branch_id);

CREATE INDEX idx_accession_tests_org_barcode
ON accession_tests(organization_id, barcode);

CREATE INDEX idx_accession_tests_org_branch_barcode
ON accession_tests(organization_id, branch_id, barcode);

--function
CREATE OR REPLACE FUNCTION generate_accession_barcode()
RETURNS TRIGGER
LANGUAGE plpgsql
AS
$$
DECLARE
    v_sequence INTEGER;
BEGIN

    SELECT
        COALESCE(MAX(RIGHT(barcode,6)::INTEGER),0)+1
    INTO v_sequence
    FROM accession_tests
    WHERE barcode LIKE
        'PUN-' || TO_CHAR(CURRENT_DATE,'YYMMDD') || '-%'
      AND organization_id = NEW.organization_id
      AND branch_id = NEW.branch_id;
    -- NOTE: source (018_accession_tests.sql) had a stray ';' ending the WHERE
    -- clause after the first AND, which is a syntax error. Joined into one
    -- WHERE clause here. See backend/progress.md Log for 2026-09-07 / Chunk 0.1.

    NEW.barcode :=
        'PUN-'
        || TO_CHAR(CURRENT_DATE,'YYMMDD')
        || '-'
        || LPAD(v_sequence::TEXT,6,'0');

    RETURN NEW;

END;
$$;
