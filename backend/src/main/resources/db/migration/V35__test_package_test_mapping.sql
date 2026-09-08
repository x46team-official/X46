-- Module : Test Package Management
-- 035_test_package_test_mapping.sql

CREATE TABLE test_package_test_mapping
(
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id) ON DELETE CASCADE,

    branch_id UUID NOT NULL
        REFERENCES branches(id),

    package_id UUID NOT NULL
        REFERENCES test_package_master(id) ON DELETE CASCADE,

    test_id UUID NOT NULL
        REFERENCES test_master(id),

    display_order INTEGER NOT NULL DEFAULT 1,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL
        DEFAULT CURRENT_TIMESTAMP,

    created_by UUID
        REFERENCES users(id),

    updated_at TIMESTAMPTZ NOT NULL
        DEFAULT CURRENT_TIMESTAMP,

    updated_by UUID
        REFERENCES users(id),

    CONSTRAINT uq_test_package_test_mapping
        UNIQUE (organization_id, branch_id, package_id, test_id)
);

CREATE INDEX idx_tptm_org
ON test_package_test_mapping(organization_id);

CREATE INDEX idx_tptm_org_branch
ON test_package_test_mapping(organization_id, branch_id);

CREATE INDEX idx_tptm_package
ON test_package_test_mapping(package_id);

CREATE INDEX idx_tptm_test
ON test_package_test_mapping(test_id);

CREATE INDEX idx_tptm_active
ON test_package_test_mapping(is_active);


-- Link billing line items back to the package they were generated from,
-- so a package selection expands into one billing_tests row per member
-- test while remaining traceable as a single package purchase.
ALTER TABLE billing_tests
ADD COLUMN package_id UUID
    REFERENCES test_package_master(id);

CREATE INDEX idx_billing_tests_package
ON billing_tests(package_id);
