-- Module 033 : Payment Mode Master
-- 033_payment_mode_master.sql


BEGIN;

CREATE TABLE payment_mode_master(

  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  organization_id UUID NOT NULL
      REFERENCES organizations(id),

  branch_id UUID NOT NULL
      REFERENCES branches(id),

  payment_mode_code VARCHAR(30) NOT NULL,

  payment_mode_name VARCHAR(100) NOT NULL,

  sort_order INTEGER NOT NULL
      DEFAULT 1,

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

  CONSTRAINT uq_payment_mode_master_code
      UNIQUE (organization_id, branch_id, payment_mode_code)
);

CREATE INDEX idx_payment_mode_master_org
ON payment_mode_master(organization_id);

CREATE INDEX idx_payment_mode_master_org_branch
ON payment_mode_master(organization_id, branch_id);

CREATE INDEX idx_payment_mode_master_code
ON payment_mode_master(payment_mode_code);

CREATE INDEX idx_payment_mode_master_active
ON payment_mode_master(is_active);


INSERT INTO payment_mode_master
(
    organization_id,
    branch_id,
    payment_mode_code,
    payment_mode_name,
    sort_order
)
SELECT
    o.id,
    b.id,
    v.payment_mode_code,
    v.payment_mode_name,
    v.sort_order
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
CROSS JOIN
(
    VALUES
        ('CASH',              'Cash',              1),
        ('CARD',              'Card',              2),
        ('UPI',               'UPI',               3),
        ('NET_BANKING',       'Net Banking',       4),
        ('CHEQUE',            'Cheque',            5),
        ('WALLET',            'Wallet',            6),
        ('CORPORATE_CREDIT',  'Corporate Credit',  7)
) AS v(payment_mode_code, payment_mode_name, sort_order)
ON CONFLICT (organization_id, branch_id, payment_mode_code)
DO NOTHING;

DO
$$
BEGIN
    IF EXISTS
    (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'payment_payment_mode_check'
          AND conrelid = 'payment'::regclass
    ) THEN
        ALTER TABLE payment
            DROP CONSTRAINT payment_payment_mode_check;
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
        WHERE conname = 'fk_payment_payment_mode'
          AND conrelid = 'payment'::regclass
    ) THEN
        ALTER TABLE payment
            ADD CONSTRAINT fk_payment_payment_mode
            FOREIGN KEY (organization_id, branch_id, payment_mode)
            REFERENCES payment_mode_master (organization_id, branch_id, payment_mode_code);
    END IF;
END
$$;

CREATE INDEX IF NOT EXISTS idx_payment_org_branch_payment_mode
ON payment(organization_id, branch_id, payment_mode);

COMMIT;
