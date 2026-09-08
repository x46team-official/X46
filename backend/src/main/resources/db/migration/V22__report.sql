
-- ==== source: database/schema/022_report_master.sql ====

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

-- ==== source: database/schema/022_report_delivery_log.sql ====

-- Module 022 : Report Delivery Log
-- File : 022_report_delivery_log.sql

CREATE TABLE report_delivery_log
(
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  organization_id UUID  NOT NULL REFERENCES organizations(id) on DELETE CASCADE,

  branch_id UUID NOT NULL REFERENCES branches(id),

  report_id UUID NOT NULL REFERENCES report_master(id) on DELETE CASCADE,

  delivery_type VARCHAR(20) NOT NULL 
  CHECK 
  (
    delivery_type IN (
      'PRINT',
      'EMAIL',
      'SMS',
      'WHATSAPP',
      'PORTAL'

    )
  ),

  recipient_type VARCHAR(30) NOT NULL
    CHECK 
    (
      recipient_type IN 
      (
        'PATIENT',
        'DOCTOR',
        'REFERRAL',
        'COLLECTION_CENTER',
        'LAB'
      )
    ),

    recipient_name VARCHAR(255),

    recipient_contact VARCHAR(255),

    delivery_status VARCHAR(20) NOT NULL
     DEFAULT 'PENDING'
     CHECK (
      delivery_status IN
      (
        'PENDING',
        'SENT',
        'FAILED',
        'DELIVERED'
      )
     ),

  delivered_at TIMESTAMPTZ,

delivered_by UUID
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
        DEFAULT TRUE
);

CREATE INDEX idx_rdl_org
ON report_delivery_log(organization_id);

CREATE INDEX idx_rdl_org_branch
ON report_delivery_log(organization_id, branch_id);

CREATE INDEX idx_rdl_report
ON report_delivery_log(report_id);

CREATE INDEX idx_rdl_delivery_type
ON report_delivery_log(delivery_type);

CREATE INDEX idx_rdl_recipient_type
ON report_delivery_log(recipient_type);

CREATE INDEX idx_rdl_status
ON report_delivery_log(delivery_status);

CREATE INDEX idx_rdl_active
ON report_delivery_log(is_active);
