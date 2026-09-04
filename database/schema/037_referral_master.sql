-- Module : Referral Management
-- 037_referral_master.sql
--
-- The referring doctor/hospital/clinic a patient was referred by - referred
-- to as "Referral" in Finance reports. Distinct from billing_master's own
-- referring_doctor_id, which points at an in-house `users` row.

CREATE TABLE referral_master
(
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    branch_id UUID NOT NULL
        REFERENCES branches(id),

    referral_code VARCHAR(30) NOT NULL,
    referral_name VARCHAR(150) NOT NULL,

    referral_type VARCHAR(30) NOT NULL DEFAULT 'DOCTOR'
        CHECK (
            referral_type IN (
                'DOCTOR',
                'HOSPITAL',
                'CLINIC',
                'OTHER'
            )
        ),

    contact_person VARCHAR(150),
    phone_number VARCHAR(20),
    email VARCHAR(100),

    address TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    pincode VARCHAR(20),

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID REFERENCES users(id),

    CONSTRAINT uq_referral_code
        UNIQUE (organization_id, branch_id, referral_code),

    CONSTRAINT uq_referral_name
        UNIQUE (organization_id, branch_id, referral_name)
);

CREATE INDEX idx_referral_org
ON referral_master(organization_id);

CREATE INDEX idx_referral_org_branch
ON referral_master(organization_id, branch_id);

CREATE INDEX idx_referral_code
ON referral_master(referral_code);

CREATE INDEX idx_referral_name
ON referral_master(referral_name);

CREATE INDEX idx_referral_type
ON referral_master(referral_type);

CREATE INDEX idx_referral_active
ON referral_master(is_active);


-- patient_registrations.referral_doctor_id existed since
-- 006_patient_registration_enhancement.sql with no FK and no master table
-- behind it. Wire it up now.

ALTER TABLE patient_registrations
ADD CONSTRAINT fk_patient_registrations_referral
FOREIGN KEY (referral_doctor_id)
REFERENCES referral_master(id);

CREATE INDEX idx_patient_registrations_referral
ON patient_registrations(referral_doctor_id);
