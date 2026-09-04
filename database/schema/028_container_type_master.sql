CREATE TABLE container_type_master (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    branch_id UUID NOT NULL
        REFERENCES branches(id),

    container_name VARCHAR(100) NOT NULL,
    description TEXT,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID REFERENCES users(id),

    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES users(id),

    CONSTRAINT uq_container_type
        UNIQUE (organization_id, branch_id, container_name)
);

CREATE INDEX idx_container_type_org
ON container_type_master(organization_id);

CREATE INDEX idx_container_type_org_branch
ON container_type_master(organization_id, branch_id);

CREATE INDEX idx_container_type_name
ON container_type_master(container_name);
