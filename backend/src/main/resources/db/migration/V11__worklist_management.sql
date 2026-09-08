-- Module : 011_worklist_management
-- 011_worklist_management.sql

CREATE TABLE worklist_master(
 
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL REFERENCES organizations(id),
    branch_id UUID NOT NULL REFERENCES branches(id),
    department_id UUID NOT NULL REFERENCES department_master(id),

    worklist_code VARCHAR(30) NOT NULL,
    worklist_name VARCHAR(100) NOT NULL,

    description TEXT,
    sort_order VARCHAR(30) NOT NULL DEFAULT 'ASC',

    estimated_tat_minutes INTEGER,
    allow_generate_worklist BOOLEAN NOT NULL DEFAULT TRUE,

    allow_generate_worksheet BOOLEAN NOT NULL DEFAULT TRUE,

      
    allow_print BOOLEAN DEFAULT TRUE,

    allow_export BOOLEAN DEFAULT TRUE,

    is_default BOOLEAN DEFAULT FALSE,

    is_active BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID REFERENCES users(id)

);


CREATE INDEX idx_worklist_org
ON worklist_master(organization_id);

CREATE INDEX idx_worklist_org_branch
ON worklist_master(organization_id, branch_id);

CREATE INDEX idx_worklist_department
ON worklist_master(department_id);

CREATE INDEX idx_worklist_code
ON worklist_master(worklist_code);

CREATE INDEX idx_worklist_name
ON worklist_master(worklist_name);

CREATE INDEX idx_worklist_active
ON worklist_master(is_active);

ALTER TABLE worklist_master
ADD CONSTRAINT uq_worklist_code
UNIQUE (organization_id, branch_id, worklist_code);

ALTER TABLE worklist_master
ADD CONSTRAINT uq_worklist_name
UNIQUE (organization_id, branch_id, worklist_name);
