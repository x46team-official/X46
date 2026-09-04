--Module 027 : Administration
--Description : This table stores organization-specific settings

CREATE TABLE system_configuration (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    branch_id UUID NOT NULL
        REFERENCES branches(id),

    config_key VARCHAR(100) NOT NULL,
    config_value TEXT NOT NULL,

    description TEXT,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID REFERENCES users(id),

    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES users(id),

    CONSTRAINT uq_system_configuration
        UNIQUE (organization_id, branch_id, config_key)
);

CREATE INDEX idx_system_configuration_org
ON system_configuration(organization_id);

CREATE INDEX idx_system_configuration_org_branch
ON system_configuration(organization_id, branch_id);

CREATE INDEX idx_system_configuration_key
ON system_configuration(config_key);

CREATE INDEX idx_system_configuration_active
ON system_configuration(is_active);
