-- Module : Billing Management
-- 039_billing_finance_fields.sql
--
-- Adds TDS deduction and write-off tracking to billing_master. Both were
-- identified as schema gaps in the Finance module audit - no column,
-- status, or table for either existed anywhere in the schema.

ALTER TABLE billing_master
ADD COLUMN tds_amount NUMERIC(10,2) NOT NULL DEFAULT 0,

ADD COLUMN write_off_amount NUMERIC(10,2) NOT NULL DEFAULT 0,
ADD COLUMN write_off_reason TEXT,

ADD COLUMN written_off_by UUID
    REFERENCES users(id),

ADD COLUMN written_off_at TIMESTAMPTZ;

ALTER TABLE billing_master
ADD CONSTRAINT chk_billing_master_tds_amount
    CHECK (tds_amount >= 0),

ADD CONSTRAINT chk_billing_master_write_off_amount
    CHECK (write_off_amount >= 0);

CREATE INDEX idx_billing_master_write_off
ON billing_master(organization_id, branch_id)
WHERE write_off_amount > 0;
