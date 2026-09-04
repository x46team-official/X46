-- Module : Outsource Center Management
-- 009_outsource_center_management

CREATE Table outsource_center_master(
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  organization_id UUID NOT NULL
    REFERENCES organizations(id),

  branch_id UUID NOT NULL
    REFERENCES branches(id),
  
  center_code VARCHAR(30) NOT NULL,
  center_name VARCHAR(100) NOT NULL,

  contact_person VARCHAR(150),

  phone_number VARCHAR(20),
  email VARCHAR(100),

  address TEXT,
  city VARCHAR(100),
  state VARCHAR(100),
  country VARCHAR(100),
  pincode VARCHAR(20),


  gst_number VARCHAR(30),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,

  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by UUID REFERENCES users(id),

  update_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by UUID REFERENCES users(id),

  unique (organization_id, branch_id, center_code),
  unique (organization_id, branch_id, center_name)
);

CREATE INDEX idx_outsource_org
ON outsource_center_master(organization_id);

CREATE INDEX idx_outsource_org_branch
ON outsource_center_master(organization_id, branch_id);

CREATE INDEX idx_outsource_name
ON outsource_center_master(center_name);

CREATE INDEX idx_outsource_active
ON outsource_center_master(is_active);
