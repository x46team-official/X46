-- Module 020 : Result Entry
-- File : 020_result_entry.sql


CREATE TABLE result_entry
(
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id)
        ON DELETE CASCADE,

    branch_id UUID NOT NULL
        REFERENCES branches(id),

    accession_test_id UUID NOT NULL
        REFERENCES accession_tests(id)
        ON DELETE CASCADE,

    result_status VARCHAR(20) NOT NULL
        DEFAULT 'PENDING'
        CHECK (
            result_status IN
            (
                'PENDING',
                'IN_PROGRESS',
                'COMPLETED',
                'AUTHORIZED',
                'REJECTED'
            )
        ),

    entered_at TIMESTAMPTZ,

    entered_by UUID
        REFERENCES users(id),

    verified_at TIMESTAMPTZ,

    verified_by UUID
        REFERENCES users(id),

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

    CONSTRAINT uq_result_entry
        UNIQUE (organization_id, branch_id, accession_test_id)
);

CREATE INDEX idx_result_entry_org
ON result_entry(organization_id);

CREATE INDEX idx_result_entry_org_branch
ON result_entry(organization_id, branch_id);

CREATE INDEX idx_result_entry_accession
ON result_entry(accession_test_id);

CREATE INDEX idx_result_entry_status
ON result_entry(result_status);

CREATE INDEX idx_result_entry_active
ON result_entry(is_active);
