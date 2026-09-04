
-- Module 023 : Instrument Test Mapping
-- Description : Maps instrument test/parameter codes  to LIMS tests and parameters


CREATE TABLE instrument_test_mapping (

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

    machine_test_code VARCHAR(50) NOT NULL,

    machine_parameter_code VARCHAR(50) NOT NULL,

    display_order INTEGER NOT NULL DEFAULT 1,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

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

    CONSTRAINT uq_instrument_mapping
        UNIQUE (
            organization_id,
            branch_id,
            instrument_id,
            machine_test_code,
            machine_parameter_code
        )
);


CREATE INDEX idx_itm_org
ON instrument_test_mapping(organization_id);

CREATE INDEX idx_itm_org_branch
ON instrument_test_mapping(organization_id, branch_id);

CREATE INDEX idx_itm_instrument
ON instrument_test_mapping(instrument_id);

CREATE INDEX idx_itm_test
ON instrument_test_mapping(test_id);

CREATE INDEX idx_itm_parameter
ON instrument_test_mapping(parameter_id);

CREATE INDEX idx_itm_active
ON instrument_test_mapping(is_active);
