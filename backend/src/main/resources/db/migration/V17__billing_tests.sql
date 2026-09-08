-- Module : Billing Tests
-- 017_billing_tests.sql

CREATE TABLE billing_tests
(
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    branch_id UUID NOT NULL
        REFERENCES branches(id),

    billing_id UUID NOT NULL
        REFERENCES billing_master(id),

    test_id UUID NOT NULL
        REFERENCES test_master(id),

    sample_type_id UUID
        REFERENCES sample_type_master(id),

    performing_lab_id UUID
        REFERENCES performing_lab_master(id),

    quantity INTEGER NOT NULL DEFAULT 1,

    rate NUMERIC(10,2) NOT NULL DEFAULT 0,

    discount_amount NUMERIC(10,2) DEFAULT 0,

    concession_amount NUMERIC(10,2) DEFAULT 0,

    net_amount NUMERIC(10,2) DEFAULT 0,

    tat_minutes INTEGER,

    barcode VARCHAR(100),

    status VARCHAR(30) DEFAULT 'Pending',

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID REFERENCES users(id)
);


CREATE INDEX idx_billing_tests_org
ON billing_tests(organization_id);

CREATE INDEX idx_billing_tests_org_branch
ON billing_tests(organization_id, branch_id);

CREATE INDEX idx_billing_tests_bill
ON billing_tests(billing_id);

CREATE INDEX idx_billing_tests_test
ON billing_tests(test_id);

CREATE INDEX idx_billing_tests_sample
ON billing_tests(sample_type_id);

CREATE INDEX idx_billing_tests_lab
ON billing_tests(performing_lab_id);

CREATE INDEX idx_billing_tests_status
ON billing_tests(status);

CREATE INDEX idx_billing_tests_barcode
ON billing_tests(barcode);
