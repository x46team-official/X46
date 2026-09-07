-- Module 024 : QC Run Log Description : Stores Quality Control run results


CREATE TABLE qc_run_log (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    branch_id UUID NOT NULL
        REFERENCES branches(id),

    qc_master_id UUID NOT NULL
        REFERENCES qc_master(id),

    instrument_id UUID NOT NULL
        REFERENCES instrument_master(id),

    actual_value NUMERIC(10,3) NOT NULL,

    z_score NUMERIC(10,3),

    result_status VARCHAR(20) NOT NULL
        CHECK (
            result_status IN (
                'PASS',
                'FAIL'
            )
        ),

    rule_triggered VARCHAR(20)
        CHECK (
            rule_triggered IN (
                '1-2S',
                '1-3S',
                '2-2S',
                'R-4S',
                '4-1S',
                '10X'
            )
        ),

    remarks TEXT,

    run_datetime TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

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

CREATE INDEX idx_qc_run_org
ON qc_run_log(organization_id);

CREATE INDEX idx_qc_run_org_branch
ON qc_run_log(organization_id, branch_id);

CREATE INDEX idx_qc_run_master
ON qc_run_log(qc_master_id);

CREATE INDEX idx_qc_run_instrument
ON qc_run_log(instrument_id);

CREATE INDEX idx_qc_run_status
ON qc_run_log(result_status);

CREATE INDEX idx_qc_run_datetime
ON qc_run_log(run_datetime);
