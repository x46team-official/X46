CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Customer lab / hospital / diagnostic organization
CREATE TABLE organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_code VARCHAR(50) NOT NULL UNIQUE,
    organization_name VARCHAR(200) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Physical branch of organization
CREATE TABLE branches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id),
    branch_code VARCHAR(50) NOT NULL,
    branch_name VARCHAR(200) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (organization_id, branch_code)
);

-- Staff roles
CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id),
    branch_id UUID NOT NULL REFERENCES branches(id),
    role_code VARCHAR(50) NOT NULL,
    role_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_roles_org_branch_code
        UNIQUE (organization_id, branch_id, role_code)
);

-- Staff login identities
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id),
    branch_id UUID NOT NULL REFERENCES branches(id),
    username VARCHAR(100) NOT NULL,
    email VARCHAR(255),
    password_hash TEXT NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (organization_id, branch_id, username)
);

-- User can have one or more roles
CREATE TABLE user_roles (
    organization_id UUID NOT NULL REFERENCES organizations(id),
    branch_id UUID NOT NULL REFERENCES branches(id),
    user_id UUID NOT NULL REFERENCES users(id),
    role_id UUID NOT NULL REFERENCES roles(id),
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, role_id)
);

-- Important operation history
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id),
    branch_id UUID NOT NULL REFERENCES branches(id),
    user_id UUID REFERENCES users(id),
    action_type VARCHAR(50) NOT NULL,
    entity_type VARCHAR(100) NOT NULL,
    entity_id UUID,
    old_values JSONB,
    new_values JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_branches_org
ON branches(organization_id);

CREATE INDEX idx_roles_org_branch
ON roles(organization_id, branch_id);

CREATE INDEX idx_users_org_branch
ON users(organization_id, branch_id);

CREATE INDEX idx_user_roles_org_branch
ON user_roles(organization_id, branch_id);

CREATE INDEX idx_audit_logs_org_branch
ON audit_logs(organization_id, branch_id);
