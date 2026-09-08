
-- ==== source: database/schema/023_instrument_master.sql ====

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

-- ==== source: database/schema/023_instrument_configuration.sql ====

-- Module 023: Instrument Configuration
-- Description : Stores communication settings for     laboratory analyzers

CREATE TABLE instrument_configuration
(
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  organization_id UUID NOT NULL
   REFERENCES organizations(id),

   branch_id UUID NOT NULL REFERENCES branches(id),

   instrument_id UUID NOT NULL REFERENCES instrument_master(id),

   communication_protocol VARCHAR(20)
   CHECK (
    communication_protocol IN
    (
      'HL7',
      'ASTM'

    )
   ),
   connection_type VARCHAR(20)
   CHECK (
    connection_type IN
    (
       'TCP/IP',
        'RS232',
        'USB'
    )
   ),

 interface_mode VARCHAR(20)
        CHECK (
            interface_mode IN (
                'UNIDIRECTIONAL',
                'BIDIRECTIONAL'
            )
        ),

    ip_address VARCHAR(50),

    port INTEGER,

    com_port VARCHAR(20),

    baud_rate INTEGER,

    parity VARCHAR(20)
        CHECK (
            parity IN (
                'NONE',
                'EVEN',
                'ODD'
            )
        ),

    data_bits INTEGER,

    stop_bits INTEGER,

    driver_name VARCHAR(100),

    workstation_name VARCHAR(100),

    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
        CHECK (
            status IN (
                'ACTIVE',
                'INACTIVE'
            )
        ),

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    created_by UUID
        REFERENCES users(id),

    updated_at TIMESTAMPTZ,

    updated_by UUID
        REFERENCES users(id),

    deleted_at TIMESTAMPTZ,

    deleted_by UUID
        REFERENCES users(id)
);

CREATE INDEX idx_instrument_configuration_org
ON instrument_configuration(organization_id);

CREATE INDEX idx_instrument_configuration_org_branch
ON instrument_configuration(organization_id, branch_id);

CREATE INDEX idx_instrument_configuration_instrument
ON instrument_configuration(instrument_id);

CREATE INDEX idx_instrument_configuration_status
ON instrument_configuration(status);

-- ==== source: database/schema/023_instrument_test_mapping.sql ====


-- Module 023 : Instrument Test Mapping
-- Description : Maps instrument test/parameter codes  to LIMS tests and parameters


CREATE TABLE instrument_test_mapping (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    branch_id UUID NOT NULL
        REFERENCES branches(id),

    instrument_id UUID NOT NULL
        REFERENCES instrument_master(id),

    test_id UUID NOT NULL
        REFERENCES test_master(id),

    parameter_id UUID NOT NULL
        REFERENCES parameter_master(id),

    machine_test_code VARCHAR(50) NOT NULL,

    machine_parameter_code VARCHAR(50) NOT NULL,

    display_order INTEGER NOT NULL DEFAULT 1,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    remarks TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    created_by UUID
        REFERENCES users(id),

    updated_at TIMESTAMPTZ,

    updated_by UUID
        REFERENCES users(id),

    deleted_at TIMESTAMPTZ,

    deleted_by UUID
        REFERENCES users(id),

    CONSTRAINT uq_instrument_mapping
        UNIQUE (
            organization_id,
            branch_id,
            instrument_id,
            machine_test_code,
            machine_parameter_code
        )
);


CREATE INDEX idx_itm_org
ON instrument_test_mapping(organization_id);

CREATE INDEX idx_itm_org_branch
ON instrument_test_mapping(organization_id, branch_id);

CREATE INDEX idx_itm_instrument
ON instrument_test_mapping(instrument_id);

CREATE INDEX idx_itm_test
ON instrument_test_mapping(test_id);

CREATE INDEX idx_itm_parameter
ON instrument_test_mapping(parameter_id);

CREATE INDEX idx_itm_active
ON instrument_test_mapping(is_active);

-- ==== source: database/schema/023_instrument_transaction_log.sql ====

-- Module 023: Instrument Transaction Log
-- Description : Stores analyzer communication logs

CREATE TABLE instrument_transaction_log
(
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    branch_id UUID NOT NULL
        REFERENCES branches(id),

    instrument_id UUID NOT NULL
        REFERENCES instrument_master(id),

    accession_test_id UUID
        REFERENCES accession_tests(id),

    sample_barcode VARCHAR(100),

    message_type VARCHAR(20)
        CHECK (
            message_type IN (
                'ORDER',
                'RESULT',
                'ACK',
                'ERROR'
            )
        ),

    protocol VARCHAR(20)
        CHECK (
            protocol IN (
                'HL7',
                'ASTM'
            )
        ),

    direction VARCHAR(20)
        CHECK (
            direction IN (
                'INBOUND',
                'OUTBOUND'
            )
        ),

    raw_message TEXT NOT NULL,

    parsed_data JSONB,

    processing_status VARCHAR(20) NOT NULL DEFAULT 'RECEIVED'
        CHECK (
            processing_status IN (
                'RECEIVED',
                'PROCESSED',
                'FAILED'
            )
        ),

    error_message TEXT,

    received_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    processed_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    created_by UUID
        REFERENCES users(id),

    updated_at TIMESTAMPTZ,

    updated_by UUID
        REFERENCES users(id),

    deleted_at TIMESTAMPTZ,

    deleted_by UUID
        REFERENCES users(id)
);


CREATE INDEX idx_instrument_transaction_org
ON instrument_transaction_log(organization_id);

CREATE INDEX idx_instrument_transaction_org_branch
ON instrument_transaction_log(organization_id, branch_id);

CREATE INDEX idx_instrument_transaction_instrument
ON instrument_transaction_log(instrument_id);

CREATE INDEX idx_instrument_transaction_barcode
ON instrument_transaction_log(sample_barcode);

CREATE INDEX idx_instrument_transaction_status
ON instrument_transaction_log(processing_status);

CREATE INDEX idx_instrument_transaction_received
ON instrument_transaction_log(received_at);

