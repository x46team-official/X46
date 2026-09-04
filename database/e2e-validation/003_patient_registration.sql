BEGIN;

-- GET ORGANIZATION
SELECT id as organization_id
from organizations
where organization_code ='LAB002'
\gset

-- GET BRANCH
SELECT id as branch_id

from branches
where organization_id = :'organization_id'
AND branch_code ='PUNE002'
\gset

-- GET ADMIN USER
SELECT id as admin_user_id
from users
where organization_id=:'organization_id'
AND username='admin'
\gset

\echo Admin User ID = :admin_user_id

--patient

INSERT into patients
(
  organization_id,
  branch_id,
  patient_type,
  first_name,
  last_name,
  gender,
  date_of_birth,
  patient_category,
  is_active,
  created_by
)
values
(
  :'organization_id',
  :'branch_id',
  'OUTPATIENT',
  'Manas',
  'Gaikwad',
  'Male',
  DATE '2005-01-01',
  'GENERAL',
  TRUE,
  :'admin_user_id'
)
returning id as patient_id
\gset
--patient identifier
INSERT INTO patient_identifiers
(
    organization_id,
    branch_id,
    patient_id,
    identifier_type,
    identifier_value,
    is_primary
)
VALUES
(
    :'organization_id',
    :'branch_id',
    :'patient_id',
    'MRN',
    'MRN000001',
    TRUE
);

--patient contact
insert into patient_contacts
(
  organization_id,
  branch_id,
  patient_id,
  contact_type,
  contact_value,
  whatsapp_consent,
  is_primary,
  created_by
)
values
(
  :'organization_id',
  :'branch_id',
  :'patient_id',
  'MOBILE',
  '7498529559',
  TRUE,
  TRUE,
  :'admin_user_id'
);

--patient address

INSERT INTO patient_addresses
(
  organization_id,
  branch_id,
  patient_id,
  address_type,
  address_line1,
  city,
  district,
  state,
  country,
  pincode,
  is_primary,
  created_by
)
values(
  :'organization_id',
  :'branch_id',
  :'patient_id',
  'HOME',
  'Yerwaada',
  'Pune',
  'PUNE',
  'Maharashtra',
  'INDIA',
  '411041',
  TRUE,
  :'admin_user_id'
  );



-- patient registration 
INSERT INTO patient_registrations
(
  organization_id,
  branch_id,
  patient_id,
  registration_number,
  registration_status,
  created_by
)
values
(
  :'organization_id',
  :'branch_id',
  :'patient_id',
  'REG001',
  'REGISTERED',
  :'admin_user_id'

)
returning id as registration_id
\gset

COMMIT;
--verification

SELECT * FROM patients WHERE id = :'patient_id';

SELECT * FROM patient_contacts
WHERE patient_id = :'patient_id';

SELECT * FROM patient_addresses
WHERE patient_id = :'patient_id';

SELECT * FROM patient_identifiers
WHERE patient_id = :'patient_id';

SELECT * FROM patient_registrations
WHERE id = :'registration_id';
