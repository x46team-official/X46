-- Test 1 — Successful organization creation
BEGIN ;

INSERT INTO organizations
(
   organization_name,
   organization_code
)
VALUES
(
    'X46 Diagnostics',
    'ORG001'
)
RETURNING
    id,
    organization_name,
    organization_code;

ROLLBACK;


-- Test 2 — Required organization name

BEGIN ; 


INSERT INTO organizations
(
   organization_name,
   organization_code
)
VALUES
(
    NULL,
    'ORG002'
);

ROLLBACK;


--Test 3 — Required organization code
BEGIN;

INSERT INTO organizations
(
    organization_name,
    organization_code
)
VALUES
(
    'Test Diagnostics',
    NULL
);


ROLLBACK;


-- Test 4 — Duplicate organization code
BEGIN;

INSERT INTO organizations
(
    organization_name,
    organization_code
)
VALUES
(
    'X46 Diagnostics',
    'ORG001'
);

INSERT INTO organizations
(
    organization_name,
    organization_code
)
VALUES
(
    'ABC Diagnostics',
    'ORG001'
);

ROLLBACK;

