-- Module : 029 Dashboard
-- 029_dashboard_cache.sql

CREATE table dashboard_cache
(
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  organization_id UUID NOT NULL REFERENCES organizations(id),

  branch_id UUID NOT NULL REFERENCES branches(id),

  dashboard_key VARCHAR(100) NOT NULL,

  dashboard_value JSONB NOT NULL,

  generated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

  is_active BOOLEAN NOT NULL DEFAULT TRUE,

  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

  created_by UUID REFERENCES users(id),
  
   updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID REFERENCES users(id),

    deleted_at TIMESTAMPTZ,
    deleted_by UUID REFERENCES users(id),

    CONSTRAINT uq_dashboard_cache
        UNIQUE (organization_id, branch_id, dashboard_key)
);

CREATE INDEX idx_dashboard_cache_org
ON dashboard_cache (organization_id);

CREATE INDEX idx_dashboard_cache_branch
ON dashboard_cache (branch_id);

CREATE INDEX idx_dashboard_cache_org_branch
ON dashboard_cache (organization_id, branch_id);

CREATE INDEX idx_dashboard_cache_key
ON dashboard_cache (dashboard_key);

CREATE INDEX idx_dashboard_cache_generated
ON dashboard_cache (generated_at);

CREATE INDEX idx_dashboard_cache_active
ON dashboard_cache (is_active);
