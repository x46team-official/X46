-- Module 022 : Report Management
-- File : 022_report_master.sql

-- Module 022 : Report Management
-- 022_report_master.sql

CREATE TABLE report_master
(
  id UUID PRIMARY KEY  DEFAULT gen_random_uuid(),

  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,

  branch_id UUID NOT NULL REFERENCES branches(id),

  accession_id UUID NOT NULL REFERENCES  accession_master(id) on DELETE CASCADE,

  report_number VARCHAR(50) NOT NULL,

  version_no INTEGER NOT NULL DEFAULT 1,

  report_status VARCHAR(20) NOT NULL 
    DEFAULT 'DRAFT'
    CHECK (
      report_status IN
      (
        'DRAFT' ,
        'GENERATED',
        'AUTHORIZED',
        'RELEASED',
        'CANCELLED'

      )
    ),

    generated_at TIMESTAMPTZ,

    generated_by UUID REFERENCES users(id),

    authorized_at TIMESTAMPTZ,

    authorized_by UUID REFERENCES users(id),

    printed_at TIMESTAMPTZ, 

    printed_by UUID REFERENCES users(id),
   
    released_at TIMESTAMPTZ,

    released_by UUID REFERENCES users(id),

    pdf_path TEXT,

    qr_code TEXT,

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

    CONSTRAINT uq_report_number
        UNIQUE (organization_id, branch_id, report_number),

    CONSTRAINT uq_report_accession
        UNIQUE (organization_id, branch_id, accession_id)
);


CREATE INDEX idx_report_org
ON report_master(organization_id);

CREATE INDEX idx_report_org_branch
ON report_master(organization_id, branch_id);

CREATE INDEX idx_report_accession
ON report_master(accession_id);

CREATE INDEX idx_report_status
ON report_master(report_status);

CREATE INDEX idx_report_generated
ON report_master(generated_at);

CREATE INDEX idx_report_active
ON report_master(is_active);
