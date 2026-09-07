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
