
-- Module : Department Management
-- File   : 007_department_master.sql
-- 

CREATE TABLE department_master (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL REFERENCES organizations(id),
    branch_id UUID NOT NULL REFERENCES branches(id),

    department_name VARCHAR(100) NOT NULL,
    department_code VARCHAR(30),

    description TEXT,

    is_active BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID REFERENCES users(id)
);

CREATE INDEX idx_department_org
ON department_master(organization_id);

CREATE INDEX idx_department_org_branch
ON department_master(organization_id, branch_id);

CREATE INDEX idx_department_name
ON department_master(department_name);


ALTER TABLE department_master
ADD CONSTRAINT uq_department_org_name
UNIQUE (organization_id, branch_id, department_name);

ALTER TABLE department_master
ADD CONSTRAINT uq_department_org_code
UNIQUE (organization_id, branch_id, department_code);
