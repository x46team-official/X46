-- Module 024 : QC Master
-- Description : Stores QC lot information and expected         values for quality control materials.


CREATE TABLE qc_master (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    branch_id UUID NOT NULL
        REFERENCES branches(id),

    instrument_id UUID NOT NULL
        REFERENCES instrument_master(id),

    test_id UUID NOT NULL
        REFERENCES test_master(id),

    parameter_id UUID NOT NULL
        REFERENCES parameter_master(id),

    qc_level VARCHAR(20) NOT NULL
        CHECK (
            qc_level IN (
                'LEVEL_1',
                'LEVEL_2',
                'LEVEL_3'
            )
        ),

    lot_number VARCHAR(50) NOT NULL,

    manufacturer VARCHAR(100),

    mean_value NUMERIC(10,3) NOT NULL,

    standard_deviation NUMERIC(10,3) NOT NULL,

    acceptable_min NUMERIC(10,3) NOT NULL,

    acceptable_max NUMERIC(10,3) NOT NULL,

    expiry_date DATE,

    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
        CHECK (
            status IN (
                'ACTIVE',
                'INACTIVE',
                'EXPIRED'
            )
        ),

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    created_by UUID
        REFERENCES users(id),

    updated_at TIMESTAMPTZ,

    updated_by UUID
        REFERENCES users(id),

    deleted_at TIMESTAMPTZ,

    deleted_by UUID
        REFERENCES users(id),

    CONSTRAINT uq_qc_master
        UNIQUE (
            organization_id,
            branch_id,
            instrument_id,
            test_id,
            parameter_id,
            qc_level,
            lot_number
        )
);

CREATE INDEX idx_qc_master_org
ON qc_master(organization_id);

CREATE INDEX idx_qc_master_org_branch
ON qc_master(organization_id, branch_id);

CREATE INDEX idx_qc_master_instrument
ON qc_master(instrument_id);

CREATE INDEX idx_qc_master_test
ON qc_master(test_id);

CREATE INDEX idx_qc_master_parameter
ON qc_master(parameter_id);

CREATE INDEX idx_qc_master_status
ON qc_master(status);
