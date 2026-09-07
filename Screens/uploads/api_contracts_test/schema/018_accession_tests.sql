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
      AND organization_id = NEW.organization_id;
      AND branch_id = NEW.branch_id;

    NEW.barcode :=
        'PUN-'
        || TO_CHAR(CURRENT_DATE,'YYMMDD')
        || '-'
        || LPAD(v_sequence::TEXT,6,'0');

    RETURN NEW;

END;
$$;
