
-- ==== source: database/schema/027_application_settings.sql ====

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

-- ==== source: database/schema/027_menu_permission.sql ====

--Module 027 : Administration
--Description : Controls menu visibility by role.

CREATE TABLE menu_permission (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    branch_id UUID NOT NULL
        REFERENCES branches(id),

    role_id UUID NOT NULL
        REFERENCES roles(id),

    menu_name VARCHAR(100) NOT NULL,

    is_visible BOOLEAN NOT NULL DEFAULT TRUE,

    display_order INTEGER DEFAULT 0,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID REFERENCES users(id),

    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES users(id),

    CONSTRAINT uq_menu_permission
    UNIQUE (organization_id, branch_id, role_id, menu_name)
);

CREATE INDEX idx_menu_permission_role
ON menu_permission(role_id);

CREATE INDEX idx_menu_permission_org
ON menu_permission(organization_id);

CREATE INDEX idx_menu_permission_org_branch
ON menu_permission(organization_id, branch_id);

-- ==== source: database/schema/027_role_permission.sql ====

--Module 027 : Administration
--Description : Stores CRUD and workflow permissions for each role.

CREATE TABLE role_permission (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    branch_id UUID NOT NULL
        REFERENCES branches(id),

    role_id UUID NOT NULL
        REFERENCES roles(id),

    module_name VARCHAR(100) NOT NULL,

    can_create BOOLEAN NOT NULL DEFAULT FALSE,
    can_view BOOLEAN NOT NULL DEFAULT FALSE,
    can_update BOOLEAN NOT NULL DEFAULT FALSE,
    can_delete BOOLEAN NOT NULL DEFAULT FALSE,

    can_authorize BOOLEAN NOT NULL DEFAULT FALSE,
    can_print BOOLEAN NOT NULL DEFAULT FALSE,
    can_export BOOLEAN NOT NULL DEFAULT FALSE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID REFERENCES users(id),

    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES users(id),

    CONSTRAINT uq_role_permission
    UNIQUE (organization_id, branch_id, role_id, module_name)
);

CREATE INDEX idx_role_permission_role
ON role_permission(role_id);

CREATE INDEX idx_role_permission_org
ON role_permission(organization_id);

CREATE INDEX idx_role_permission_org_branch
ON role_permission(organization_id, branch_id);

-- ==== source: database/schema/027_system_configuration.sql ====

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
