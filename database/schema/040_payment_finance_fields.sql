-- Module : Payment Management
-- 040_payment_finance_fields.sql
--
-- Adds bank/cheque detail to payment, needed for cheque and bank-transfer
-- collection reports. Identified as a schema gap in the Finance module
-- audit - neither column existed anywhere in the schema.

ALTER TABLE payment
ADD COLUMN bank_name VARCHAR(150),
ADD COLUMN cheque_number VARCHAR(50);

CREATE INDEX idx_payment_cheque_number
ON payment(organization_id, branch_id, cheque_number)
WHERE cheque_number IS NOT NULL;
