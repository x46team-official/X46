
-- API-T005 : Valid Branch Creation
-- Expected API: 201 Created


BEGIN;

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
WHERE organization_code = 'LAB002'
RETURNING
    id,
    organization_id,
    branch_code,
    branch_name;

ROLLBACK;



-- API-T006 : Missing Branch Code
-- Expected API: 400 Bad Request


BEGIN;

INSERT INTO branches (
    organization_id,
    branch_code,
    branch_name
)
SELECT
    id,
    NULL,
    'Pune Main Branch'
FROM organizations
WHERE organization_code = 'LAB002';

ROLLBACK;



-- API-T007 : Missing Branch Name
-- Expected API: 400 Bad Request


BEGIN;

INSERT INTO branches (
    organization_id,
    branch_code,
    branch_name
)
SELECT
    id,
    'PUNE-02',
    NULL
FROM organizations
WHERE organization_code = 'LAB002';

ROLLBACK;



-- API-T008 : Duplicate Branch Code
-- Expected API: 409 Conflict


BEGIN;

-- First branch
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
WHERE organization_code = 'LAB002';


-- Duplicate branch code
INSERT INTO branches (
    organization_id,
    branch_code,
    branch_name
)
SELECT
    id,
    'PUNE-01',
    'Another Pune Branch'
FROM organizations
WHERE organization_code = 'LAB002';

ROLLBACK;



-- API-T009 : Invalid Organization
-- Expected API: 404 Not Found


BEGIN;

INSERT INTO branches (
    organization_id,
    branch_code,
    branch_name
)
SELECT
    id,
    'PUNE-99',
    'Invalid Organization Branch'
FROM organizations
WHERE organization_code = 'INVALID-ORG';

ROLLBACK;