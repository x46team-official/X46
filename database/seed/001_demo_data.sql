
-- DEMO FOUNDATION DATA


-- Organization
INSERT INTO organizations (
    organization_code,
    organization_name
)
VALUES (
    'DEMO-LAB',
    'Demo Diagnostic Laboratory'
);


-- Branch
INSERT INTO branches (
    organization_id,
    branch_code,
    branch_name
)
SELECT
    id,
    'PUNE-01',
    'Pune Main Branch'
FROM organizations
WHERE organization_code = 'DEMO-LAB';


-- Receptionist Role
INSERT INTO roles (
    organization_id,
    branch_id,
    role_code,
    role_name
)
SELECT
    o.id,
    b.id,
    'RECEPTIONIST',
    'Receptionist'
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
WHERE o.organization_code = 'DEMO-LAB 2'
  AND b.branch_code = 'PUNE-01';


-- Receptionist User
INSERT INTO users (
    organization_id,
    branch_id,
    username,
    email,
    password_hash,
    first_name,
    last_name
)
SELECT
    o.id,
    b.id,
    'receptionist01',
    'receptionist@demo.local',
    'DEMO_HASH_NOT_REAL_PASSWORD',
    'Demo',
    'Receptionist'
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
WHERE o.organization_code = 'DEMO-LAB'
  AND b.branch_code = 'PUNE-01';


-- Assign RECEPTIONIST role
INSERT INTO user_roles (
    organization_id,
    branch_id,
    user_id,
    role_id
)
SELECT
    o.id,
    u.branch_id,
    u.id,
    r.id
FROM users u
JOIN organizations o
    ON o.id = u.organization_id
JOIN roles r
    ON r.organization_id = o.id
   AND r.branch_id = u.branch_id
WHERE o.organization_code = 'DEMO-LAB'
  AND u.username = 'receptionist01'
  AND r.role_code = 'RECEPTIONIST';
