-- Module : Test Package Management
-- 034_test_package_master.sql

CREATE TABLE test_package_master
(
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    branch_id UUID NOT NULL
        REFERENCES branches(id),

    test_category_id UUID
        REFERENCES test_category_master(id),

    billing_category_id UUID
        REFERENCES billing_category_master(id),

    package_code VARCHAR(50) NOT NULL,

    package_name VARCHAR(200) NOT NULL,

    display_name VARCHAR(200),

    short_code VARCHAR(50),


    selling_price NUMERIC(10,2) NOT NULL DEFAULT 0,

    cost_price NUMERIC(10,2) NOT NULL DEFAULT 0,


    tat_minutes INTEGER DEFAULT 0,

    description TEXT,

    is_active BOOLEAN DEFAULT TRUE,


    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    created_by UUID
        REFERENCES users(id),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    updated_by UUID
        REFERENCES users(id),


    CONSTRAINT uq_test_package_code
        UNIQUE (organization_id, branch_id, package_code),

    CONSTRAINT uq_test_package_name
        UNIQUE (organization_id, branch_id, package_name)
);


CREATE INDEX idx_test_package_org
ON test_package_master(organization_id);

CREATE INDEX idx_test_package_org_branch
ON test_package_master(organization_id, branch_id);

CREATE INDEX idx_test_package_category
ON test_package_master(test_category_id);

CREATE INDEX idx_test_package_billing_category
ON test_package_master(billing_category_id);

CREATE INDEX idx_test_package_code
ON test_package_master(package_code);

CREATE INDEX idx_test_package_name
ON test_package_master(package_name);

CREATE INDEX idx_test_package_active
ON test_package_master(is_active);
