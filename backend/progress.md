# X46 LIMS Backend — Progress Tracker

Update this file at the end of every chunk (the chunk execution prompt in
`CHUNK_PROMPT.md` requires it). One row per chunk from `plan.md`. Do not
reopen a chunk marked ✅ — file a new chunk instead if something needs to change.

Status legend: `⬜ not started` · `🔄 in progress` · `✅ done` · `🚧 blocked`

## M0 — Platform Foundation

| Chunk | Title | Status | Tests | Postman |
|---|---|---|---|---|
| 0.1 | Flyway baseline + entity base classes | ✅ | ✅ | n/a |
| 0.2 | API response envelope + exception handling | ✅ | ✅ | n/a |
| 0.3 | JWT auth core (`/api/auth/login`) | ✅ | ✅ | ✅ |
| 0.4 | RBAC permission evaluator | ⬜ | ⬜ | n/a |
| 0.5 | Scope guard + audit log writer | ⬜ | ⬜ | n/a |

## M1 — Organization, Branch & Identity

| Chunk | Title | Status | Tests | Postman |
|---|---|---|---|---|
| 1.1 | Organization + bootstrap platform role | ⬜ | ⬜ | ⬜ |
| 1.2 | Branch | ⬜ | ⬜ | ⬜ |
| 1.3 | Roles (+ `roles.is_active` migration) | ⬜ | ⬜ | ⬜ |
| 1.4 | Users | ⬜ | ⬜ | ⬜ |
| 1.5 | User-Role assignment | ⬜ | ⬜ | ⬜ |

## M2 — Master Data

| Chunk | Title | Status | Tests | Postman |
|---|---|---|---|---|
| 2.1 | Test Master CRUD + status | ⬜ | ⬜ | ⬜ |
| 2.2 | Test list & search | ⬜ | ⬜ | ⬜ |
| 2.3 | Department CRUD + status | ⬜ | ⬜ | ⬜ |
| 2.4 | Parameters & Reference Ranges | ⬜ | ⬜ | ⬜ |
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
