CREATE TABLE billing_category_master(

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL REFERENCES organizations(id),
    branch_id UUID NOT NULL REFERENCES branches(id),

    billing_category_code VARCHAR(30) NOT NULL,
    billing_category_name VARCHAR(100) NOT NULL,

    description TEXT,

    is_default BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID REFERENCES users(id),

    CONSTRAINT uq_billing_category_code
        UNIQUE(organization_id, branch_id, billing_category_code),

    CONSTRAINT uq_billing_category_name
        UNIQUE(organization_id, branch_id, billing_category_name)
);

CREATE INDEX idx_billing_category_org
ON billing_category_master(organization_id);

CREATE INDEX idx_billing_category_org_branch
ON billing_category_master(organization_id, branch_id);

CREATE INDEX idx_billing_category_code
ON billing_category_master(billing_category_code);

CREATE INDEX idx_billing_category_name
ON billing_category_master(billing_category_name);

CREATE INDEX idx_billing_category_active
ON billing_category_master(is_active);
