-- Module : Sample Tracking
-- 019_sample_tracking.sql

CREATE TABLE sample_tracking(
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL REFERENCES organizations(id),
  branch_id UUID NOT NULL REFERENCES branches(id),
  sample_collection_id UUID NOT NULL REFERENCES sample_collection(id) on DELETE CASCADE,

  tracking_status VARCHAR(40) NOT NULL
  CHECK(
    tracking_status IN(
      'COLLECTED',
                'RECEIVED',
                'PROCESSING',
                'AUTHORIZED',
                'COMPLETED',
                'DISPATCHED',
                'REJECTED'
    )
  ),

  location VARCHAR(150),

  remarks TEXT,

  tracked_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

  tracked_by UUID REFERENCES users(id),

  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

  created_by UUID REFERENCES users(id),

  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    updated_by UUID
        REFERENCES users(id),

    is_active BOOLEAN DEFAULT TRUE
);

CREATE INDEX idx_sample_tracking_collection
ON sample_tracking(sample_collection_id);

CREATE INDEX idx_sample_tracking_status
ON sample_tracking(tracking_status);

CREATE INDEX idx_sample_tracking_datetime
ON sample_tracking(tracked_at);

CREATE INDEX idx_sample_tracking_org_collection
ON sample_tracking(organization_id, sample_collection_id);

CREATE INDEX idx_sample_tracking_org_status
ON sample_tracking(organization_id, tracking_status);

CREATE INDEX idx_sample_tracking_org_branch
ON sample_tracking(organization_id, branch_id);
