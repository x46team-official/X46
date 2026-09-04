-- Module 020 : Parameter Master
-- 020_parameter_master.sql

CREATE TABLE parameter_master(
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id) on DELETE CASCADE,
  branch_id UUID NOT NULL REFERENCES branches(id),

  parameter_code  VARCHAR(50) NOT NULL,

  parameter_name VARCHAR(255) NOT NULL,

  data_type  VARCHAR(20) NOT NULL 
     DEFAULT 'NUMERIC'
     CHECK (
      data_type IN 
      (
            
                'NUMERIC',
                'TEXT',
                'BOOLEAN',
                'DATE',
                'DATETIME'   
      )
     ),

     result_type  VARCHAR(20) NOT NULL 
      DEFAULT 'NUMERIC'
     CHECK (
      result_type IN 
      (
            
                'NUMERIC',
                'TEXT',
                'BOOLEAN',
                'DATE',
                'DATETIME'   
      )
     ),

        unit VARCHAR(50),

        default_reference_range VARCHAR(255),

        default_min_value NUMERIC (18,4),

        default_max_value NUMERIC(18,4),

        critical_low NUMERIC(18,4),

        critical_high  NUMERIC(18,4),
        decimal_places SMALLINT NOT NULL
        DEFAULT 2,

    formula TEXT,

    method VARCHAR(255),

    display_order INTEGER NOT NULL
        DEFAULT 1,

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

    CONSTRAINT uq_parameter_master_code
        UNIQUE (organization_id, branch_id, parameter_code),

    CONSTRAINT uq_parameter_master_name
        UNIQUE (organization_id, branch_id, parameter_name)
);

CREATE INDEX idx_parameter_master_org
ON parameter_master(organization_id);

CREATE INDEX idx_parameter_master_org_branch
ON parameter_master(organization_id, branch_id);

CREATE INDEX idx_parameter_master_code
ON parameter_master(parameter_code);

CREATE INDEX idx_parameter_master_name
ON parameter_master(parameter_name);

CREATE INDEX idx_parameter_master_active
ON parameter_master(is_active);
