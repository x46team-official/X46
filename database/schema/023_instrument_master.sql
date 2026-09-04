-- Module 023: Instrument Master
-- Description : Stores laboratory analyzer master details

CREATE TABLE instrument_master(

  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  organization_id UUID NOT NULL REFERENCES organizations(id),

  branch_id UUID NOT NULL REFERENCES branches(id),

  department_id UUID NOT NULL REFERENCES department_master(id),

  instrument_code VARCHAR(30) NOT NULL,
  instrument_name VARCHAR(100) NOT NULL,

  manufacture VARCHAR(100),
  model VARCHAR(100),
  serial_number VARCHAR(100),

  analyzer_type VARCHAR(50)
  CHECK 
  (
     analyzer_type IN 
     (
      'HEMATOLOGY',
                'BIOCHEMISTRY',
                'IMMUNOASSAY',
                'MICROBIOLOGY',
                'URINE_ANALYZER',
                'COAGULATION',
                'BLOOD_GAS',
                'OTHER'
     )
  ),

  status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
  CHECK 
  (
    status IN 
    (
      'ACTIVE',
      'INACTIVE',
      'MAINTENANCE'
    )
  ),

  remarks TEXT,

  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

  created_by UUID REFERENCES users(id),

  update_at TIMESTAMPTZ,
  updated_by UUID REFERENCES users(id),

  CONSTRAINT uq_instrument_code
    UNIQUE( organization_id, branch_id, instrument_code)
);

CREATE INDEX idx_instrument_master_org
ON instrument_master(organization_id);

CREATE INDEX idx_instrument_master_org_branch
ON instrument_master(organization_id, branch_id);

CREATE INDEX idx_instrument_master_department
ON instrument_master(department_id);

CREATE INDEX idx_instrument_master_status
ON instrument_master(status);

CREATE INDEX idx_instrument_master_name
ON instrument_master(instrument_name);
