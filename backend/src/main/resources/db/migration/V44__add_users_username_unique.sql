-- Not one of the 139 fixed contracts (plan.md gap #8, explicit user request):
-- usernames become globally unique instead of unique-per-org+branch, so login
-- can resolve a user from username alone (no org/branch code needed). New
-- usernames are auto-prefixed with their org's code by UserService.create
-- (e.g. "ACME-jdoe") to make collisions across orgs practically impossible;
-- this constraint is what makes that guarantee real instead of a convention.
-- No backfill needed: at migration time the only row is the V42 seed's
-- 'platform_admin', already unique and left as-is (it's a widely-referenced
-- dev credential, not worth renaming for a constraint that doesn't need it).
ALTER TABLE users ADD CONSTRAINT uq_users_username UNIQUE (username);
