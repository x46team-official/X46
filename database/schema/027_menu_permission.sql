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
