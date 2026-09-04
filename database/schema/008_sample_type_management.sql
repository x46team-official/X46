-- Module : Sample Type Management
-- 008_sample_type_management

CREATE TABLE sample_type_master (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    branch_id UUID NOT NULL
        REFERENCES branches(id),

    sample_code VARCHAR(30) NOT NULL,
    sample_name VARCHAR(100) NOT NULL,
    print_name VARCHAR(100),

    description TEXT,

    container_type VARCHAR(100),
    container_color VARCHAR(50),

    minimum_volume NUMERIC(10,2),
    volume_unit VARCHAR(20),

    storage_temperature VARCHAR(50),

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID REFERENCES users(id),

    CONSTRAINT uq_sample_type_code
        UNIQUE (organization_id, branch_id, sample_code),

    CONSTRAINT uq_sample_type_name
        UNIQUE (organization_id, branch_id, sample_name)
);

-- =====================================================
-- Indexes
-- =====================================================

CREATE INDEX idx_sample_type_org
ON sample_type_master(organization_id);

CREATE INDEX idx_sample_type_org_branch
ON sample_type_master(organization_id, branch_id);

CREATE INDEX idx_sample_type_name
ON sample_type_master(sample_name);

CREATE INDEX idx_sample_type_code
ON sample_type_master(sample_code);

CREATE INDEX idx_sample_type_active
ON sample_type_master(is_active);
