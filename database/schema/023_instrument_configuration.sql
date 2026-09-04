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
