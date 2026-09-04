-- Module :Test Management
-- 015_test_master.sql


CREATE TABLE test_master
(
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    branch_id UUID NOT NULL
        REFERENCES branches(id),

    department_id UUID NOT NULL
        REFERENCES department_master(id),

    test_category_id UUID
        REFERENCES test_category_master(id),

    billing_category_id UUID
        REFERENCES billing_category_master(id),

    sample_type_id UUID
        REFERENCES sample_type_master(id),

    performing_lab_id UUID
        REFERENCES performing_lab_master(id),

    outsource_center_id UUID
        REFERENCES outsource_center_master(id),

    worksheet_id UUID
        REFERENCES worksheet_master(id),

    worklist_id UUID
        REFERENCES worklist_master(id),

   
    test_code VARCHAR(50) NOT NULL,

    test_name VARCHAR(200) NOT NULL,

    display_name VARCHAR(200),

    print_name VARCHAR(200),

    short_code VARCHAR(50),

   
    selling_price NUMERIC(10,2) NOT NULL DEFAULT 0,

    cost_price NUMERIC(10,2) NOT NULL DEFAULT 0,

    cprr NUMERIC(10,2) NOT NULL DEFAULT 0,

   
    test_method VARCHAR(200),

    test_type VARCHAR(100),

    tat_minutes INTEGER DEFAULT 0,

    machine_test_code VARCHAR(100),

    consumption_group VARCHAR(100),

   
    auto_approval BOOLEAN DEFAULT FALSE,

    automatically_authorize BOOLEAN DEFAULT FALSE,

    nabl_accredited BOOLEAN DEFAULT FALSE,

    mark_as_profile BOOLEAN DEFAULT FALSE,

    two_step_verification BOOLEAN DEFAULT FALSE,

    authorize_only_by_authorizer BOOLEAN DEFAULT FALSE,

    outsource_test BOOLEAN DEFAULT FALSE,

    notify_accession BOOLEAN DEFAULT FALSE,

  
    is_active BOOLEAN DEFAULT TRUE,

    description TEXT,

   
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    created_by UUID
        REFERENCES users(id),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    updated_by UUID
        REFERENCES users(id),

   
    CONSTRAINT uq_test_code
        UNIQUE (organization_id, branch_id, test_code),

    CONSTRAINT uq_test_name
        UNIQUE (organization_id, branch_id, test_name)
);



CREATE INDEX idx_test_org
ON test_master(organization_id);

CREATE INDEX idx_test_org_branch
ON test_master(organization_id, branch_id);

CREATE INDEX idx_test_department
ON test_master(department_id);

CREATE INDEX idx_test_category
ON test_master(test_category_id);

CREATE INDEX idx_test_billing_category
ON test_master(billing_category_id);

CREATE INDEX idx_test_sample
ON test_master(sample_type_id);

CREATE INDEX idx_test_performing_lab
ON test_master(performing_lab_id);

CREATE INDEX idx_test_outsource
ON test_master(outsource_center_id);

CREATE INDEX idx_test_worksheet
ON test_master(worksheet_id);

CREATE INDEX idx_test_worklist
ON test_master(worklist_id);

CREATE INDEX idx_test_code
ON test_master(test_code);

CREATE INDEX idx_test_name
ON test_master(test_name);

CREATE INDEX idx_test_active
ON test_master(is_active);


ALTER TABLE test_master
ADD CONSTRAINT fk_test_master_container_type
FOREIGN KEY (container_type_id)
REFERENCES container_type_master(id);
