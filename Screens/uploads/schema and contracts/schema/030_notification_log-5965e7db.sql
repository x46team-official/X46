-- MODULE 30 : NOTIFICATION TEmplate

CREATE TABLE notification_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    branch_id UUID NOT NULL
        REFERENCES branches(id),

    template_id UUID
        REFERENCES notification_template(id),

    patient_registration_id UUID
        REFERENCES patient_registrations(id),

    notification_type VARCHAR(20) NOT NULL
        CHECK (
            notification_type IN (
                'EMAIL',
                'SMS',
                'WHATSAPP'
            )
        ),

    recipient VARCHAR(255) NOT NULL,

    subject VARCHAR(255),

    message_body TEXT NOT NULL,

    status VARCHAR(20) NOT NULL DEFAULT 'PENDING'
        CHECK (
            status IN (
                'PENDING',
                'SENT',
                'FAILED'
            )
        ),

    sent_at TIMESTAMPTZ,

    error_message TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID REFERENCES users(id),

    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES users(id)
);

CREATE INDEX idx_notification_log_org
ON notification_log(organization_id);

CREATE INDEX idx_notification_log_org_branch
ON notification_log(organization_id, branch_id);

CREATE INDEX idx_notification_log_patient
ON notification_log(patient_registration_id);

CREATE INDEX idx_notification_log_template
ON notification_log(template_id);

CREATE INDEX idx_notification_log_status
ON notification_log(status);

CREATE INDEX idx_notification_log_sent
ON notification_log(sent_at);
