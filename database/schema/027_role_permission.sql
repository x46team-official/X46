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
