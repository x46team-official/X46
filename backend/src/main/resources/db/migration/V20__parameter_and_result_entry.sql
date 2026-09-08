
-- ==== source: database/schema/020_parameter_master.sql ====

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

-- ==== source: database/schema/020_result_entry.sql ====

-- Module 020 : Result Entry
-- File : 020_result_entry.sql


CREATE TABLE result_entry
(
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id)
        ON DELETE CASCADE,

    branch_id UUID NOT NULL
        REFERENCES branches(id),

    accession_test_id UUID NOT NULL
        REFERENCES accession_tests(id)
        ON DELETE CASCADE,

    result_status VARCHAR(20) NOT NULL
        DEFAULT 'PENDING'
        CHECK (
            result_status IN
            (
                'PENDING',
                'IN_PROGRESS',
                'COMPLETED',
                'AUTHORIZED',
                'REJECTED'
            )
        ),

    entered_at TIMESTAMPTZ,

    entered_by UUID
        REFERENCES users(id),

    verified_at TIMESTAMPTZ,

    verified_by UUID
        REFERENCES users(id),

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

    CONSTRAINT uq_result_entry
        UNIQUE (organization_id, branch_id, accession_test_id)
);

CREATE INDEX idx_result_entry_org
ON result_entry(organization_id);

CREATE INDEX idx_result_entry_org_branch
ON result_entry(organization_id, branch_id);

CREATE INDEX idx_result_entry_accession
ON result_entry(accession_test_id);

CREATE INDEX idx_result_entry_status
ON result_entry(result_status);

CREATE INDEX idx_result_entry_active
ON result_entry(is_active);

-- ==== source: database/schema/020_result_entry_details.sql ====

-- Module 020 : Result Entry Details
-- File : 020_result_entry_details.sql

CREATE TABLE result_entry_details
(
   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

   organization_id UUID NOT NULL REFERENCES organizations(id) on DELETE CASCADE,

   branch_id UUID NOT NULL REFERENCES branches(id),

   result_entry_id UUID NOT NULL
    REFERENCES result_entry(id),
  
  parameter_id UUID NOT NULL 
    REFERENCES parameter_master(id),

  result_value VARCHAR(255),

  result_flag VARCHAR(20)
   CHECK (
    result_flag IN
    (
       'NORMAL',
                'HIGH',
                'LOW',
                'CRITICAL',
                'ABNORMAL'
    )
   ),

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

    CONSTRAINT uq_result_parameter
        UNIQUE (result_entry_id, parameter_id)
);

CREATE INDEX idx_red_org
ON result_entry_details(organization_id);

CREATE INDEX idx_red_org_branch
ON result_entry_details(organization_id, branch_id);

CREATE INDEX idx_red_result
ON result_entry_details(result_entry_id);

CREATE INDEX idx_red_parameter
ON result_entry_details(parameter_id);

CREATE INDEX idx_red_flag
ON result_entry_details(result_flag);

CREATE INDEX idx_red_active
ON result_entry_details(is_active);

-- ==== source: database/schema/020_test_parameter_mapping.sql ====

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
