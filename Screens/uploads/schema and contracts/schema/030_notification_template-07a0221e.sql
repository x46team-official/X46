-- MODULE 30 : NOTIFICATION TEmplate

CREATE TABLE notification_template (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    organization_id UUID NOT NULL
        REFERENCES organizations(id),

    branch_id UUID NOT NULL
        REFERENCES branches(id),

    template_name VARCHAR(100) NOT NULL,

    notification_type VARCHAR(20) NOT NULL
        CHECK (
            notification_type IN (
                'EMAIL',
                'SMS',
                'WHATSAPP'
            )
        ),

    subject VARCHAR(255),

    message_body TEXT NOT NULL,

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID REFERENCES users(id),

    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES users(id),

    CONSTRAINT uq_notification_template
    UNIQUE (
        organization_id,
        branch_id,
        template_name,
        notification_type
    )
);

CREATE INDEX idx_notification_template_org
ON notification_template(organization_id);

CREATE INDEX idx_notification_template_org_branch
ON notification_template(organization_id, branch_id);

CREATE INDEX idx_notification_template_type
ON notification_template(notification_type);

CREATE INDEX idx_notification_template_active
ON notification_template(is_active);
