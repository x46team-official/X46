# X46 LIMS Backend — Implementation Plan

Source of truth for every contract detail (request/response schema, validation
rules, error catalog, DB tables) is `database/api_contracts_json/API-XXX_*.json`.
This plan does not repeat those fields — it tells each chunk which contract
file(s) to read and what to build from them. Schema source of truth is
`database/schema/001_*.sql` … `040_*.sql` (see Chunk 0.1).

Stack: Spring Boot 4.1.1, Java 21, Spring Data JPA, Spring Security, Flyway,
PostgreSQL 17 (`docker-compose.yml`, volume `x46-postgres-data`), Maven.
`spring.jpa.hibernate.ddl-auto=validate` — Flyway owns the schema, JPA never
creates or alters tables.

---

## 1. Architecture Overview

```
Controller  → Service → Repository (Spring Data JPA) → PostgreSQL
   ^                        |
   |  @PreAuthorize          v
   +---- SecurityFilter   role_permission (RBAC)
         (JWT bearer)
```

**Package layout** (`com.x46.backend.*`):

| Package | Contents |
|---|---|
| `common` | `ApiResponse<T>`, `GlobalExceptionHandler`, custom exceptions (`NotFoundException`, `ConflictException`, `ValidationException`), `ScopeGuard` (org/branch existence + tenant check helper) |
| `security` | JWT filter, `JwtService`, `AuthController` (`/api/auth/login`), `PermissionEvaluatorService` (bean name `perm`, backs `@PreAuthorize("@perm.can(...)")`) |
| `org` | Organization, Branch |
| `identity` | Role, User, UserRole |
| `master` | TestMaster, DepartmentMaster, ParameterMaster, ReferenceRangeMaster, TestPackageMaster, TestPackageTestMapping |
| `patient` | Patient, PatientRegistration |
| `clinical` | PatientClinicalHistory, ClinicalMaster (read-only lookup) |
| `billing` | BillingMaster, BillingTests |
| `payment` | Payment |
| `accession` | AccessionMaster, AccessionTests |
| `sample` | SampleCollection |
| `worklist` | WorklistMaster, WorksheetMaster |
| `result` | ResultEntry, ResultEntryDetails, ResultAuthorization |
| `report` | ReportMaster, ReportDeliveryLog |
| `outsource` | (reuses `accession.AccessionTests` + `master.PerformingLabMaster`, no new entity) |
| `finance` | read-only aggregate query services over billing/payment |

**Response envelope** — every contract response is `{success, message|error, data}`.
Built once in Chunk 0.2, used by all controllers; no module reinvents it.

**Multi-tenancy** — nearly every endpoint carries `organizationId`/`branchId`
path params. `ScopeGuard.requireOrgBranch(orgId, branchId)` (Chunk 0.5) loads
and validates both, then every repository query for that request is scoped by
them. A row that exists but belongs to a different org/branch reads as
`404 Not Found`, per contract convention (not `403`) — see
`Screens/API-SCENARIO-MAP.md` for the UI-observed convention this mirrors.

**AuthN** — stateless JWT. No login contract exists in the 139 API contracts
(confirmed: no module named Auth/Login, `Screens/lims-api.js` stubs a fake
session because "there is no backend attached to this prototype"). Chunk 0.3
adds `POST /api/auth/login` as net-new infrastructure, built only on existing
columns (`users.password_hash`, `users.is_active`) — no new tables.

**AuthZ** — `role_permission` (organization_id, branch_id, role_id,
module_name, can_create/view/update/delete/authorize/print/export) already
exists (`database/schema/027_role_permission.sql`). `module_name` values used
by this plan are exactly the contract `"module"` field strings (see Appendix
A) — no invented taxonomy, so a permission grant maps 1:1 back to a contract.

**Persistence** — PostgreSQL via the existing `docker-compose.yml`
(`x46-postgres-data` named volume, already durable across container
restarts). No changes needed there; every migration and integration test
targets that instance (`localhost:5434/x46`).

---

## 2. Known gaps carried into the plan (do not silently invent schema)

These are called out in the contracts/schema themselves. Each chunk below
that touches one references it instead of guessing:

1. **`roles.is_active` does not exist** (`API-129` schema_gap_note). Chunk
   1.3 adds one additive Flyway column migration
   (`ALTER TABLE roles ADD COLUMN is_active BOOLEAN NOT NULL DEFAULT TRUE`)
   before Activate/Deactivate Role can be built — this is the only schema
   change in the whole plan, and it is spelled out by the contract itself.
2. **Outsource Update Status is marked `NOT IMPLEMENTABLE`** in `API-136`
   (no `outsource_status` column or order table anywhere). Chunk 11.2 builds
   only Create + List/View (ops 1–2 of API-136); Update Status is left
   **blocked**, returning the exact `409` the contract documents, until a
   product decision adds the column/table. Do not add one speculatively.
3. **`patients.patient_code`** referenced by a test script but not by any
   schema file (`API-016.database_gap`). Chunk 3.1 does not implement
   duplicate-patient detection by code; only the constraints the live schema
   actually enforces (`uq_patient_contact`).
4. **API-065 requires `billNumber`**, not `billingId`, as its query param —
   build the contract as written; do not silently rename it to match the
   frontend prototype's mismatch (noted in `Screens/API-SCENARIO-MAP.md` item 8).
5. **No list-parameters / list-test-packages contract** exists — Chunk 2.4/2.5
   implement only what API-111/112/113/120/121/122 specify (create + lookup),
   not a speculative list endpoint.
6. **Bootstrap chicken-and-egg**: `API-001` (Create Organization) and
   `API-002` (Create Branch) have `scope.organization_required: false` — by
   definition no `role_permission` row can exist before an organization
   exists. Chunk 1.1 seeds one reserved platform organization/branch/role
   (`PLATFORM` / `PLATFORM-01` / `PLATFORM_ADMIN`) via Flyway seed data and
   gates these two endpoints on that role, instead of the normal
   `@perm.can(...)` check. This is an assumption the contracts don't state —
   flagged, not hidden.

---

## 3. Execution order

`M0 → M1 → M2 → M3 → M4 → M5 → M7 → M6 → M8 → M9 → M10 → M11 → M12`

(M6 Payment is built after M7 Accession because `API-057` create-payment
references `accessionId`; M6.2 Payment-Against-Bill only needs M5 Billing and
could move earlier if the team prefers — noted in M6.)

---

## 4. Module Breakdown

Each module lists its contracts, the `role_permission.module_name` value(s)
it checks, and its execution chunks. Every chunk follows this shape:

- **Scope** — one line.
- **Model/DTO/Repo** — entities/DTOs/repositories to add (fields = the
  contract's `request.body` / `success.response.data`, read from the JSON,
  not retyped here).
- **Service & RBAC** — business rules beyond straight CRUD + the
  `@PreAuthorize` check.
- **Controller** — `METHOD /path` list.
- **Unit tests** — one test per contract `errors[]` entry plus the success
  path (contract already enumerates them; this is the checklist, not new
  scenarios).
- **Postman** — where it lands: `backend/postman/<module-slug>.postman_collection.json`.

---

### M0 — Platform Foundation

No API-XXX contracts (infra only). Everything downstream depends on this module.

#### Chunk 0.1 — Flyway baseline + entity base classes
- **Scope:** Get a running, validated schema so `ddl-auto=validate` passes.
- **Work:** Copy `database/schema/001_core_setup.sql` through `040_payment_finance_fields.sql`
  (numeric order, per `database/schema/CHANGELOG.md` — this is the
  authoritative incremental history) into
  `backend/src/main/resources/db/migration/` as `V1__core_setup.sql` …
  `V40__payment_finance_fields.sql`, applying `alter-minor-changes.sql` as a
  final `V41__`. Do **not** pull from `database/schema/versions/` or
  `schema_snapshot_v*.sql` — those are point-in-time snapshots/history, not
  reapplication input. Add `AbstractTenantEntity` (`id`, `organizationId`,
  `branchId`, `createdAt`, `updatedAt`) as a `@MappedSuperclass` for reuse.
- **Unit tests:** `mvn test` boots the context against the dockerized
  Postgres and Flyway validates cleanly (`FlywayMigrationTest` — just asserts
  `flyway.info().current()` reaches the last version, no per-table assertions
  needed yet).
- **Postman:** none (no endpoint).

#### Chunk 0.2 — API response envelope + global exception handling
- **Scope:** One shape for every success/error body, matching every contract's
  `{success, message|error, data}`.
- **Model/DTO:** `ApiResponse<T>` (`success`, `message`, `error`, `data`),
  `NotFoundException`, `ConflictException` (409), `ValidationException` (400).
- **Service:** `GlobalExceptionHandler` (`@RestControllerAdvice`) maps each
  exception → status + envelope; falls through to `500` +
  `"Internal server error"` for anything unmapped (every contract's last
  `errors[]` entry).
- **Unit tests:** one `@WebMvcTest` per exception type asserting status code
  and envelope shape; unmapped `RuntimeException` → 500.
- **Postman:** none.

#### Chunk 0.3 — JWT auth core (`POST /api/auth/login`)
- **Scope:** Net-new endpoint (see gap #6 above), built only on
  `users.password_hash`/`is_active`, `roles`, `user_roles`.
- **Model/DTO:** `LoginRequest{organizationCode, branchCode, username, password}`,
  `LoginResponse{token, expiresAt, userId, organizationId, branchId, roles[]}`.
- **Service & RBAC:** `AuthService.login` — resolve org/branch by code, look
  up user by `(organizationId, branchId, username)`, verify
  `BCryptPasswordEncoder` hash, `403`/`401` style contract-consistent error
  (`{success:false, error:"Invalid credentials"}`, 401) if user inactive or
  password mismatch. `JwtService` issues a signed JWT with claims `sub`
  (userId), `org`, `branch`, `roles[]`; `JwtAuthFilter` validates it on every
  request and populates `SecurityContext`.
- **Controller:** `POST /api/auth/login`.
- **Unit tests:** valid login → 200 + token; wrong password → 401; inactive
  user → 401; unknown org/branch/username → 401 (do not leak which field was
  wrong); expired/tampered token on a protected endpoint → 401.
- **Postman:** `backend/postman/00-auth.postman_collection.json`.

#### Chunk 0.4 — RBAC permission evaluator
- **Scope:** Wire `role_permission` into Spring Security method security.
- **Model/DTO/Repo:** `RolePermissionRepository` (existing table, no schema change).
- **Service:** `PermissionEvaluatorService` bean `perm`, method
  `can(String moduleName, String action)` — reads roles off the current
  JWT's `SecurityContext`, unions `role_permission` rows for
  `(organizationId, branchId, roleId in ..., moduleName)`, checks the
  matching `can_*` boolean. `action` ∈ `CREATE|VIEW|UPDATE|DELETE|AUTHORIZE|PRINT|EXPORT`.
  Enable `@EnableMethodSecurity`; controllers annotate
  `@PreAuthorize("@perm.can('Billing','CREATE')")`.
- **Unit tests:** role with `can_create=true` on module X → allowed; role
  without the flag → 403; user with no `role_permission` row for that module →
  403; permission scoped to a different branch → 403.
- **Postman:** none (cross-cutting; exercised implicitly by every other
  collection's 401/403 cases).

#### Chunk 0.5 — Scope guard + audit log writer
- **Scope:** The org/branch existence check every contract's `validation[]`
  repeats, and the `audit_logs` write every mutating endpoint implies
  (table already exists, `database/schema/001_core_setup.sql`).
- **Model/DTO/Repo:** `AuditLogRepository`.
- **Service:** `ScopeGuard.requireOrgBranch(orgId, branchId)` → throws
  `NotFoundException("Organization or branch not found")` (the exact string
  used by ~40 contracts) if either is missing; `AuditLogService.record(action,
  entityType, entityId, oldValues, newValues)` called from every
  create/update/status-change service method going forward.
- **Unit tests:** missing org → 404 with the contract's exact error string;
  missing branch under a valid org → same; audit row written on a sample
  create-then-update sequence.
- **Postman:** none.

---

### M1 — Organization, Branch & Identity

**Contracts:** API-001, 002, 003, 004, 005, 128, 129
**RBAC module_name:** `Organization Management`, `Branch Management`,
`Role Management`, `User Management`, `User Role Management`

#### Chunk 1.1 — Organization (API-001) + bootstrap platform role
- **Scope:** Create Organization, gated per gap #6, not the normal RBAC check.
- **Model/DTO/Repo:** `Organization` entity/repo, `CreateOrganizationRequest`.
- **Service & RBAC:** `@PreAuthorize("hasRole('PLATFORM_ADMIN')")` (JWT role
  claim, not `role_permission` — no org exists yet to key permissions on).
  Flyway seed (part of Chunk 0.1's last migration) inserts the reserved
  `PLATFORM` org/branch/role/one bootstrap user.
- **Controller:** `POST /api/organizations`.
- **Unit tests:** per `API-001.errors[]` (missing name, missing code,
  duplicate code, 500 fallback) + success; non-`PLATFORM_ADMIN` caller → 403.
- **Postman:** `backend/postman/01-org-identity.postman_collection.json`.

#### Chunk 1.2 — Branch (API-002)
- **Scope:** Create Branch under an organization.
- **Model/DTO/Repo:** `Branch` entity/repo, `CreateBranchRequest`.
- **Service & RBAC:** same `PLATFORM_ADMIN` gate as 1.1 (branch is still
  pre-tenant bootstrap); org existence via `ScopeGuard`.
- **Controller:** `POST /api/organizations/{organizationId}/branches`.
- **Unit tests:** per `API-002.errors[]` + success.
- **Postman:** same collection as 1.1.

#### Chunk 1.3 — Roles (API-003 create, API-129 list/view/update/status)
- **Scope:** Full role lifecycle. **Includes the one schema migration in this
  plan** (gap #1): `V42__add_roles_is_active.sql`.
- **Model/DTO/Repo:** `Role` entity (+`isActive` field once migrated) /repo,
  `CreateRoleRequest`, `UpdateRoleRequest`, `RoleStatusRequest`.
- **Service & RBAC:** `@perm.can('Role Management', <action>)`.
- **Controller:** `POST .../roles`, `GET .../roles`, `GET .../roles/{roleId}`,
  `PUT .../roles/{roleId}`, `PATCH .../roles/{roleId}/status`.
- **Unit tests:** per `API-003.errors[]` and `API-129` operations' `errors[]`
  (4 operations × their own error lists) + success paths.
- **Postman:** same collection as 1.1, folder "Roles".

#### Chunk 1.4 — Users (API-004 create, API-128 list/view/update/status)
- **Scope:** Full user lifecycle. Password hashing via `BCryptPasswordEncoder`.
- **Model/DTO/Repo:** `User` entity/repo, `CreateUserRequest`
  (+ raw `password` field, contract's `password_hash` populated from it —
  read `API-004` for the exact request body), `UpdateUserRequest`, `UserStatusRequest`.
- **Service & RBAC:** `@perm.can('User Management', <action>)`.
- **Controller:** `POST .../users`, `GET .../users`, `GET .../users/{userId}`,
  `PUT .../users/{userId}`, `PATCH .../users/{userId}/status`.
- **Unit tests:** per `API-004.errors[]` and `API-128` operations' `errors[]` + success.
- **Postman:** same collection, folder "Users".

#### Chunk 1.5 — User-Role assignment (API-005)
- **Scope:** Assign a role to a user (`user_roles`).
- **Model/DTO/Repo:** `UserRole` entity/repo (composite key per schema).
- **Service & RBAC:** `@perm.can('User Role Management', 'CREATE')`; both
  user and role must belong to the same org+branch as the path.
- **Controller:** `POST .../users/{userId}/roles`.
- **Unit tests:** per `API-005.errors[]` + success.
- **Postman:** same collection, folder "User Roles".

---

### M2 — Master Data (Tests, Departments, Reference Ranges, Packages)

**Contracts:** API-006–011, 012–015, 111–119, 120–127
**RBAC module_name:** `Test Management`, `Department Management`,
`Reference Range Master`, `Test Package Management`

#### Chunk 2.1 — Test Master CRUD + status (API-006, 007, 008, 009)
- **Model/DTO/Repo:** `TestMaster` entity/repo, `CreateTestRequest`,
  `UpdateTestRequest`, `TestStatusRequest`.
- **Service & RBAC:** `@perm.can('Test Management', <action>)`; duplicate
  test code → 409 per `API-006`.
- **Controller:** `POST/GET/PUT .../tests`, `.../tests/{testId}`,
  `PATCH .../tests/{testId}/status`.
- **Unit tests:** per API-006/007/008/009 `errors[]` + success.
- **Postman:** `backend/postman/02-master-data.postman_collection.json`, folder "Tests".

#### Chunk 2.2 — Test list & search (API-010, 011)
- **Model/DTO:** `TestListResponse` (paged or flat per contract), search by
  `q` param.
- **Controller:** `GET .../tests`, `GET .../tests/search`.
- **Unit tests:** empty-query 400 (per `API-011`), no-results empty list, filter by `isActive`.
- **Postman:** same collection, folder "Tests".

#### Chunk 2.3 — Department CRUD + status (API-012–015)
- **Model/DTO/Repo:** `DepartmentMaster` entity/repo + 3 request DTOs.
- **Service & RBAC:** `@perm.can('Department Management', <action>)`.
- **Controller:** `POST/GET/PUT .../departments`, `.../departments/{departmentId}`,
  `PATCH .../departments/{departmentId}/status`.
- **Unit tests:** per API-012–015 `errors[]` + success.
- **Postman:** same collection, folder "Departments".

#### Chunk 2.4 — Parameters & Reference Ranges (API-111, 112, 113 + negatives 114–119)
- **Model/DTO/Repo:** `ParameterMaster`, `ReferenceRangeMaster` entities/repos,
  `CreateParameterRequest`, `CreateReferenceRangeRequest`, `ReferenceRangeLookupQuery`.
- **Service & RBAC:** `@perm.can('Reference Range Master', <action>)`;
  overlapping-demographic-band check (409, API-116), age/date/bound range
  validation (400s, API-117/118/119) all live in `ReferenceRangeService`.
- **Controller:** `POST /api/parameters`, `POST /api/reference-ranges`,
  `GET /api/reference-ranges/lookup`.
- **Unit tests:** per API-111/112/113 `errors[]` and API-114–119 scenarios + success.
- **Postman:** same collection, folder "Reference Ranges".

#### Chunk 2.5 — Test Packages (API-120, 121 + negatives 123–126)
- **Model/DTO/Repo:** `TestPackageMaster`, `TestPackageTestMapping`
  entities/repos, `CreateTestPackageRequest`, `AddTestToPackageRequest`.
- **Service & RBAC:** `@perm.can('Test Package Management', <action>)`;
  duplicate code/name (409), invalid/duplicate member test (404/409).
- **Controller:** `POST .../test-packages`, `POST .../test-packages/{packageId}/tests`.
- **Unit tests:** per API-120/121 `errors[]` and API-123–126 scenarios + success.
- **Postman:** same collection, folder "Test Packages".

#### Chunk 2.6 — Bill Test Package (API-122 + negative 127)
- **Scope:** Expands a package into billing line items. **Depends on M5
  (Billing) — sequence this chunk after Chunk 5.1**, not before.
- **Service:** `BillingService.addPackage(billingId, packageId)` — expands
  `test_package_test_mapping` rows into `billing_tests` rows tagged with
  `package_id`, pro-rata per contract.
- **Controller:** `POST .../billings/{billingId}/test-packages`.
- **Unit tests:** per API-122/127 `errors[]` + success (package expands to N
  billing_tests rows, sum matches package price rule from the contract).
- **Postman:** same collection, folder "Test Packages" (cross-links Billing collection too).

---

### M3 — Patient & Registration

**Contracts:** API-016–025
**RBAC module_name:** `Patient Management`, `Patient Registration`

#### Chunk 3.1 — Patient CRUD (API-016, 017, 018)
- **Model/DTO/Repo:** `Patient` entity/repo (+ optional `PatientContact`
  insert per API-016's `contact`/`email` convenience fields), `CreatePatientRequest`, `UpdatePatientRequest`.
- **Service & RBAC:** `@perm.can('Patient Management', <action>)`. No
  duplicate-patient-by-code check (gap #3) — only `uq_patient_contact`.
- **Controller:** `POST/GET/PUT .../patients`, `.../patients/{patientId}`.
- **Unit tests:** per API-016/017/018 `errors[]` + success.
- **Postman:** `backend/postman/03-patient-registration.postman_collection.json`, folder "Patients".

#### Chunk 3.2 — Patient search & status (API-019, 020)
- **Controller:** `GET .../patients/search`, `PATCH .../patients/{patientId}/status`.
- **Unit tests:** per API-019/020 `errors[]` + success.
- **Postman:** same collection, folder "Patients".

#### Chunk 3.3 — Registration create/view (API-021, 022)
- **Model/DTO/Repo:** `PatientRegistration` entity/repo, `CreateRegistrationRequest`.
- **Service & RBAC:** `@perm.can('Patient Registration', <action>)`; patient must exist in scope.
- **Controller:** `POST .../patients/{patientId}/registrations`, `GET .../registrations/{registrationId}`.
- **Unit tests:** per API-021/022 `errors[]` + success.
- **Postman:** same collection, folder "Registrations".

#### Chunk 3.4 — Registration status & history (API-023, 024)
- **Controller:** `PATCH .../registrations/{registrationId}/status`, `GET .../patients/{patientId}/registrations`.
- **Unit tests:** per API-023/024 `errors[]` + success.
- **Postman:** same collection, folder "Registrations".

#### Chunk 3.5 — Registration search (API-025)
- **Controller:** `GET .../registrations/search`.
- **Unit tests:** per API-025 `errors[]` + success (empty query, no results).
- **Postman:** same collection, folder "Registrations".

---

### M4 — Clinical History

**Contracts:** API-026–032
**RBAC module_name:** `Clinical History`

#### Chunk 4.1 — Create / View / Update (API-026, 027, 028 + negatives 029–031)
- **Model/DTO/Repo:** `PatientClinicalHistory` entity/repo,
  `CreateClinicalHistoryRequest`, `UpdateClinicalHistoryRequest`.
- **Service & RBAC:** `@perm.can('Clinical History', <action>)`; validates
  patient, `clinical_master` reference, and registration all exist in scope
  (the three negative scenarios API-029/030/031).
- **Controller:** `POST/GET/PUT .../patients/{patientId}/clinical-history[/{clinicalHistoryId}]`.
- **Unit tests:** per API-026/027/028 `errors[]` + API-029/030/031 scenarios + success.
- **Postman:** `backend/postman/04-clinical-history.postman_collection.json`.

#### Chunk 4.2 — Search Clinical History (API-032)
- **Controller:** `GET .../patients/{patientId}/clinical-history` with search params.
- **Unit tests:** per API-032 `errors[]` + success.
- **Postman:** same collection.

---

### M5 — Billing

**Contracts:** API-033–042
**RBAC module_name:** `Billing`

#### Chunk 5.1 — Create / View Bill (API-033, 034 + negatives 040, 041, 042)
- **Model/DTO/Repo:** `BillingMaster` entity/repo, `CreateBillRequest`.
- **Service & RBAC:** `@perm.can('Billing', <action>)`; registration must
  exist (API-040), bill number unique per org+branch (API-041).
- **Controller:** `POST .../billing`, `GET .../billing/{billingId}`.
- **Unit tests:** per API-033/034 `errors[]` + API-040/041/042 scenarios + success.
- **Postman:** `backend/postman/05-billing.postman_collection.json`.

#### Chunk 5.2 — Update Bill / Add Test / View Billing Tests (API-035, 036, 037)
- **Model/DTO/Repo:** `BillingTests` entity/repo, `UpdateBillRequest`, `AddBillingTestRequest`.
- **Controller:** `PUT .../billing/{billingId}`, `POST .../billing/{billingId}/tests`,
  `GET .../billing/{billingId}/tests`.
- **Unit tests:** per API-035/036/037 `errors[]` + success.
- **Postman:** same collection.

#### Chunk 5.3 — Search & Cancel Bill (API-038, 039)
- **Controller:** `GET .../billing/search`, `PATCH .../billing/{billingId}/cancel`.
- **Unit tests:** per API-038/039 `errors[]` + success.
- **Postman:** same collection.

*(Chunk 2.6 — Bill Test Package — executes after 5.1; it lives in M2's
numbering but touches this module's service.)*

---

### M7 — Accession

**Contracts:** API-043–056
**RBAC module_name:** `Accession`

*(Sequenced before M6/Payment because API-057 Create Payment needs `accessionId`.)*

#### Chunk 7.1 — Create / View Accession (API-043, 044 + negatives 052–055)
- **Model/DTO/Repo:** `AccessionMaster` entity/repo, `CreateAccessionRequest`.
- **Service & RBAC:** `@perm.can('Accession', <action>)`; billing and
  registration must exist (API-054/055), accession number unique (API-053).
- **Controller:** `POST .../accessions`, `GET .../accessions/{accessionId}`.
- **Unit tests:** per API-043/044 `errors[]` + API-052–055 scenarios + success.
- **Postman:** `backend/postman/06-accession.postman_collection.json`.

#### Chunk 7.2 — Update Accession / Status (API-045, 046)
- **Controller:** `PUT .../accessions/{accessionId}`, `PATCH .../accessions/{accessionId}/status`.
- **Unit tests:** per API-045/046 `errors[]` + success.
- **Postman:** same collection.

#### Chunk 7.3 — Accession Tests: list + sample/collection status (API-047, 048, 049)
- **Model/DTO/Repo:** `AccessionTests` entity/repo (line items).
- **Controller:** `GET .../accessions/{accessionId}/tests`,
  `PATCH .../tests/{accessionTestId}/sample-status`,
  `PATCH .../tests/{accessionTestId}/collection-status`.
- **Unit tests:** per API-047/048/049 `errors[]` + success.
- **Postman:** same collection.

#### Chunk 7.4 — Authorization / report status (API-050, 051)
- **Controller:** `PATCH .../tests/{accessionTestId}/authorization-status`,
  `PATCH .../tests/{accessionTestId}/report-status`.
- **Unit tests:** per API-050/051 `errors[]` + success.
- **Postman:** same collection.

#### Chunk 7.5 — Search Accessions (API-056)
- **Controller:** `GET .../accessions/search`.
- **Unit tests:** per API-056 `errors[]` + success.
- **Postman:** same collection.

---

### M6 — Payment

**Contracts:** API-057–068
**RBAC module_name:** `Payment`

#### Chunk 6.1 — Create Payment / Payment Against Bill (API-057, 060 + negatives 061–064)
- **Model/DTO/Repo:** `Payment` entity/repo, `CreatePaymentRequest`, `PaymentAgainstBillRequest`.
- **Service & RBAC:** `@perm.can('Payment', <action>)`; billing must exist
  (API-061), payment mode must be a configured `payment_mode_master` row
  (API-062), amount > 0 (API-063), transaction reference unique (API-064).
  Read `API-SCENARIO-MAP.md` item 6 before implementing — API-057 requires
  `accessionId`, API-060 does not; keep both endpoints exactly as their
  contracts specify rather than merging them.
- **Controller:** `POST /api/payments`, `POST /api/bills/{billingId}/payments`.
- **Unit tests:** per API-057/060 `errors[]` + API-061–064 scenarios + success.
- **Postman:** `backend/postman/07-payment.postman_collection.json`.

#### Chunk 6.2 — View / Update Payment, Search (API-058, 059, 065, 066, 067)
- **Controller:** `GET /api/payments/{paymentId}`, `PUT /api/payments/{paymentId}`,
  `GET /api/payments?billNumber=` (per gap #4 — `billNumber`, not `billingId`).
- **Unit tests:** per API-058/059/065 `errors[]` + API-066/067 scenarios (invalid
  ID, cross-org/branch scope → 404) + success.
- **Postman:** same collection.

#### Chunk 6.3 — Payment status (API-068)
- **Controller:** `PATCH /api/payments/{paymentId}/status`.
- **Service:** recompute `billing_master.paid_amount`/`balance_amount` from
  successful payments on status change (matches the UI-observed behavior in
  `Screens/API-SCENARIO-MAP.md`).
- **Unit tests:** per API-068 `errors[]` + success (bill balance recalculates).
- **Postman:** same collection.

---

### M8 — Sample Collection & Worklist/Worksheet

**Contracts:** API-069–087, 130
**RBAC module_name:** `Sample Collection`, `Worklist Management`

#### Chunk 8.1 — Sample Collection (API-069 + negatives 070–076)
- **Model/DTO/Repo:** `SampleCollection` entity/repo, `CreateSampleCollectionRequest`.
- **Service & RBAC:** `@perm.can('Sample Collection', <action>)`; validates
  accession test, collector (user), sample condition, collection status,
  quantity, duplicate collection, org/branch scope — one 4xx per negative
  contract (API-070–076).
- **Controller:** `POST /api/sample-collections`.
- **Unit tests:** per API-069 `errors[]` + API-070–076 scenarios + success.
- **Postman:** `backend/postman/08-sample-worklist.postman_collection.json`.

#### Chunk 8.2 — Worklist / Worksheet create (API-077, 078 + negatives 080–084)
- **Model/DTO/Repo:** `WorklistMaster`, `WorksheetMaster` entities/repos,
  `CreateWorklistRequest`, `CreateWorksheetRequest`.
- **Service & RBAC:** `@perm.can('Worklist Management', <action>)`;
  department must exist (API-080), code/name uniqueness (API-081–084).
- **Controller:** `POST /api/worklists`, `POST /api/worksheets`.
- **Unit tests:** per API-077/078 `errors[]` + API-080–084 scenarios + success.
- **Postman:** same collection.

#### Chunk 8.3 — Assign sample to worklist (API-079 + negatives 085–087)
- **Controller:** `PATCH .../accession-tests/{accessionTestId}/worklist`.
- **Unit tests:** per API-079 `errors[]` + API-085/086/087 scenarios + success.
- **Postman:** same collection.

#### Chunk 8.4 — List/Search/View/Status worklist (API-130)
- **Controller:** `GET /api/organizations/{organizationId}/branches/{branchId}/worklists`
  (list/search/view/status per the contract's bundled operations — read
  `API-130` for the exact sub-routes).
- **Unit tests:** per API-130's operation-level `errors[]` + success for each.
- **Postman:** same collection.

---

### M9 — Result Entry & Authorization

**Contracts:** API-088–099, 131, 132
**RBAC module_name:** `Result Entry`, `Result Authorization`

#### Chunk 9.1 — Create Result Entry (API-088 + negatives 091, 092)
- **Model/DTO/Repo:** `ResultEntry` entity/repo, `CreateResultEntryRequest`.
- **Service & RBAC:** `@perm.can('Result Entry', 'CREATE')`; accession test
  must exist (API-091), one result entry per accession test (API-092, unique constraint).
- **Controller:** `POST /api/result-entries`.
- **Unit tests:** per API-088 `errors[]` + API-091/092 scenarios + success.
- **Postman:** `backend/postman/09-result.postman_collection.json`.

#### Chunk 9.2 — Add Result Detail (API-089 + negatives 093–095)
- **Model/DTO/Repo:** `ResultEntryDetails` entity/repo, `AddResultDetailRequest`.
- **Controller:** `POST /api/result-entries/{resultEntryId}/details`.
- **Unit tests:** per API-089 `errors[]` + API-093/094/095 scenarios + success.
- **Postman:** same collection.

#### Chunk 9.3 — Update Result Entry Status (API-090 + negative 096)
- **Controller:** `PATCH /api/result-entries/{resultEntryId}/status`.
- **Unit tests:** per API-090 `errors[]` + API-096 scenario + success.
- **Postman:** same collection.

#### Chunk 9.4 — View / Update Result (API-131)
- **Controller:** `GET /api/result-entries/{resultEntryId}` (view + update per
  the contract's bundled operations).
- **Unit tests:** per API-131's `errors[]` + success.
- **Postman:** same collection.

#### Chunk 9.5 — Authorize Result Entry (API-097 + negatives 098, 099) + List Pending (API-132)
- **Model/DTO/Repo:** `ResultAuthorization` entity/repo.
- **Service & RBAC:** `@perm.can('Result Authorization', 'AUTHORIZE')`;
  result entry must exist (API-098), must be `COMPLETED` before authorizing (API-099).
- **Controller:** `PATCH /api/result-entries/{resultEntryId}/authorize`,
  `GET .../result-entries` (pending list, API-132).
- **Unit tests:** per API-097 `errors[]` + API-098/099 scenarios + API-132 `errors[]` + success.
- **Postman:** same collection.

---

### M10 — Report Generation, Delivery & History

**Contracts:** API-100–110, 133, 134, 135
**RBAC module_name:** `Report Generation`, `Report Delivery`

#### Chunk 10.1 — Generate Report (API-100 + negatives 101–103)
- **Model/DTO/Repo:** `ReportMaster` entity/repo, `GenerateReportRequest`.
- **Service & RBAC:** `@perm.can('Report Generation', 'CREATE')`; accession
  must exist (API-101), report number unique (API-102), one report per
  accession (API-103).
- **Controller:** `POST /api/reports`.
- **Unit tests:** per API-100 `errors[]` + API-101/102/103 scenarios + success.
- **Postman:** `backend/postman/10-report.postman_collection.json`.

#### Chunk 10.2 — Report status update / View Report (API-104, 133)
- **Controller:** `PATCH /api/reports/{reportId}/status`, `GET /api/reports/{reportId}`.
- **Unit tests:** per API-104/133 `errors[]` + success.
- **Postman:** same collection.

#### Chunk 10.3 — Log Delivery / Release Report (API-105, 106 + negatives 107–110)
- **Model/DTO/Repo:** `ReportDeliveryLog` entity/repo, `LogDeliveryRequest`.
- **Controller:** `POST /api/reports/{reportId}/deliveries`, `PATCH /api/reports/{reportId}/release`.
- **Unit tests:** per API-105/106 `errors[]` + API-107/108/109/110 scenarios + success.
- **Postman:** same collection.

#### Chunk 10.4 — Report History (API-134)
- **Controller:** `GET .../patients/{patientRegistrationId}/reports`.
- **Unit tests:** per API-134 `errors[]` + success.
- **Postman:** same collection.

#### Chunk 10.5 — Batch Send + Delivery Status (API-135)
- **Controller:** `POST /api/reports/deliveries/batch` (batch send + status view per contract).
- **Unit tests:** per API-135's `errors[]` + success.
- **Postman:** same collection.

---

### M11 — Outsource

**Contract:** API-136 (3 operations, 1 explicitly blocked — see gap #2)
**RBAC module_name:** `Outsource`

#### Chunk 11.1 — Create Outsource Order + List/View (API-136, ops 1–2)
- **Model/DTO/Repo:** no new entity — reuses `AccessionTests`
  (`performing_lab_id`) and `PerformingLabMaster` (read).
- **Service & RBAC:** `@perm.can('Outsource', <action>)`.
- **Controller:** `PATCH .../accession-tests/{accessionTestId}/outsource`,
  `GET .../outsource/accession-tests`.
- **Unit tests:** per API-136 op 1/2 `errors[]` + success.
- **Postman:** `backend/postman/11-outsource.postman_collection.json`.

#### Chunk 11.2 — Update Outsource Status — **blocked, do not build**
- **Scope:** Contract explicitly states `NOT IMPLEMENTABLE` pending a schema
  decision (add `outsource_status` column or a dedicated table). Ship the
  documented `409` stub only if a stakeholder asks for the route to exist;
  otherwise leave unbuilt and record it as blocked in `progress.md`.
- **Postman:** none until unblocked.

---

### M12 — Finance & Analytics

**Contracts:** API-137, 138, 139 (all read-only aggregate queries over billing/payment)
**RBAC module_name:** `Finance Overview`, `Finance Reports`, `Most Tested Tests`

#### Chunk 12.1 — Finance Dashboard Summary (API-137)
- **Service:** aggregate queries over `billing_master`/`payment` (native
  `@Query` or JPQL `SUM`/`GROUP BY` — no new tables).
- **Controller:** `GET .../finance/dashboard`.
- **Unit tests:** per API-137 `errors[]` + success against seeded billing/payment fixtures.
- **Postman:** `backend/postman/12-finance.postman_collection.json`.

#### Chunk 12.2 — Finance Reports (API-138)
- **Controller:** `GET .../finance/reports` (date-wise / payment-mode-wise /
  user-wise collection, branch-wise / org-wise billing, payment transaction
  report — all query-param variants of one endpoint per the contract).
- **Unit tests:** per API-138's `errors[]` + one test per report variant listed in the contract.
- **Postman:** same collection.

#### Chunk 12.3 — Most Tested Tests (API-139)
- **Controller:** `GET .../reports/most-tested-tests`.
- **Unit tests:** per API-139 `errors[]` + success.
- **Postman:** same collection.

---

## Appendix A — RBAC `module_name` registry

| module_name (exact string, matches contract `"module"`) | Chunks |
|---|---|
| Organization Management | 1.1 |
| Branch Management | 1.2 |
| Role Management | 1.3 |
| User Management | 1.4 |
| User Role Management | 1.5 |
| Test Management | 2.1, 2.2 |
| Department Management | 2.3 |
| Reference Range Master | 2.4 |
| Test Package Management | 2.5, 2.6 |
| Patient Management | 3.1, 3.2 |
| Patient Registration | 3.3, 3.4, 3.5 |
| Clinical History | 4.1, 4.2 |
| Billing | 5.1, 5.2, 5.3 |
| Accession | 7.1–7.5 |
| Payment | 6.1–6.3 |
| Sample Collection | 8.1 |
| Worklist Management | 8.2, 8.3, 8.4 |
| Result Entry | 9.1–9.4 |
| Result Authorization | 9.5 |
| Report Generation | 10.1, 10.2 |
| Report Delivery | 10.3, 10.4, 10.5 |
| Outsource | 11.1 |
| Finance Overview | 12.1 |
| Finance Reports | 12.2 |
| Most Tested Tests | 12.3 |

Seed `role_permission` rows for each `module_name` × role during Chunk 0.1's
seed data (or a dedicated seed migration) so RBAC tests in every chunk have
fixtures to assert against.
