-- Module : Agent Management
-- 038_agent_master.sql
--
-- The marketing/sales person credited with bringing in a registration -
-- referred to as "Marketing Person" in Finance reports.

CREATE TABLE agent_master
(
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    branch_id UUID NOT NULL
        REFERENCES branches(id),

    agent_code VARCHAR(30) NOT NULL,
    agent_name VARCHAR(150) NOT NULL,

    phone_number VARCHAR(20),
    email VARCHAR(100),

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID REFERENCES users(id),

    CONSTRAINT uq_agent_code
        UNIQUE (organization_id, branch_id, agent_code),

    CONSTRAINT uq_agent_name
        UNIQUE (organization_id, branch_id, agent_name)
);

CREATE INDEX idx_agent_org
ON agent_master(organization_id);

CREATE INDEX idx_agent_org_branch
ON agent_master(organization_id, branch_id);

CREATE INDEX idx_agent_code
ON agent_master(agent_code);

CREATE INDEX idx_agent_name
ON agent_master(agent_name);

CREATE INDEX idx_agent_active
ON agent_master(is_active);


-- patient_registrations.agent_id existed since
-- 006_patient_registration_enhancement.sql with no FK and no master table
-- behind it. Wire it up now.

ALTER TABLE patient_registrations
ADD CONSTRAINT fk_patient_registrations_agent
FOREIGN KEY (agent_id)
REFERENCES agent_master(id);

CREATE INDEX idx_patient_registrations_agent
ON patient_registrations(agent_id);
