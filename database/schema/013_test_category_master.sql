-- Module : Test Category Management
-- 013_test_category_master.sql

CREATE TABLE test_category_master(

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    branch_id UUID NOT NULL
        REFERENCES branches(id),

    category_code VARCHAR(30) NOT NULL,

    category_name VARCHAR(100) NOT NULL,

    description TEXT,

    display_order INTEGER DEFAULT 1,

    is_active BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID REFERENCES users(id),

    CONSTRAINT uq_test_category_code
        UNIQUE (organization_id, branch_id, category_code),

    CONSTRAINT uq_test_category_name
        UNIQUE (organization_id, branch_id, category_name)
);

CREATE INDEX idx_test_category_org
ON test_category_master(organization_id);

CREATE INDEX idx_test_category_org_branch
ON test_category_master(organization_id, branch_id);

CREATE INDEX idx_test_category_code
ON test_category_master(category_code);

CREATE INDEX idx_test_category_name
ON test_category_master(category_name);

CREATE INDEX idx_test_category_active
ON test_category_master(is_active);
