--Module 027 : Administration
--Description : Organization/Lab-level configuration that affects laboratory workflows.

CREATE TABLE application_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL REFERENCES organizations(id),
    branch_id UUID NOT NULL REFERENCES branches(id),

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

    CONSTRAINT uq_application_settings
        UNIQUE(organization_id, branch_id, config_key)
);

CREATE INDEX idx_application_settings_org
ON application_settings(organization_id);

CREATE INDEX idx_application_settings_org_branch
ON application_settings(organization_id, branch_id);

CREATE INDEX idx_application_settings_key
ON application_settings(config_key);

CREATE INDEX idx_application_settings_active
ON application_settings(is_active);
