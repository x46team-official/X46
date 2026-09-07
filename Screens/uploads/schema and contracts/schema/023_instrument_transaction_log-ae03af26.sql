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

