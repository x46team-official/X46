
-- Module 026 : Payment Description : Stores payment details for patient bills

CREATE TABLE payment (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    branch_id UUID NOT NULL
        REFERENCES branches(id),

    accession_id UUID NOT NULL
        REFERENCES accession_master(id),

    billing_master_id UUID NOT NULL
        REFERENCES billing_master(id),

    patient_registration_id UUID NOT NULL
REFERENCES patient_registrations(id),

    payment_mode VARCHAR(20) NOT NULL
        CHECK (
            payment_mode IN (
                'CASH',
                'CARD',
                'UPI',
                'NET_BANKING',
                'CHEQUE'
            )
        ),

    amount_paid NUMERIC(12,2) NOT NULL
        CHECK (amount_paid >= 0),

    transaction_reference VARCHAR(100),

    payment_status VARCHAR(20) NOT NULL DEFAULT 'SUCCESS'
        CHECK (
            payment_status IN (
                'SUCCESS',
                'PENDING',
                'FAILED',
                'PARTIAL'
            )
        ),

    payment_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    created_by UUID
        REFERENCES users(id),

    updated_at TIMESTAMPTZ,

    updated_by UUID
        REFERENCES users(id),

    deleted_at TIMESTAMPTZ,

    deleted_by UUID
        REFERENCES users(id)
);

CREATE INDEX idx_payment_accession
ON payment(accession_id);

CREATE INDEX idx_payment_org
ON payment(organization_id);

CREATE INDEX idx_payment_org_branch
ON payment(organization_id, branch_id);

CREATE INDEX idx_payment_bill
ON payment(billing_master_id);

CREATE INDEX idx_payment_patient
ON payment(patient_registration_id);

CREATE INDEX idx_payment_status
ON payment(payment_status);
