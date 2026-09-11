-- Chunk 1.1 bootstrap seed (plan.md gap #6): API-001 (Create Organization) and
-- API-002 (Create Branch) have scope.organization_required=false, so no
-- role_permission row can exist to gate them before any organization exists.
-- Seeds one reserved platform tenant + one PLATFORM_ADMIN user, so those two
-- endpoints can be gated on @PreAuthorize("hasRole('PLATFORM_ADMIN')")
-- (a JWT role claim) instead of the normal @perm.can(...) check.
--
-- Bootstrap login: organizationCode=PLATFORM, branchCode=PLATFORM-01,
-- username=platform_admin, password=Platform@123 (dev-only, rotate before prod).
WITH org AS (
    INSERT INTO organizations (organization_code, organization_name, is_active)
    VALUES ('PLATFORM', 'Platform', TRUE)
    RETURNING id
),
branch AS (
    INSERT INTO branches (organization_id, branch_code, branch_name, is_active)
    SELECT id, 'PLATFORM-01', 'Platform Bootstrap Branch', TRUE FROM org
    RETURNING id, organization_id
),
role AS (
    INSERT INTO roles (organization_id, branch_id, role_code, role_name)
    SELECT organization_id, id, 'PLATFORM_ADMIN', 'Platform Administrator' FROM branch
    RETURNING id, organization_id, branch_id
),
bootstrap_user AS (
    INSERT INTO users (organization_id, branch_id, username, password_hash, first_name, is_active)
    SELECT organization_id, branch_id, 'platform_admin',
           '$2a$10$NJXphUlGc/wCmjvjUYYQ/OCQSBB/1xWPTM9e/Hl.y6JGe85rG4ykC',
           'Platform', TRUE
    FROM role
    RETURNING id, organization_id, branch_id
)
INSERT INTO user_roles (organization_id, branch_id, user_id, role_id)
SELECT bootstrap_user.organization_id, bootstrap_user.branch_id, bootstrap_user.id, role.id
FROM bootstrap_user, role;
