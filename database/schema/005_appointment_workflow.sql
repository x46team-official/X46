-- F006 APPOINTMENT WORKFLOW
-- Phase 2
-- Covers:
-- Appointment Tests
-- Appointment Assignments
-- Appointment Status History

--APPOINTMENT TESTS

create table appointment_tests(
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id),
  branch_id uuid not null references branches(id),
  appointment_id uuid not null references appointments(id),

  test_code varchar(50),
  test_name varchar(200) not null,
  department varchar(100),

  priority varchar(50) not null default 'NORMAL',

  remarks text,

  created_at timestamptz not null default current_timestamp,
  created_by uuid references users(id),

  updated_at timestamptz not null default current_timestamp,
  updated_by uuid references users(id)
);

create table appointment_assignments(
  id UUID primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id),
  branch_id uuid not null references branches(id),
  appointment_id uuid not null references appointments(id),
  assigned_to uuid not null references users(id),
  assignment_role varchar(50),

  assigned_at TIMESTAMPTZ not null default current_timestamp,
  assigned_status varchar(50) default 'ASSIGNED',
  remarks text,

  created_at timestamptz not null default current_timestamp,
  created_by uuid references users(id),

  updated_at timestamptz not null default current_timestamp,
  updated_by uuid references users(id)

);

create table appointment_status_history(
  id UUID primary key default gen_random_uuid(),
  organization_id uuid not null references organizations(id),
  branch_id uuid not null references branches(id),
  appointment_id uuid not null references appointments(id),
  status varchar(50) not null,
  remarks text,

  created_at timestamptz not null default current_timestamp,
  created_by uuid references users(id)
);


create index idx_appointment_tests_appointment_id on appointment_tests(appointment_id);
create index idx_appointment_tests_org_branch on appointment_tests(organization_id, branch_id);

create index idx_appointment_assignments_appointment_id on appointment_assignments(appointment_id);
create index idx_appointment_assignments_org_branch on appointment_assignments(organization_id, branch_id);

create index idx_appointment_assignments_assigned_to on
appointment_assignments(assigned_to);

create index idx_appointment_status_history_appointment_id on appointment_status_history(appointment_id);
create index idx_appointment_status_history_org_branch on appointment_status_history(organization_id, branch_id);

create index idx_appointment_status_history_status on appointment_status_history(status);

