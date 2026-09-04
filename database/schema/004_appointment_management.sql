
-- F006 APPOINTMENT MANAGEMENT
-- Phase 1
-- Covers:
-- Appointment Type Master
-- Appointments



-- APPOINTMENT TYPE MASTER


CREATE TABLE appointment_type_master (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    branch_id UUID NOT NULL
        REFERENCES branches(id),

    appointment_type_code VARCHAR(30),

    appointment_type_name VARCHAR(100) NOT NULL,

    description TEXT,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID REFERENCES users(id),

    UNIQUE (organization_id, branch_id, appointment_type_name)
);




-- APPOINTMENTS


CREATE TABLE appointments (

    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    branch_id UUID NOT NULL
        REFERENCES branches(id),

    patient_id UUID NOT NULL
        REFERENCES patients(id),

    registration_id UUID
        REFERENCES patient_registrations(id),

    appointment_type_id UUID
        REFERENCES appointment_type_master(id),

    appointment_number VARCHAR(100) NOT NULL,

    appointment_date DATE NOT NULL,

    appointment_time TIME NOT NULL,

    appointment_status VARCHAR(50)
        NOT NULL DEFAULT 'BOOKED',

    remarks TEXT,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID NOT NULL
        REFERENCES users(id),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID
        REFERENCES users(id),

    UNIQUE (organization_id, branch_id, appointment_number)
);




-- INDEXES


CREATE INDEX idx_appointment_type_org
ON appointment_type_master(organization_id);

CREATE INDEX idx_appointment_type_org_branch
ON appointment_type_master(organization_id, branch_id);


CREATE INDEX idx_appointments_org
ON appointments(organization_id);

CREATE INDEX idx_appointments_org_branch
ON appointments(organization_id, branch_id);

CREATE INDEX idx_appointments_patient
ON appointments(patient_id);


CREATE INDEX idx_appointments_registration
ON appointments(registration_id);


CREATE INDEX idx_appointments_branch
ON appointments(branch_id);


CREATE INDEX idx_appointments_date
ON appointments(appointment_date);


CREATE INDEX idx_appointments_status
ON appointments(appointment_status);
