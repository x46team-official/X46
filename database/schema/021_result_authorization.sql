-- Module 021 : Result Authorization
-- 021_result_authorization.sql

CREATE TABLE result_authorization
(
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  organization_id UUID NOT NULL REFERENCES  organizations(id) on DELETE CASCADE,

  branch_id UUID NOT NULL REFERENCES branches(id),

  result_entry_id UUID NOT NULL REFERENCES result_entry(id) on DELETE CASCADE,

  authorization_status VARCHAR(30) NOT NULL 
  default 'PENDING'
  CHECK
  (
    authorization_status IN (
      'PENDING',
      'AUTHORIZED',
      'REJECTED'
    )
  ),

  authorized_at  TIMESTAMPTZ,

  authorized_by UUID REFERENCES users(id),

  rejection_reason TEXT,

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

    CONSTRAINT uq_result_authorization
        UNIQUE (organization_id, branch_id, result_entry_id)
);

CREATE INDEX idx_ra_org
ON result_authorization(organization_id);

CREATE INDEX idx_ra_org_branch
ON result_authorization(organization_id, branch_id);

CREATE INDEX idx_ra_result
ON result_authorization(result_entry_id);

CREATE INDEX idx_ra_status
ON result_authorization(authorization_status);

CREATE INDEX idx_ra_active
ON result_authorization(is_active);
