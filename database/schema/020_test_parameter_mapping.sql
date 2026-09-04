-- Module 020 : Test Parameter Mapping
--  020_test_parameter_mapping.sql

CREATE TABLE test_parameter_mapping
(
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  organization_id UUID NOT NULL REFERENCES organizations(id) on DELETE CASCADE,
  branch_id UUID NOT NULL REFERENCES branches(id),

  test_id UUID NOT NULL REFERENCES test_master(id),

  parameter_id UUID NOT NULL REFERENCES parameter_master(id) on DELETE CASCADE,

  display_order  INTEGER NOT NULL DEFAULT 1,

  unit VARCHAR(50),

  reference_range VARCHAR(255),

  min_value NUMERIC(10,3),

  max_value NUMERIC(10,3),

  critical_low NUMERIC(10,3),

  critical_high NUMERIC(10,3),

  is_mandatory BOOLEAN NOT NULL DEFAULT TRUE,

  formula TEXT,

  remarks TEXT,

  created_at TIMESTAMPTZ NOT NULL
    DEFAULT CURRENT_TIMESTAMP,

created_by UUID
    REFERENCES users(id),

updated_at TIMESTAMPTZ NOT NULL
    DEFAULT CURRENT_TIMESTAMP,

updated_by UUID
    REFERENCES users(id),

  is_active BOOLEAN NOT NULL
    DEFAULT TRUE,

  CONSTRAINT ug_test_parameter_mapping
     UNIQUE (organization_id, branch_id, test_id, parameter_id) 

);

CREATE INDEX idx_tpm_org
ON test_parameter_mapping(organization_id);

CREATE INDEX idx_tpm_org_branch
ON test_parameter_mapping(organization_id, branch_id);

CREATE INDEX idx_tpm_test
ON test_parameter_mapping(test_id);

CREATE INDEX idx_tpm_parameter
ON test_parameter_mapping(parameter_id);

CREATE INDEX idx_tpm_active
ON test_parameter_mapping(is_active);
