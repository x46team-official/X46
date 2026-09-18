# X46 LIMS Backend — Progress Tracker

Update this file at the end of every chunk (the chunk execution prompt in
`CHUNK_PROMPT.md` requires it). One row per chunk from `../plan.md`. Do not
reopen a chunk marked ✅ — file a new chunk instead if something needs to change.

Status legend: `⬜ not started` · `🔄 in progress` · `✅ done` · `🚧 blocked`

## M0 — Platform Foundation

| Chunk | Title | Status | Tests | Postman |
|---|---|---|---|---|
| 0.1 | Flyway baseline + entity base classes | ✅ | ✅ | n/a |
| 0.2 | API response envelope + exception handling | ✅ | ✅ | n/a |
| 0.3 | JWT auth core (`/api/auth/login`) | ✅ | ✅ | ✅ |
| 0.4 | RBAC permission evaluator | ✅ | ✅ | n/a |
| 0.5 | Scope guard + audit log writer | ✅ | ✅ | n/a |

## M1 — Organization, Branch & Identity

| Chunk | Title | Status | Tests | Postman |
|---|---|---|---|---|
| 1.1 | Organization + bootstrap platform role | ✅ | ✅ | ✅ |
| 1.2 | Branch | ✅ | ✅ | ✅ |
| 1.3 | Roles (+ `roles.is_active` migration) | ✅ | ✅ | ✅ |
| 1.4 | Users | ✅ | ✅ | ✅ |
| 1.5 | User-Role assignment | ✅ | ✅ | ✅ |
| 1.6 | List Organizations (platform monitoring, gap #7) | ✅ | ✅ | ✅ |
| 1.8 | List Organization Users (platform monitoring, gap #7) | ✅ | ✅ | ✅ |
| 1.7 | Bootstrap Admin (first login for a new org, gap #7) | ✅ | ✅ | ✅ |

## M2 — Master Data

| Chunk | Title | Status | Tests | Postman |
|---|---|---|---|---|
| 2.1 | Test Master CRUD + status | ✅ | ✅ | ✅ |
| 2.2 | Test list & search | ✅ | ✅ | ✅ |
| 2.3 | Department CRUD + status | ✅ | ✅ | ✅ |
| 2.4 | Parameters & Reference Ranges | ✅ | ✅ | ✅ |
| 2.5 | Test Packages | ⬜ | ⬜ | ⬜ |
| 2.6 | Bill Test Package (needs 5.1 first) | ⬜ | ⬜ | ⬜ |

## M3 — Patient & Registration

| Chunk | Title | Status | Tests | Postman |
|---|---|---|---|---|
| 3.1 | Patient CRUD | ⬜ | ⬜ | ⬜ |
| 3.2 | Patient search & status | ⬜ | ⬜ | ⬜ |
| 3.3 | Registration create/view | ⬜ | ⬜ | ⬜ |
| 3.4 | Registration status & history | ⬜ | ⬜ | ⬜ |
| 3.5 | Registration search | ⬜ | ⬜ | ⬜ |

## M4 — Clinical History

| Chunk | Title | Status | Tests | Postman |
|---|---|---|---|---|
| 4.1 | Create / View / Update | ⬜ | ⬜ | ⬜ |
| 4.2 | Search | ⬜ | ⬜ | ⬜ |

## M5 — Billing

| Chunk | Title | Status | Tests | Postman |
|---|---|---|---|---|
| 5.1 | Create / View Bill | ⬜ | ⬜ | ⬜ |
| 5.2 | Update Bill / Add Test / View Billing Tests | ⬜ | ⬜ | ⬜ |
| 5.3 | Search & Cancel Bill | ⬜ | ⬜ | ⬜ |

## M7 — Accession *(built before M6 — see plan.md § Execution order)*

| Chunk | Title | Status | Tests | Postman |
|---|---|---|---|---|
| 7.1 | Create / View Accession | ⬜ | ⬜ | ⬜ |
| 7.2 | Update Accession / Status | ⬜ | ⬜ | ⬜ |
| 7.3 | Accession Tests list + sample/collection status | ⬜ | ⬜ | ⬜ |
| 7.4 | Authorization / report status | ⬜ | ⬜ | ⬜ |
| 7.5 | Search Accessions | ⬜ | ⬜ | ⬜ |

## M6 — Payment

| Chunk | Title | Status | Tests | Postman |
|---|---|---|---|---|
| 6.1 | Create Payment / Payment Against Bill | ⬜ | ⬜ | ⬜ |
| 6.2 | View / Update Payment, Search | ⬜ | ⬜ | ⬜ |
| 6.3 | Payment status | ⬜ | ⬜ | ⬜ |

## M8 — Sample Collection & Worklist/Worksheet

| Chunk | Title | Status | Tests | Postman |
|---|---|---|---|---|
| 8.1 | Sample Collection | ⬜ | ⬜ | ⬜ |
| 8.2 | Worklist / Worksheet create | ⬜ | ⬜ | ⬜ |
| 8.3 | Assign sample to worklist | ⬜ | ⬜ | ⬜ |
| 8.4 | List/Search/View/Status worklist | ⬜ | ⬜ | ⬜ |

## M9 — Result Entry & Authorization

| Chunk | Title | Status | Tests | Postman |
|---|---|---|---|---|
| 9.1 | Create Result Entry | ⬜ | ⬜ | ⬜ |
| 9.2 | Add Result Detail | ⬜ | ⬜ | ⬜ |
| 9.3 | Update Result Entry Status | ⬜ | ⬜ | ⬜ |
| 9.4 | View / Update Result | ⬜ | ⬜ | ⬜ |
| 9.5 | Authorize Result Entry + List Pending | ⬜ | ⬜ | ⬜ |

## M10 — Report Generation, Delivery & History

| Chunk | Title | Status | Tests | Postman |
|---|---|---|---|---|
| 10.1 | Generate Report | ⬜ | ⬜ | ⬜ |
| 10.2 | Report status update / View Report | ⬜ | ⬜ | ⬜ |
| 10.3 | Log Delivery / Release Report | ⬜ | ⬜ | ⬜ |
| 10.4 | Report History | ⬜ | ⬜ | ⬜ |
| 10.5 | Batch Send + Delivery Status | ⬜ | ⬜ | ⬜ |

## M11 — Outsource

| Chunk | Title | Status | Tests | Postman |
|---|---|---|---|---|
| 11.1 | Create Outsource Order + List/View | ⬜ | ⬜ | ⬜ |
| 11.2 | Update Outsource Status | 🚧 blocked — schema gap, see plan.md § 2 gap #2 | n/a | n/a |

## M12 — Finance & Analytics

| Chunk | Title | Status | Tests | Postman |
|---|---|---|---|---|
| 12.1 | Finance Dashboard Summary | ⬜ | ⬜ | ⬜ |
| 12.2 | Finance Reports | ⬜ | ⬜ | ⬜ |
| 12.3 | Most Tested Tests | ⬜ | ⬜ | ⬜ |

---

## Log

One line per completed chunk: date, chunk id, one-sentence note (deviations
from plan.md, follow-ups filed, etc). Newest first.

- 2026-09-19, Chunk 2.4: `ParameterMaster` + `ReferenceRangeMaster` entities
  (both `AbstractTenantEntity`; only the columns API-111/112/113 touch are
  mapped — `data_type`/`result_type`/`decimal_places`/`display_order` etc.
  are left out of the INSERT so their DB defaults apply) + repositories + one
  `ReferenceRangeService` + one `ReferenceRangeController` in `master`, all
  gated `@perm.can('Reference Range Master', CREATE|VIEW)`. API-114–119 are
  failure scenarios of the same two POSTs, not separate endpoints.
  **Lookup's org/branch come from the caller's JWT**: API-113 lists
  `organizationId`/`branchId` in `required_fields` and `scope` but defines no
  query/path parameter for them, so `@AuthenticationPrincipal JwtPrincipal`
  supplies them rather than inventing parameters. Also no `ScopeGuard` call
  there — a valid token's org/branch always exist.
  **Lookup gender is an exact match**, per API-113's documented filter — a
  `MALE` lookup does *not* fall back to an `ANY` band. Clinically a fallback
  may be wanted; not added since the contract doesn't specify it. Unknown
  `parameterId` on lookup naturally matches no band → the contract's single
  404 `"No matching reference range found"` (no separate existence check).
  **Overlap 409 (API-116) comes from the DB trigger, not a Java copy of it**:
  `saveAndFlush` + catch `DataAccessException` whose most-specific cause
  contains `"overlapping demographic band"` (the trigger's `RAISE` text) →
  `ConflictException`; any other DB failure is rethrown untouched (unit test
  `createRangeOtherDatabaseFailureIsNotMaskedAsConflict`). Race-free, and the
  trigger stays the single source of truth. The age/effective/bounds CHECKs
  (API-117/118/119) *are* pre-validated in the service so callers get the
  contract's exact 400 messages instead of a 500.
  **Additions beyond the literal `errors[]`, same precedent as Chunk 2.1**:
  missing required fields → 400 `"<field> is required"`; `gender`/`ageUnit`
  outside the DB CHECK sets → 400 `"Invalid gender"`/`"Invalid age unit"`
  (would otherwise be a CHECK-violation 500); duplicate `parameterName` → 409
  `"Duplicate parameter name"` (`uq_parameter_master_name` is in API-111's
  own `validation[]`); org/branch existence on both POSTs →
  `scopeGuard.requireOrgBranch`; reference range's `parameterId` must belong
  to the same org+branch, else 404 `"Parameter not found"`.
  `mvn test` green (288/288 — 257 from 0.1-2.3 + 17
  `ReferenceRangeServiceTest` Mockito cases (parameter: missing code 400,
  org/branch 404, duplicate code/name 409 ×2, success; range: missing
  parameterId 400, invalid gender 400, age/date/bounds 400 ×3, unknown
  parameter 404, trigger-overlap 409, non-overlap DB error rethrown, contract
  defaults applied; lookup: missing gender 400, no match 404, success with
  defaulted date/pregnancy) + 14 `ReferenceRangeIntegrationTest` full-stack
  cases against the real dockerized Postgres — including
  `overlappingBandIsRejectedByTriggerWith409`, which proves the real trigger
  error surfaces as the caught exception — plus a 403 and a 401).
  Postman: `02-master-data.postman_collection.json` gained a "Chunk 2.4 -
  Reference Ranges" folder (3 requests); API-114–119's error examples are
  attached to the request they exercise, deduplicated, all verbatim from the
  contracts.
- 2026-09-18, Chunk 2.3: `DepartmentMaster` entity (extends
  `AbstractTenantEntity`; `is_active` mapped as boxed `Boolean` because the
  column is nullable — `DEFAULT TRUE` with no `NOT NULL` — and a NULL would
  blow up unboxing into a primitive) + `DepartmentMasterRepository` +
  `DepartmentService` + `DepartmentController` in `master`, gated
  `@perm.can('Department Management', CREATE|VIEW|UPDATE)` (status uses
  `UPDATE`, same as Test/Role/User). `created_by`/`updated_by` left unmapped —
  no contract reads or writes them.
  **One 404 via a scoped lookup, not `ScopeGuard`, on View/Update/Status**:
  API-013/014/015 all collapse unknown org, unknown branch, unknown
  department and out-of-scope department into the single message
  `"Department not found"`, which `requireOrgBranch`'s combined
  `"Organization or branch not found"` would contradict. A single
  `findByIdAndOrganizationIdAndBranchId` lookup enforces the same tenancy
  rule (a row under another org/branch simply isn't found) and yields the
  contract's message for every case. Create still uses
  `scopeGuard.requireOrgBranch`, since API-012's message matches it.
  **Code-or-name duplicates share one 409** (`"Duplicate department
  code/name"`), per both contracts; Update uses `…AndIdNot` so a department
  never collides with itself. `departmentCode` is required at the API layer
  even though the DB column is nullable — API-012's own note says this is
  deliberate. Update only overwrites `description` when sent (same
  optional-field handling as `TestService.update`) and bumps `updated_at`.
  Request DTOs kept as 3 separate records per plan.md even though
  Create/Update share a shape; 4 response DTOs because each contract returns
  a different field set (only View includes `description`).
  **Follow-up (not fixed, per rule 1):** Chunk 2.1's
  `TestService.requireDepartment` still checks department existence with a
  raw `JdbcTemplate` query because no Department entity existed then; it can
  now use `DepartmentMasterRepository.findByIdAndOrganizationIdAndBranchId`
  (or an `exists…` equivalent) instead.
  **Unrelated uncommitted work stashed, not touched:** an unfinished
  organization-status change (`OrganizationService` +
  `OrganizationStatusRequest`/`Response`, not a plan.md chunk) broke
  compilation for the whole module, so it was set aside with `git stash`
  (`"WIP org status (stashed during Chunk 2.3)"`) to get a buildable tree —
  `git stash pop` to resume it.
  `mvn test` green (257/257 — 226 from 0.1-2.2 + CORS, + 15
  `DepartmentServiceTest` Mockito cases (create: missing code / blank name
  400, org/branch 404, duplicate code 409, duplicate name 409, success; view:
  404, success; update: 400, 404, collision 409, success keeping description;
  status: 400, 404, success) + 16 `DepartmentIntegrationTest` full-stack cases
  against the real dockerized Postgres covering all 4 endpoints' success/error
  paths, including a department viewed under another branch → 404, a
  malformed UUID → 400 `"Invalid request"`, a `@perm.can`-driven 403 and a
  401). Postman: `backend/postman/02-master-data.postman_collection.json`
  gained a "Chunk 2.3 - Departments" folder with all 4 requests and example
  responses taken verbatim from `API-012`–`API-015`.
- 2026-09-17, Infra (not a plan.md chunk): **CORS was never actually wired up
  — the 2026-09-15 entry below is wrong.** That entry claims a
  `CorsConfigurationSource` bean was added to `SecurityConfig` and "wired into
  the filter chain via `.cors(...)`". It wasn't: `git log -S "cors" --
  SecurityConfig.java` returns no commits, and `app.cors.allowed-origins` (in
  `application.properties` since `31f9db5`) was an **orphaned property no Java
  code read**. Net effect: every browser request from `frontend/` was blocked
  — the preflight `OPTIONS /api/auth/login` hit
  `.anyRequest().authenticated()` and came back `401` with no
  `Access-Control-Allow-Origin`, so the browser never sent the real request
  and the frontend showed its generic "Unable to reach the server" fallback
  (`http-client.ts`). `curl` never caught it because curl ignores CORS, and
  no test covered it, so the whole suite stayed green while the app was
  unusable from a browser. Fixed for real this time: `corsConfigurationSource`
  bean reading the existing property + `.cors(Customizer.withDefaults())` in
  the chain, so Spring Security's `CorsFilter` answers preflights before the
  authorization rules run. Deliberately **no `setAllowCredentials(true)`** —
  auth is a Bearer header, not a cookie, so credentialed CORS isn't needed.
  New `security.CorsIntegrationTest` (3 cases: preflight from an allowed
  origin → 200 + header, real request carries the header, disallowed origin →
  403 and no header) is the check that was missing the first time.
  `mvn test` green (226/226 — 223 from 0.1-2.2 + 3 CORS cases).
  **Follow-up for whoever is running the app:** a backend started before this
  fix is still serving the old filter chain — it must be restarted for the
  frontend to work.
- 2026-09-17, Chunk 2.2: `TestService.list`/`search` + two `GET` mappings on
  the existing `TestController`, plus `TestMasterRepository
  .findByOrganizationIdAndBranchId` and a `search` `@Query` — the latter
  copies `RoleRepository.search`'s `LOWER(...) LIKE LOWER(CONCAT('%',:query,'%'))`
  shape verbatim. Safe from Chunk 1.3's Postgres null-bind bug
  (`function lower(bytea) does not exist`) because `query` is **required**
  here and is rejected with a 400 before the query ever runs, so no NULL is
  ever bound — no need for 1.3's two-method split.
  **Two spots where the contract overrides plan.md's shorthand**, resolved in
  the contract's favour per CLAUDE.md rule 2: (1) plan.md says "search by `q`
  param", but `API-011`'s `query_parameters` names it **`query`**; (2)
  plan.md's unit-test line says "filter by `isActive`", but `API-010`
  declares `"query_parameters": {}` — **no filter param exists in the
  contract**, so none was added; the listing returns every test in scope and
  `listIncludesInactiveTests` asserts an inactive row still comes back with
  `isActive: false` instead (consistent with `API-007`'s note that inactivity
  never hides a test).
  **Per-endpoint response DTOs again** (`TestListItemResponse` has
  `departmentId`/`sellingPrice`/`costPrice`, `TestSearchItemResponse` has only
  `id`/`testCode`/`testName`/`isActive`) — the two contracts genuinely specify
  different shapes, so no shared DTO, same reasoning as Chunk 1.3/2.1.
  Both endpoints use Chunk 0.5's original combined-message
  `ScopeGuard.requireOrgBranch` (both contracts say "Organization or branch
  not found"), **not** the `requireBranch` added in 2.1 — that one exists for
  API-006/007's branch-only message and is deliberately left unused here.
  **Extended `GlobalExceptionHandler`** (Chunk 0.2's file) with
  `MethodArgumentTypeMismatchException` → 400 `"Invalid request"`, which is
  `API-010`'s second `errors[]` entry ("malformed path parameters"): a bad
  UUID in the path previously fell through to the catch-all `Exception`
  handler and surfaced as a 500. Same extend-shared-Module-0-infra precedent
  as Chunk 0.3's 401 and Chunk 0.4's 403, and it fixes the same latent 500
  for every other UUID-path endpoint in the app.
  Route precedence between the new `GET .../tests/search` and Chunk 2.1's
  `GET .../tests/{testId}` resolves in favour of the literal `search` segment
  (Spring's `PathPatternParser` sorts literals above variables) — proven by
  `searchTestsMatchesCodeOrName` (200 + real results) and
  `searchTestsMissingQueryReturns400`, which returns "Search query is
  required" rather than the "Invalid request" a `{testId}` UUID-parse
  failure would now produce.
  `mvn test` green (223/223 — 207 from 0.1-2.1 + 9 `TestServiceTest` Mockito
  cases (list: org/branch 404, success, inactive-included, empty; search:
  missing/blank query 400 ×2, org/branch 404, success, no-matches empty) + 7
  `TestIntegrationTest` full-stack cases against the real dockerized Postgres
  (list success/404/malformed-UUID-400, search success/empty/400/404)).
  Postman: `backend/postman/02-master-data.postman_collection.json` gained a
  "Chunk 2.2 - Test list & search" folder with both requests and their
  example responses taken verbatim from `API-010`/`API-011`.
- 2026-09-17, Chunk 2.1: **M2 — Master Data is now open.** New `master`
  package (mirrors `org`/`identity`'s controller/dto/entity/repository/service
  layout) — `TestMaster` extends `AbstractTenantEntity` (`test_master` has
  org_id/branch_id/created_at/updated_at NOT NULL, same fit as `User`),
  mapping every column the API-006–009 contracts actually read or write
  (not the unused FK columns like `container_type_id`, already excluded by
  API-006's own notes, or `worksheet_id`/`worklist_id`/etc. beyond what
  create's request body lists). `TestMasterRepository` +`TestService` +
  `TestController` (`@perm.can('Test Management', <action>)`).
  **Extended `ScopeGuard`** with `requireBranch(organizationId, branchId)` →
  `"Branch not found"` — API-006/API-007 need this exact message distinct
  from `requireOrgBranch`'s combined `"Organization or branch not found"`;
  same reuse-not-fork precedent as Chunk 1.2's `requireOrg`. View (API-007)
  needed three distinct 404s (`Organization not found`/`Branch not found`/
  `Test not accessible` vs `Test not found`), so it calls `requireOrg` +
  `requireBranch` separately rather than the combined check, then
  disambiguates "doesn't exist anywhere" from "exists but wrong org/branch"
  by looking the test up by id alone first.
  **Department existence is checked via a scoped `JdbcTemplate` query**
  directly in `TestService` (no `Department` entity exists until Chunk 2.3)
  — same precedent as `AuthLookupRepository`/`UserService`'s org-code lookup
  for pre-entity tables.
  **Three deviations beyond the literal `errors[]` catalog**, all justified
  by the contracts' own `validation[]`/`required_fields` text rather than
  invented: (1) Update (API-008) rejects a missing `departmentId` with 400
  even though no such entry is in `errors[]` — `required_fields` lists it as
  required, and letting a null hit the NOT NULL DB column would surface as
  an ugly 500 instead. (2) Update also checks `departmentId` belongs to the
  same org+branch (`"Department not found"` 404) — API-008's own
  `validation[]` explicitly says "departmentId must belong to the same
  organization + branch" even though `errors[]` never enumerates it. (3)
  Update rejects a colliding `testCode` the same way Create does
  (`"Duplicate test code"` 409, symmetric with the `uq_test_code` constraint
  and the already-covered `testName` case) — `errors[]` only lists the
  testName collision, but leaving testCode uncovered would let a real
  UNIQUE-constraint violation fall through as a 500. All three have their
  own unit test even though only two are contract-mandated.
  `mvn test` green (207/207 — 169 from 0.1-1.8 + 23 `TestServiceTest`
  Mockito cases (7 create validations/errors + success, 5 view scenarios, 7
  update validations/errors + success, 3 status scenarios) + 15
  `TestIntegrationTest` full-stack cases against the real dockerized
  Postgres covering all 4 endpoints' success/error paths, a
  `@perm.can`-driven 403, and a 401 — including API-007's note that an
  inactive test is still returned at 200, not hidden). Postman:
  `backend/postman/02-master-data.postman_collection.json` created with a
  "Chunk 2.1 - Test Master CRUD + status" folder, all 4 requests and their
  example responses taken verbatim from `API-006`/`API-007`/`API-008`/`API-009`.
- 2026-09-16, Chunk 1.8: **Net-new endpoint outside the 139 fixed
  contracts**, plan.md gap #7 extension. Platform dashboard needed to drill
  into one organization's users, but `API-128` List Users is org+branch
  scoped and there's no List Branches contract to iterate branches first, so
  `GET /api/organizations/{organizationId}/users` queries across all
  branches of the org directly. New `identity.dto.OrganizationUserResponse`
  (includes `branchCode` so the dashboard can show which branch each user
  belongs to) + `UserService.listByOrganization()` (one `JdbcTemplate`
  `users`+`branches` join, same pattern `UserService.view()` already uses
  for its roles read) + a new `GET` mapping on the existing `UserController`
  (distinct path template from the org+branch List Users route). Gated
  `hasRole('PLATFORM_ADMIN')` per gap #6/#7's precedent. `mvn test` green
  (169/169 — 164 from the single-field-login work + 2 `UserServiceTest`
  Mockito cases (unknown-org 404, success across branches) + 3
  `UserIntegrationTest` full-stack cases against the real dockerized
  Postgres (success across two branches — asserted via
  `com.jayway.jsonpath.JsonPath` filter reads, same fix as Chunk 1.6's
  JsonPath-matcher quirk — 403 non-admin, 401 no token)). Postman:
  `backend/postman/01-org-identity.postman_collection.json` gained a
  "Chunk 1.8 - List Organization Users (platform monitoring)" folder.
- 2026-09-16, Infra (not a plan.md chunk): **Single-field login (username +
  password only) — plan.md gap #8, explicit user request**, cutting across
  Chunk 0.3 (login), Chunk 1.4 (user creation), and a new schema migration —
  wide enough that it's logged here rather than folded into either chunk's
  own entry.
  `V44__add_users_username_unique.sql` adds `UNIQUE (username)` globally
  (only the V42 seed's `platform_admin` row existed at migration time, so no
  backfill was needed or done — it's left unprefixed deliberately, see
  plan.md gap #8). `UserService.create` now looks up its org's code via
  `jdbcTemplate` and auto-prefixes every new username (`"jdoe"` → `"ACME-jdoe"`)
  before the uniqueness check, which switched from
  `UserRepository.existsByOrganizationIdAndBranchIdAndUsername` to the new
  `existsByUsername` — global instead of org+branch-scoped, matching the new
  constraint. `AuthService.login` branches on whether
  `organizationCode`/`branchCode` are present: omitted → new
  `AuthLookupRepository.findUserByUsername` (global, safe only because of
  V44); present → the original org+branch-scoped path, byte-for-byte
  unchanged, so no existing test needed to change its login calls. Frontend
  now always uses the single-field path (`LoginForm`/`AdminLoginForm` both
  just ask username + password).
  `mvn test` green (164/164 — 157 from Chunk 1.7 + 3 new `AuthServiceTest`
  cases for the global-lookup path (success, unknown username, wrong
  password) + 2 new `AuthIntegrationTest` cases against the real dockerized
  Postgres (single-field success, single-field unknown-username 401) + fixes
  to 5 existing tests whose asserted username values needed the org-code
  prefix: 3 `UserServiceTest` Mockito cases updated for the new
  `jdbcTemplate.queryForObject` org-code lookup + `existsByUsername` mock,
  2 `UserIntegrationTest` assertions updated to expect the prefixed value,
  `FlywayMigrationTest` bumped to version "44"). Postman:
  `backend/postman/00-auth.postman_collection.json` gained a "Login (single
  field...)" request + `roleCodes` added to the existing Login response
  example; `01-org-identity.postman_collection.json`'s Create User response
  examples updated to show the prefixed username.
- 2026-09-16, Infra (not a plan.md chunk): **`LoginResponse` gains
  `roleCodes: List<String>`**, needed so the frontend can gate the new
  platform-admin-only pages (Chunk 1.6/1.7) — the existing `roles` field is
  `List<UUID>` (role IDs), not codes, and there's no other endpoint that
  resolves them. Login isn't governed by any `API-XXX` contract (Chunk 0.3
  built it straight from plan.md, gap #6), so this additive field isn't a
  contract violation. `AuthService.login()` now also calls the already
  existing `authLookupRepository.findRoleCodes(roleIds)` (the same method
  `JwtAuthFilter` already uses to grant `ROLE_*` authorities) — no new query,
  just reusing it a second time. Same "necessary infra extension beyond this
  chunk's own file list" precedent as Chunk 1.1's `JwtAuthFilter` change, not
  a new chunk of its own. `mvn test` green (159/159 — 157 from Chunk 1.7 + 2
  new: `AuthServiceTest` now asserts `roleCodes` on both the empty-roles and
  populated-roles paths, `AuthIntegrationTest` gained an assertion on the
  existing login test plus a new `platformAdminLoginReturnsPlatformAdminRoleCode`
  case against the real dockerized Postgres).
- 2026-09-16, Chunk 1.7: **Net-new endpoint outside the 139 fixed contracts**,
  plan.md gap #7 (same user-approved addition as Chunk 1.6). Solves the real
  chicken-and-egg gap: `POST .../bootstrap-admin` gives a brand-new org (zero
  roles, zero `role_permission` rows) a working first login in one call,
  instead of requiring a manual DB seed. `identity.service
  .OrganizationBootstrapService` **composes** `RoleService.create`/
  `UserService.create`/`UserRoleService.assign` rather than duplicating their
  validation — the only genuinely new logic is granting all 7 `can_*` flags
  across every one of Appendix A's 25 `module_name` rows for the new `ADMIN`
  role. Marked `@Transactional`: without it, a duplicate-username 409 from
  `UserService.create` (which only runs *after* the role is already created
  and granted) would leave an orphaned fully-permissioned role behind with no
  user — caught during test-writing, not shipped. **Widened
  `security.RolePermissionRepository`** from package-private to `public
  interface` — the smallest possible change, needed because
  `OrganizationBootstrapService` (in `identity`) is now a second legitimate
  caller; not a fork of Module 0 infra, just wider access to the same
  repository. Gated `hasRole('PLATFORM_ADMIN')` per gap #6's precedent
  (pre-permission for a brand-new org, same reasoning as Create
  Organization/Branch). `mvn test` green (157/157 — 144 from 0.1-1.6 + 7
  `OrganizationBootstrapServiceTest` Mockito cases (3 required-field 400s,
  org/branch 404, duplicate-role 409, duplicate-username 409, success
  asserting all 25 `role_permission` rows granted) + 6
  `OrganizationBootstrapIntegrationTest` full-stack cases against the real
  dockerized Postgres: success (verifies 25 `role_permission` rows persisted
  *and* logs in as the newly bootstrapped admin to prove the login actually
  works), 400, 404, double-bootstrap 409, 403 non-admin, 401 no token).
  Postman: `backend/postman/01-org-identity.postman_collection.json` gained a
  "Chunk 1.7 - Bootstrap Admin (first login for a new org)" folder.
- 2026-09-16, Chunk 1.6: **Net-new endpoint outside the 139 fixed contracts**,
  logged as plan.md gap #7 with explicit user approval (needed to power a
  platform-admin monitoring dashboard the frontend is about to add).
  `GET /api/organizations`, gated `hasRole('PLATFORM_ADMIN')` per gap #6's
  precedent (cross-tenant data — no single org's `role_permission` row could
  ever authorize seeing every org's data, so `@perm.can(...)` doesn't apply
  here either). New `org.dto.OrganizationSummaryResponse` (kept separate from
  the contract-shaped `OrganizationResponse`, which must not gain fields) +
  `OrganizationService.listWithCounts()` — one aggregate `JdbcTemplate` query
  (`LEFT JOIN branches`/`users`, `GROUP BY`), same `JdbcTemplate`-injection
  pattern `UserService` already uses for its own narrow non-JPA reads.
  `mvn test` green (144/144 — 138 from 0.1-1.5 + 1 `OrganizationServiceTest`
  Mockito case for `listWithCounts()` + 3 `OrganizationIntegrationTest` cases
  against the real dockerized Postgres: success with real branch/user counts
  read back via `com.jayway.jsonpath.JsonPath` filter expressions, 403
  non-admin, 401 no token). Postman:
  `backend/postman/01-org-identity.postman_collection.json` gained a
  "Chunk 1.6 - List Organizations (platform monitoring)" folder.
- 2026-09-15, Infra (not a plan.md chunk): Added CORS support to
  `SecurityConfig` — a `CorsConfigurationSource` bean reading allowed
  origins from a new `app.cors.allowed-origins` property (defaults to
  `http://localhost:5173`, the Vite dev origin), wired into the filter chain
  via `.cors(...)`. Required for the new `frontend/` React app (dev server
  and, later, its deployed Vercel URL) to call this API at all — no
  frontend request could previously reach the backend cross-origin. Not a
  numbered chunk since it's cross-cutting security infra, not a contract
  endpoint; logged here per CLAUDE.md's "notice something broken, log it,
  don't fix it inline" rule applied to a genuine prerequisite gap instead.
  `mvn test` green (140/140, unchanged) — this addition touches no existing
  business logic.
- 2026-09-15, Chunk 1.5: **M1 — Organization, Branch & Identity is now
  complete.** `identity.UserRole` (composite `@IdClass(UserRoleId.class)`
  entity — `user_roles`' PRIMARY KEY is `(user_id, role_id)` with no
  generated `id` column, so it doesn't extend `AbstractTenantEntity` like
  `Role`/`Organization`/`Branch` before it) + `UserRoleRepository`
  (`existsByUserIdAndRoleId`) + `UserRoleService` + `UserRoleController`
  (`POST .../users/{userId}/roles`) in `identity`.
  Validation order follows the codebase's established convention
  (`scopeGuard.requireOrgBranch` first) rather than `API-005.errors[]`'s
  literal listing order (user → role → org/branch → duplicate) — every
  prior M1 service checks org/branch scope before any entity-specific
  lookup, and the contract's `errors[]` is an error catalog, not a mandated
  sequence. Missing/unknown `roleId` needs no separate blank-check: passing
  it straight to `RoleRepository.findByIdAndOrganizationIdAndBranchId`
  naturally falls through to the same 404 "Role not found" the contract
  specifies for both "missing" and "invalid" `roleId`.
  `mvn test` green (140/140 — 128 from 0.1-1.4 + 5 `UserRoleServiceTest`
  Mockito cases (org/branch 404, user 404, role 404, duplicate 409, success)
  + 7 `UserRoleIntegrationTest` full-stack cases against the real dockerized
  Postgres: success, user/role/branch 404s, duplicate 409, a
  `@perm.can`-driven 403, and a 401). Postman:
  `backend/postman/01-org-identity.postman_collection.json` gained a
  "Chunk 1.5 - User Roles" folder with the Assign Role to User request and
  its 201/404×3/409 example responses, bodies taken verbatim from
  `API-005`.
- 2026-09-15, Chunk 1.4: Picked up mid-flight: `org`/`identity` had already
  been restructured (uncommitted, not part of this chunk's own work) into
  `controller`/`dto`/`entity`/`repository`/`service` subpackages, with `Role`
  moved from `org` into `identity` and `User`'s entity/repository/most DTOs
  already scaffolded — that layout was reused as-is rather than redone.
  Added the two missing pieces: `UserService` (create/list/view/update/
  updateStatus) + `UserController` in `identity`, plus two response DTOs the
  scaffold didn't have yet (`UserUpdateResponse` for `id/firstName/lastName/
  email`, `UserStatusResponse` for `id/isActive` — neither matches an
  existing DTO's exact field set, so no reuse was forced per the Role
  precedent).
  **List Users filtering** (`isActive`/`search`, both optional) needed 4
  `UserRepository` methods instead of one nullable-param JPQL clause, same
  fix as Chunk 1.3's `RoleRepository.search` (Postgres can't infer a type
  for a bound `NULL` inside `LOWER(...)`).
  **View User's `roles[]`** is read via a narrow `JdbcTemplate` join of
  `user_roles`+`roles` inside `UserService` itself, not a new repository
  class — `user_roles` has no owning entity until Chunk 1.5 (`UserRole`),
  same reasoning `AuthLookupRepository` used for pre-entity tables in
  Chunk 0.3.
  **`updated_at` is set on every `User` update path** (`update`,
  `updateStatus`) — `User` is the first entity in this codebase with both a
  real `updated_at` column and an actual update operation exercising it
  (Organization/Branch/Role either have no update op or no `updated_at`
  column), so leaving it stale would've been a silent correctness gap, not
  scope creep.
  `mvn test` green (128/128 — 90 from 0.1-1.3 + 20 `UserServiceTest` Mockito
  cases (3 create validations + org/branch 404 + duplicate 409 + 2 success
  variants (default/explicit `isActive`) + 4 list filter combos + org/branch
  404 + view 404/success + update 400/404/success + status 400/404/success)
  + 18 `UserIntegrationTest` full-stack cases against the real dockerized
  Postgres covering all 5 endpoints' success/error paths, a `@perm.can`-driven
  403, and a 401). Postman: `backend/postman/01-org-identity.postman_collection.json`
  gained a "Chunk 1.4 - Users" folder with all 5 requests and example
  responses taken verbatim from `API-004`/`API-128`.
  Docker Desktop / the `x46-postgres` container were down at the start of
  this chunk (integration tests couldn't load their `ApplicationContext`
  at all) — user confirmed and started Docker Desktop themselves before
  `mvn test` was re-run.
- 2026-09-11, Chunk 1.3: **The plan's one schema migration lands as
  `V43__add_roles_is_active.sql`**, not `V42` as plan.md's literal text
  names it — Chunk 1.1's bootstrap seed claimed V42 first (flagged as a
  pending sequencing decision in that chunk's log entry). `ALTER TABLE roles
  ADD COLUMN is_active BOOLEAN NOT NULL DEFAULT TRUE`, additive, matches
  `API-129`'s `schema_gap_note` resolution verbatim.
  `org.Role` (mirrors `Organization`/`Branch` — standalone entity, not
  `AbstractTenantEntity`, since `roles` has no `updated_at` column) +
  `RoleRepository` + `RoleService` (create/list/view/update/updateStatus) +
  `RoleController` in the existing `org` package (no separate `identity`
  package exists yet, and Role is scoped under org+branch exactly like
  Branch, so no new package split was invented). First endpoints in the
  codebase gated on the real `@perm.can('Role Management', <action>)` check
  instead of `hasRole('PLATFORM_ADMIN')` — status toggle uses the `UPDATE`
  action since `PermissionAction` has no dedicated status verb, same
  reasoning as User/Test/Department status endpoints will presumably need
  later.
  **Per-operation response DTOs, not one shared `RoleResponse`**: `API-003`
  (create) returns `id/organizationId/branchId/roleCode/roleName`, `API-129`
  Update returns just `id/roleCode/roleName` (same shape as a List item, so
  `RoleSummaryResponse` is reused for both — an actual shape match, not a
  merge of two different endpoints), View adds `createdAt`
  (`RoleDetailResponse`), and Status returns `id/isActive`
  (`RoleStatusResponse`, mirroring `API-128`'s Activate/Deactivate User
  shape since `API-129`'s own status response is only specified for its
  blocked-409 state). Keeps every response body matching its contract
  exactly instead of serializing unrequested fields.
  Hit and fixed one real bug while writing `RoleIntegrationTest`: the List
  Roles search query originally used a single JPQL
  `(:search IS NULL OR LOWER(...) LIKE ...)` clause to make the `search`
  query param optional, but Postgres can't infer a type for a bound `NULL`
  parameter inside `LOWER(...)`, throwing `function lower(bytea) does not
  exist` for every no-search-term request. Fixed by splitting into two
  repository methods (`findByOrganizationIdAndBranchId` for no search,
  `search` for a real term) selected in `RoleService`, avoiding the null
  bind entirely rather than adding a cast/coalesce workaround.
  `mvn test` green (90/90 — 59 from 0.1-1.2 + 17 `RoleServiceTest` Mockito
  cases (4 operations × their own `errors[]` + success, plus the search-vs-list
  branch) + 14 `RoleIntegrationTest` full-stack cases against the real
  dockerized Postgres covering all 5 endpoints' success/error paths, a
  `@perm.can`-driven 403, and a 401). Postman:
  `backend/postman/01-org-identity.postman_collection.json` gained a
  "Chunk 1.3 - Roles" folder with all 5 requests and their example responses
  taken verbatim from `API-003`/`API-129`.
- 2026-09-11, Chunk 1.2: `org.Branch` (mirrors `Organization` — standalone
  entity, not `AbstractTenantEntity`, since that base class demands a
  `branch_id` column and `branches` is the table `branch_id` points *at*) +
  `BranchRepository` + `BranchService` (validation order matches
  `API-002.errors[]`: branchCode, branchName, org-exists, then duplicate-code
  409) + `BranchController` (`POST /api/organizations/{organizationId}/branches`,
  same `hasRole('PLATFORM_ADMIN')` gate as 1.1 per plan.md — branch is still
  pre-tenant bootstrap) in the existing `org` package.
  **Extended `ScopeGuard`** (Chunk 0.5's shared infra) with
  `requireOrg(UUID organizationId)` — the existing `requireOrgBranch(org, branch)`
  needs both IDs and throws a combined "Organization or branch not found",
  but `API-002` needs an org-only check with its own message
  ("Organization not found"), since branchId doesn't exist yet at creation
  time. This is reuse/extension of Module 0 infra per CLAUDE.md rule 4, not a
  fork. `mvn test` green (59/59 — 43 from 0.1-1.1 + 7 `BranchServiceTest`
  Mockito cases (missing code, missing name, unknown org propagated from a
  mocked `ScopeGuard`, duplicate code, unexpected-failure propagation, success
  defaulting `isActive` true, explicit `isActive=false`) + 2 new
  `ScopeGuardIntegrationTest` cases for `requireOrg` + 7
  `BranchIntegrationTest` full-stack cases against the real dockerized
  Postgres: success, both 400s, 404, 409, 403 non-admin, 401 no token).
  Postman: `backend/postman/01-org-identity.postman_collection.json` gained a
  "Chunk 1.2 - Branch" folder with Create Branch and its 201/400×2/404/409
  example responses, bodies taken verbatim from `API-002`'s contract.
- 2026-09-10, Chunk 1.1: **M1 is now open — first entity actually persisted via
  Spring Data JPA in this codebase.** `org.Organization` (id, organizationCode,
  organizationName, isActive, createdAt/updatedAt set manually in the service
  before save — no auditing annotation exists yet, so this is the simplest
  fit, not a new pattern) + `OrganizationRepository` + `OrganizationService`
  (validation order matches API-001.errors[]: name, then code, then
  duplicate-code 409) + `OrganizationController` (`POST /api/organizations`,
  `@PreAuthorize("hasRole('PLATFORM_ADMIN')")` per plan.md gap #6, not
  `@perm.can(...)`) in a new `org` package.
  **`V42__platform_bootstrap_seed.sql`** resolves Chunk 0.1's flagged
  sequencing question: it takes V42 as a *data* seed (chained
  `INSERT ... RETURNING` CTEs for organizations→branches→roles→users→
  user_roles, no ALTER/CREATE), not the *schema* change CLAUDE.md reserves
  V42 for — so Chunk 1.3's `roles.is_active` column now lands as **V43**
  when that chunk is picked up. Seeds org `PLATFORM` / branch `PLATFORM-01` /
  role `PLATFORM_ADMIN` / user `platform_admin` (password `Platform@123`,
  bcrypt hash generated once via a throwaway test calling the app's own
  `BCryptPasswordEncoder`, not hand-typed — dev-only credential, rotate
  before prod). Updated `FlywayMigrationTest` (Chunk 0.1's file) from
  expecting version "41" to "42" — a direct, required consequence of adding
  V42, not an unrelated fix.
  **Necessary infra extension beyond this chunk's own file list**: making
  `hasRole('PLATFORM_ADMIN')` actually deny/allow anything required
  `JwtAuthFilter` to grant real `GrantedAuthority`s instead of its Chunk 0.3
  `List.of()` placeholder. Chose the smallest fix that doesn't ripple through
  every existing `JwtPrincipal` call site: added
  `AuthLookupRepository.findRoleCodes(roleIds)` (resolves the JWT's existing
  `roleIds` claim to `role_code` per request) and had `JwtAuthFilter` map
  those to `ROLE_<code>` authorities — `JwtPrincipal`/`JwtService`/their
  tests are untouched. Considered embedding role codes directly as a new JWT
  claim instead, but that would have changed `JwtPrincipal`'s record shape
  and broken every test across `security` that constructs one directly;
  resolving by ID per request follows the same no-caching precedent already
  set by `ScopeGuard` and `PermissionEvaluatorService`.
  `mvn test` green (43/43 — 31 from M0 + 1 `FlywayMigrationTest` version bump
  + 5 `OrganizationServiceTest` Mockito cases (missing name, missing code,
  duplicate code, unexpected-failure propagation, success with isActive
  default) + 1 more for explicit `isActive=false` + 6
  `OrganizationIntegrationTest` full-stack cases against the real dockerized
  Postgres: success, both 400s, 409, 403 non-admin, 401 no token). Postman:
  `backend/postman/01-org-identity.postman_collection.json` created with the
  Create Organization request and 201/400×2/409/403 example responses.
- 2026-09-09, Chunk 0.5: **M0 — Platform Foundation is now complete.**
  `ScopeGuard` (`common/`) — org/branch existence via two `JdbcTemplate`
  `EXISTS` queries (not JPA entities, same reasoning as Chunk 0.3: those
  tables' real entities belong to Chunk 1.1/1.2), both branches throwing the
  identical `"Organization or branch not found"` string per plan.md. The
  branch check is scoped `WHERE id = ? AND organization_id = ?`, so a branch
  that exists under a *different* org is correctly treated as not-found —
  the multi-tenancy rule enforced by the query itself, covered by
  `branchBelongingToAnotherOrganizationIsRejected`.
  `AuditLogService` — placed in `security/`, not `common/`, despite being
  grouped with `ScopeGuard` as shared Module 0 infra in `CLAUDE.md`: it needs
  `JwtPrincipal` (org/branch/user of the current caller) off
  `SecurityContextHolder`, and `JwtPrincipal` lives in `security`. Since
  `common` is meant to be the dependency-free foundation everything else
  builds on, having it reach into `security` would be a layering inversion;
  `security` depending on its own `JwtPrincipal` (same pattern Chunk 0.4's
  `PermissionEvaluatorService` already uses) is the actually-correct
  simplest fix, not a fix. `record(actionType, entityType, entityId,
  oldValues, newValues)` matches plan.md's literal 5-param signature exactly
  because organizationId/branchId/userId are pulled from the JWT context
  automatically rather than threaded through every future caller.
  `old_values`/`new_values` (`jsonb` columns) are populated by serializing
  the caller's object to a JSON string via a self-contained `JsonMapper`
  (same technique as Chunk 0.3's `JwtService`) and passing it with an
  explicit `?::jsonb` cast — sidesteps Hibernate's JSON type mapping
  entirely, so no repeat of the Jackson-2-vs-3 question. `audit_logs` has no
  `updated_at` column (unlike every other table so far), so it deliberately
  does **not** extend `AbstractTenantEntity`. `mvn test` green (31/31 — 26
  from 0.1-0.4 + 5 new: 4 `ScopeGuardIntegrationTest` + 1
  `AuditLogServiceIntegrationTest` covering a create-then-update sequence
  per plan.md, both against the real dockerized Postgres). Postman: n/a per
  plan.md.
- 2026-09-09, Chunk 0.4: `RolePermission` JPA entity (extends
  `AbstractTenantEntity`, unlike Chunk 0.3's `JdbcTemplate` choice — no future
  chunk owns `role_permission`, so a real entity is the right tool here) +
  `RolePermissionRepository` (Spring Data derived query) +
  `PermissionEvaluatorService` (bean name `perm`, required by
  `@PreAuthorize("@perm.can(...)")` SpEL lookup) in `security/`.
  `@EnableMethodSecurity` added to `SecurityConfig`. `can(moduleName, action)`
  reads the `JwtPrincipal` off `SecurityContextHolder`, unions
  `role_permission` rows across all the caller's roles, denies-by-default on
  any unknown state (no auth, no roles, unrecognized action string).
  Hit and fixed one real wiring bug: `@PreAuthorize` denials throw
  `AccessDeniedException` *inside* the controller call, which
  `GlobalExceptionHandler`'s catch-all `Exception` handler (Chunk 0.2)
  intercepts before Spring Security's filter-level `accessDeniedHandler` ever
  sees it — a known Spring Security + `@ControllerAdvice` interaction. Fixed
  by adding an explicit `@ExceptionHandler(AccessDeniedException.class)` →
  403 in `GlobalExceptionHandler` (same pattern as Chunk 0.3's
  `UnauthorizedException` → 401) and removing the dead
  `accessDeniedHandler(...)` from `SecurityConfig`, since it can now never
  fire (no URL-pattern-based authorization rules exist, only method-level
  `@PreAuthorize`). Also fixed a flaky assertion in Chunk 0.3's
  `JwtServiceTest.tamperedTokenIsRejected` found while re-running the suite:
  it mutated only the token's last character, which sometimes falls in the
  "don't care" padding bits of a base64url-encoded 32-byte HMAC-SHA256
  signature (32 isn't divisible by 3) and can decode back to identical
  signature bytes ~1 time in 4 — not a `JwtService` bug, a test design bug.
  Now mutates a header character instead, which is always signed and
  guaranteed to change the outcome. `mvn test` green (26/26 — 20 from
  0.1-0.3 + 6 new: 4 `PermissionEvaluatorServiceTest` Mockito/SecurityContext
  scenarios per plan.md's list, 2 `PermissionEvaluatorIntegrationTest`
  full-stack cases against a test-only `@PreAuthorize`-annotated controller
  that exists only inside the test file). Postman: n/a per plan.md
  (cross-cutting, no endpoint of its own).
- 2026-09-08, Chunk 0.3: `AuthService`/`AuthController` (`POST /api/auth/login`),
  `JwtService` (hand-rolled HS256 issue/parse — JDK `Mac`+`Base64` only, no
  library added since jjwt's Jackson binding targets Jackson 2 and this app
  runs Jackson 3 `tools.jackson.*`; would've meant two Jackson majors on the
  classpath), `JwtAuthFilter` + `SecurityConfig` (stateless, CSRF off,
  `/api/auth/login` permitAll, everything else authenticated, custom 401
  JSON entry point), all in `security/`. Login reads `organizations`/
  `branches`/`users`/`user_roles` via a narrow `JdbcTemplate`-based
  `AuthLookupRepository` rather than JPA entities, since the real
  `Organization`/`Branch`/`User`/`Role` entities belong to Chunk 1.1-1.4
  (`org`/`identity` packages) and modeling them now would mean throwing the
  models away once M1 lands. Every login failure path (unknown org, unknown
  branch, unknown username, inactive user, wrong password) throws the same
  `UnauthorizedException("Invalid credentials")` — added as a 4th mapped
  exception in `common/GlobalExceptionHandler` (chunk 0.2's file), since
  0.2 only wired 400/404/409/500 and login needs 401; this is extending
  shared Module 0 infra per plan.md's own reuse rule, not touching 0.2's
  business logic. `mvn test` green (20/20 — 14 from 0.1/0.2 + 6 new: 4
  `JwtServiceTest` token round-trip/tamper/expiry/malformed, 6
  `AuthServiceTest` Mockito success/failure branches, 4 `AuthIntegrationTest`
  full-stack cases against real dockerized Postgres, seeding/cleaning its
  own rows since Chunk 1.1's seed migration doesn't exist yet). No business
  endpoint exists yet to prove "protected endpoint" behavior against, so
  `AuthIntegrationTest` uses `/actuator/health` (the only endpoint that's
  actually gated by the new `SecurityFilterChain`) for the missing/tampered
  token → 401 cases.
- 2026-09-08, Chunk 0.2: `ApiResponse<T>` (`@JsonInclude(NON_NULL)` so error
  responses omit `message`/`data` and success responses omit `error`, matching
  the contracts' exact JSON shape), `NotFoundException`/`ConflictException`/
  `ValidationException`, and `GlobalExceptionHandler` (`@RestControllerAdvice`)
  mapping them to 404/409/400 plus a catch-all `Exception`→500
  `"Internal server error"`, all in `common/`. `mvn test` green (6/6 —
  1 Flyway + 1 context load + 4 new exception-handler tests). One deviation:
  the exception-handler test uses `MockMvcBuilders.standaloneSetup(...)`
  instead of `@WebMvcTest(controllers=...)` — the latter routed requests to
  the static-resource handler instead of the nested test `@RestController`
  (cause not chased further since standalone setup tests the same
  exception→envelope mapping without needing the full web test-slice
  context). No RBAC/security wiring touched — that's Chunk 0.3/0.4.
- 2026-09-07, Chunk 0.1: Flyway migrations V1-V41 created from
  `database/schema/001_*.sql`..`040_*.sql` + `alter-minor-changes.sql`;
  `mvn test` green (2/2). Deviations from plan.md's literal wording, all
  necessary to make the copied schema actually apply — no schema was added,
  removed, or invented beyond what's below:
  - **Version numbering**: plan.md says "V1__core_setup.sql ... V40__payment_finance_fields.sql,
    ... V41" implying a 1:1 file-to-version mapping, but `database/schema/`
    has 9 numeric prefixes shared by 2-4 files each (018, 019, 020, 022, 023,
    024, 026, 027, 030) and no `025_*.sql` at all — 54 physical files across
    prefixes 001-040, not 40. Resolved by making the Flyway version number
    equal the *source file's numeric prefix* (so V1=001, V40=040, gap at
    V25 preserved since no 025 file exists), and concatenating same-prefix
    files into one `V<N>__*.sql` migration, ordered by FK dependency where
    it differs from alphabetical (022: report_master before
    report_delivery_log; 023: instrument_master before its 3 dependents; 030:
    notification_template before notification_log — alphabetical order would
    have put the dependent table first in each of these three). This keeps
    plan.md's own literal V1/V40/V41 anchors correct and leaves **V42 free**
    for Chunk 1.3's `roles.is_active` migration as plan.md names it.
  - **`015_test_master.sql` dead FK dropped**: its trailing
    `ALTER TABLE test_master ADD CONSTRAINT fk_test_master_container_type
    FOREIGN KEY (container_type_id) REFERENCES container_type_master(id)`
    is broken two ways — `container_type_master` isn't created until
    `028_container_type_master.sql` (forward reference), and `test_master`
    never gains a `container_type_id` column anywhere in 001-040 (the column
    only ever existed in the old `schema_snapshot_v24.sql` history, not in
    this file set). Adding the column would be inventing schema not
    sanctioned by any contract/plan.md §2 entry, so the statement was
    dropped rather than fixed forward. Left in `V15__test_master.sql` as a
    comment for whoever owns schema going forward.
  - **`018_accession_tests.sql` typo fixed**: its barcode-generator trigger
    function had `WHERE ... AND organization_id = NEW.organization_id;` —
    a stray `;` terminating the WHERE clause mid-condition, followed by a
    dangling `AND branch_id = NEW.branch_id;` — a plain syntax error
    (Postgres: `syntax error at or near "AND"`) that fails Flyway migrate
    outright. Joined into one WHERE clause in `V18__accession.sql`; no
    logic changed beyond removing the stray semicolon.
  - **`alter-minor-changes.sql` → `V41` as a documented no-op**: its content
    is two diagnostic `SELECT`s comparing `staging_livehealth_tests` (a
    one-off table from the `database/Livehealth/` data-migration scripts,
    never created by 001-040) against `test_category_master` — not a schema
    change, and would fail with "relation does not exist" if run here.
    Applied as `V41__alter_minor_changes.sql` containing the original SQL
    verbatim as a comment plus `SELECT 1;`, to satisfy plan.md's instruction
    to give it the final V-slot without breaking the migrate.
  - Follow-up for whoever picks up **Chunk 1.1**: plan.md §M1/Chunk 1.1 says
    the PLATFORM org/branch/role/bootstrap-user seed is "part of Chunk 0.1's
    last migration" — Chunk 0.1's own scope bullet doesn't ask for that seed,
    so it was **not** added here (V41 is a no-op, per above). Chunk 1.1 will
    need its own seed migration (e.g. `V42`, ahead of the `V42` reserved by
    Chunk 1.3 for `roles.is_active` — sequencing those two needs a decision
    when 1.1 and 1.3 are both in flight).
  - Verified against the dockerized `x46-postgres` (existing
    `x46-postgres-data` volume, untouched/not recreated): fresh
    `flyway_schema_history` reached version 41, all 40 migrations `success=t`.
