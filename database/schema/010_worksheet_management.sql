-- Module : Worksheet Management
-- 010_worksheet_management.sql


CREATE TABLE worksheet_master
(
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL REFERENCES organizations(id),

    branch_id UUID NOT NULL REFERENCES branches(id),

    worksheet_code VARCHAR(30) NOT NULL,
    worksheet_name VARCHAR(100) NOT NULL,

    description TEXT,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID REFERENCES users(id)
);

CREATE INDEX idx_worksheet_org
ON worksheet_master(organization_id);

CREATE INDEX idx_worksheet_org_branch
ON worksheet_master(organization_id, branch_id);

CREATE INDEX idx_worksheet_code
ON worksheet_master(worksheet_code);

CREATE INDEX idx_worksheet_name
ON worksheet_master(worksheet_name);

ALTER TABLE worksheet_master
ADD CONSTRAINT uq_worksheet_code
UNIQUE (organization_id, branch_id, worksheet_code);

ALTER TABLE worksheet_master
ADD CONSTRAINT uq_worksheet_name
UNIQUE (organization_id, branch_id, worksheet_name);
