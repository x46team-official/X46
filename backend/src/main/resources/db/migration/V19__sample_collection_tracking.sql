
-- ==== source: database/schema/019_sample_collection.sql ====

-- Module : Sample Collection
-- 019_sample_collection.sql

CREATE TABLE sample_collection(

  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  organization_id UUID NOT NULL REFERENCES organizations(id),

  branch_id UUID NOT NULL REFERENCES branches(id),

  accession_test_id UUID NOT NULL REFERENCES accession_tests(id) on DELETE CASCADE,

  collector_id UUID REFERENCES users(id),

  collection_datetime TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

  collection_location VARCHAR(150),

  sample_condition VARCHAR(30) NOT NULL
    DEFAULT 'GOOD'
    check(
      sample_condition IN(
         'GOOD',
                'HEMOLYZED',
                'CLOTTED',
                'LEAKING',
                'INSUFFICIENT',
                'DAMAGED'
      )
    ),

    quantity NUMERIC(10,2),

    quantity_unit VARCHAR(20),

  temperature NUMERIC(5,2),

    collection_status VARCHAR(30) NOT NULL
        DEFAULT 'COLLECTED'
        CHECK (
            collection_status IN (
                'COLLECTED',
                'RECOLLECTION_REQUIRED',
                'REJECTED'
            )
        ),

    rejection_reason VARCHAR(255),

    remarks TEXT,

    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    created_by UUID
        REFERENCES users(id),

    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    updated_by UUID
        REFERENCES users(id),

    is_active BOOLEAN DEFAULT TRUE,

    CONSTRAINT uq_sample_collection
        UNIQUE (accession_test_id)
);

CREATE INDEX idx_sample_collection_accession_test
ON sample_collection(accession_test_id);

CREATE INDEX idx_sample_collection_collector
ON sample_collection(collector_id);

CREATE INDEX idx_sample_collection_status
ON sample_collection(collection_status);

CREATE INDEX idx_sample_collection_condition
ON sample_collection(sample_condition);

CREATE INDEX idx_sample_collection_datetime
ON sample_collection(collection_datetime);

CREATE INDEX idx_sample_collection_org_status
ON sample_collection(organization_id, collection_status);

CREATE INDEX idx_sample_collection_org_branch
ON sample_collection(organization_id, branch_id);

-- ==== source: database/schema/019_sample_tracking.sql ====

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
