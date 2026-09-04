--Module 026 : Refund Description : Stores refund details

CREATE TABLE refund (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    branch_id UUID NOT NULL
        REFERENCES branches(id),

    payment_id UUID NOT NULL
        REFERENCES payment(id),

    refund_amount NUMERIC(12,2) NOT NULL
        CHECK (refund_amount > 0),

    refund_reason TEXT,

    refund_status VARCHAR(20) NOT NULL DEFAULT 'APPROVED'
        CHECK (
            refund_status IN (
                'PENDING',
                'APPROVED',
                'REJECTED',
                'COMPLETED'
            )
        ),

    refund_date TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

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

CREATE INDEX idx_refund_payment
ON refund(payment_id);

CREATE INDEX idx_refund_org
ON refund(organization_id);

CREATE INDEX idx_refund_org_branch
ON refund(organization_id, branch_id);

CREATE INDEX idx_refund_status
ON refund(refund_status);
