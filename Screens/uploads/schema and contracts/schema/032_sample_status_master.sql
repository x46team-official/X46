-- Module 032 : Sample Status Master
-- 032_sample_status_master.sql


BEGIN;

CREATE TABLE sample_status_master(

  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  organization_id UUID NOT NULL
      REFERENCES organizations(id),

  branch_id UUID NOT NULL
      REFERENCES branches(id),

  sample_status_code VARCHAR(30) NOT NULL,

  sample_status_name VARCHAR(100) NOT NULL,

  sort_order INTEGER NOT NULL
      DEFAULT 1,

  is_terminal BOOLEAN NOT NULL
      DEFAULT FALSE,

  is_active BOOLEAN NOT NULL
      DEFAULT TRUE,

  created_at TIMESTAMPTZ NOT NULL
      DEFAULT CURRENT_TIMESTAMP,

  created_by UUID
      REFERENCES users(id),

  updated_at TIMESTAMPTZ NOT NULL
      DEFAULT CURRENT_TIMESTAMP,

  updated_by UUID
      REFERENCES users(id),

  CONSTRAINT uq_sample_status_master_code
      UNIQUE (organization_id, branch_id, sample_status_code)
);

CREATE INDEX idx_sample_status_master_org
ON sample_status_master(organization_id);

CREATE INDEX idx_sample_status_master_org_branch
ON sample_status_master(organization_id, branch_id);

CREATE INDEX idx_sample_status_master_code
ON sample_status_master(sample_status_code);

CREATE INDEX idx_sample_status_master_active
ON sample_status_master(is_active);


INSERT INTO sample_status_master
(
    organization_id,
    branch_id,
    sample_status_code,
    sample_status_name,
    sort_order,
    is_terminal
)
SELECT
    o.id,
    b.id,
    v.sample_status_code,
    v.sample_status_name,
    v.sort_order,
    v.is_terminal
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
CROSS JOIN
(
    VALUES
        ('PENDING',                 'Pending',                 1, FALSE),
        ('COLLECTED',               'Collected',               2, FALSE),
        ('RECEIVED',                'Received',                3, FALSE),
        ('PROCESSING',              'Processing',              4, FALSE),
        ('COMPLETED',               'Completed',               5, TRUE),
        ('REJECTED',                'Rejected',                6, TRUE),
        ('IN_TRANSIT',              'In Transit',              7, FALSE),
        ('RECOLLECTION_REQUESTED',  'Recollection Requested',  8, FALSE)
) AS v(sample_status_code, sample_status_name, sort_order, is_terminal)
ON CONFLICT (organization_id, branch_id, sample_status_code)
DO NOTHING;


DO
$$
BEGIN
    IF EXISTS
    (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'accession_tests_sample_status_check'
          AND conrelid = 'accession_tests'::regclass
    ) THEN
        ALTER TABLE accession_tests
            DROP CONSTRAINT accession_tests_sample_status_check;
    END IF;
END
$$;


DO
$$
BEGIN
    IF NOT EXISTS
    (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_accession_tests_sample_status'
          AND conrelid = 'accession_tests'::regclass
    ) THEN
        ALTER TABLE accession_tests
            ADD CONSTRAINT fk_accession_tests_sample_status
            FOREIGN KEY (organization_id, branch_id, sample_status)
            REFERENCES sample_status_master (organization_id, branch_id, sample_status_code);
    END IF;
END
$$;

CREATE INDEX IF NOT EXISTS idx_accession_tests_org_branch_sample_status
ON accession_tests(organization_id, branch_id, sample_status);

COMMIT;
