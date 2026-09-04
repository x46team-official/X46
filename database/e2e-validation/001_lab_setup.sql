BEGIN;



-- creating organization
INSERT INTO organizations 
(
  organization_code,
  organization_name,
  is_active
)
Values(
  'LAB002',
  'X46 Diagnostics',
  TRUE
)
returning id as organization_id
\gset
-- creating branch 
INSERT INTO branches(
  organization_id,
  branch_name,
  branch_code,
  is_active
)
Values
(
  :'organization_id',
  'Yerawada Branch',
    'PUNE002',
  TRUE
)
RETURNING id as branch_id
\gset

-- creating roles organization will have 
INSERT INTO roles
(
  organization_id,
  branch_id,
  role_code,
  role_name
)
values
( :'organization_id',
  :'branch_id','ADMIN', 'Administrator'),
( :'organization_id',
  :'branch_id','RECEPTION', 'Receptionist'),
( :'organization_id',
  :'branch_id','TECHNICIAN', 'Lab Technician'),
( :'organization_id',
  :'branch_id','PATHOLOGIST', 'Pathologist');

--  organization users

INSERT into users
(
  organization_id,
  branch_id,
  username,
  email,
  password_hash,
  first_name,
  last_name,
  is_active
)
values
(
  :'organization_id',
  :'branch_id',
  'admin',
  'admin@123.com',
  'admin123',
  'Manas',
  'Administrator',
  TRUE
)
returning id as admin_user_id
\gset


INSERT into user_roles
(
  organization_id,
  branch_id,
  user_id,
  role_id

)

SELECT 

  :'organization_id',
  :'branch_id',
  :'admin_user_id',
  id
from roles
where organization_id = :'organization_id'
  and branch_id = :'branch_id'
  and role_code='ADMIN';

COMMIT;


--VERIFICATION

SELECT * FROM organizations;

SELECT * FROM branches;

SELECT * FROM roles;

SELECT * FROM users;

SELECT * FROM user_roles;
