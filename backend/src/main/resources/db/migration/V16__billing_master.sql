-- Module : Billing Management
-- File   : 016_billing_master.sql

CREATE TABLE billing_master
(
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    branch_id UUID NOT NULL
        REFERENCES branches(id),

    patient_registration_id UUID NOT NULL
        REFERENCES patient_registrations(id),

    bill_number VARCHAR(30) NOT NULL,

    bill_date TIMESTAMPTZ NOT NULL
        DEFAULT CURRENT_TIMESTAMP,

    billing_category_id UUID
        REFERENCES billing_category_master(id),

    referring_doctor_id UUID
        REFERENCES users(id),

    total_amount NUMERIC(10,2) DEFAULT 0,

    discount_amount NUMERIC(10,2) DEFAULT 0,

    concession_amount NUMERIC(10,2) DEFAULT 0,

    additional_amount NUMERIC(10,2) DEFAULT 0,

    payable_amount NUMERIC(10,2) DEFAULT 0,

    paid_amount NUMERIC(10,2) DEFAULT 0,

    balance_amount NUMERIC(10,2) DEFAULT 0,

    refund_amount NUMERIC(10,2) DEFAULT 0,

    payment_mode VARCHAR(30),

    transaction_reference VARCHAR(100),

    payment_status VARCHAR(30)
        DEFAULT 'Pending',

    remarks TEXT,

    is_cancelled BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    created_by UUID REFERENCES users(id),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    updated_by UUID REFERENCES users(id),

    CONSTRAINT uq_bill_number
        UNIQUE (organization_id, branch_id, bill_number)
);

CREATE INDEX idx_bill_org
ON billing_master(organization_id);

CREATE INDEX idx_bill_org_branch
ON billing_master(organization_id, branch_id);

CREATE INDEX idx_bill_patient
ON billing_master(patient_registration_id);

CREATE INDEX idx_bill_number
ON billing_master(bill_number);

CREATE INDEX idx_bill_date
ON billing_master(bill_date);

CREATE INDEX idx_bill_status
ON billing_master(payment_status);
