# X46 LIMS — Operational Guidelines

Spring Boot monorepo backend for X46 LIMS (Lab Information Management
System). This file defines coding standards, architecture constraints, and
rules for LLM code generation in this repo. Pairs with `AGENTS.md` (agent
execution instructions) and `backend/CHUNK_PROMPT.md` (the per-chunk prompt).

## Where things live

| What | Where |
|---|---|
| Implementation blueprint (13 modules, 53 chunks, all 139 API contracts) | `backend/plan.md` |
| Progress tracker | `backend/progress.md` |
| Reusable per-chunk execution prompt | `backend/CHUNK_PROMPT.md` |
| Agent standing instructions | `AGENTS.md` |
| API contracts — source of truth for request/response/validation/errors | `database/api_contracts_json/API-XXX_*.json` |
| DB schema — source of truth for tables/columns/constraints | `database/schema/*.sql`, changelog `database/schema/CHANGELOG.md` |
| Postman collections (module-wise, grown chunk by chunk) | `backend/postman/*.postman_collection.json` |
| Docker Postgres (volume-mounted) | `docker-compose.yml` (`x46-postgres-data`) |

## Architecture constraints

- **Layering:** Controller → Service → Repository → PostgreSQL. Controllers
  never call repositories directly; services never build HTTP responses.
- **Response envelope:** every endpoint returns `ApiResponse<T>` (`success`,
  `message`/`error`, `data`) — built once in Chunk 0.2, reused everywhere.
  Do not invent a second envelope shape.
- **Multi-tenancy:** org/branch scoping goes through `ScopeGuard` (Chunk 0.5)
  on every scoped endpoint. A row that exists but belongs to another
  org/branch returns `404`, never `403` — matches the contracts' convention.
- **AuthN:** stateless JWT only. No sessions, no cookies.
- **AuthZ:** `role_permission` via `@PreAuthorize("@perm.can('<ModuleName>','<ACTION>')")`.
  `module_name` values are exactly the contract `"module"` strings (see
  `backend/plan.md` Appendix A) — never invent a new taxonomy. The only
  endpoints gated on a hardcoded role instead of `@perm.can(...)` are the two
  bootstrap endpoints in Chunk 1.1/1.2 (`PLATFORM_ADMIN`), because no
  organization exists yet to key permissions on.
- **Schema changes go through Flyway only.** `spring.jpa.hibernate.ddl-auto=validate` —
  Hibernate never creates or alters tables. Migrations live in
  `backend/src/main/resources/db/migration/`. The only schema change the
  whole plan calls for is `roles.is_active` (Chunk 1.3, `V42__`) — do not add
  others without updating `backend/plan.md` § 2 first.
- **Volume persistence:** Postgres always runs via the existing
  `docker-compose.yml` (`x46-postgres-data` named volume). Never substitute
  an in-memory/H2 database for anything beyond a throwaway local experiment —
  integration tests must run against the real dockerized instance so
  volume-mounted persistence is actually exercised, not assumed.

## Rules for LLM code generation

1. **Strict scope enforcement.** Implement exactly one chunk from
   `backend/plan.md` at a time. Touch only the files that chunk's scope
   names. Notice something broken in an earlier chunk? Log it in
   `progress.md`'s Log, don't fix it inline.
2. **Contracts are the source of truth.** Read the referenced
   `API-XXX_*.json` file(s) in full before writing a DTO. Never invent a
   request/response field the contract doesn't have.
3. **No speculative schema.** If a contract carries a
   `database_gap`/`schema_gap_note`/`requires_confirmation`, follow the
   resolution already recorded in `backend/plan.md` § 2 (Known gaps). Never
   add a table or column to solve it unilaterally.
4. **No unrequested abstractions.** No interface with one implementation, no
   generic repository wrapper beyond Spring Data JPA's own, no config value
   that never changes. Reuse the Module 0 infrastructure (`ApiResponse`,
   `GlobalExceptionHandler`, `ScopeGuard`, `PermissionEvaluatorService`,
   `AuditLogService`) — never fork or re-implement it per module.
5. **Test-driven — tests before build succeeds.** A chunk is not done until
   its unit tests exist, pass, and `mvn test` is green. Never report a chunk
   complete without pasting the final test summary line.
6. **Postman on every chunk.** Every completed chunk updates its module's
   `backend/postman/<module-slug>.postman_collection.json` with the new
   endpoint(s); example bodies come from the contract's
   `success.response`/`request.body`, not invented.
7. **Don't merge contracts for convenience.** Two endpoints that look
   redundant (e.g. `API-057` Create Payment vs `API-060` Payment Against
   Bill) are still built exactly as their contracts specify, separately.

## Testing rules

- **Unit tests:** service-layer logic — one test per contract `errors[]`
  entry plus the success path (already enumerated per chunk in
  `backend/plan.md`).
- **Integration tests:** `@SpringBootTest` against the dockerized Postgres
  for anything touching Flyway migrations or repositories.
- **Security tests:** every RBAC-guarded endpoint gets at least one
  "forbidden" test (authenticated, wrong/missing permission) and one
  "unauthenticated" test (missing/invalid JWT).
- Run `mvn test` from `backend/` before declaring any chunk done. A red test
  blocks the chunk — do not comment it out, delete it, or mark it
  `@Disabled` to force a green build.

## What not to do

- Don't add endpoints, fields, or modules not present in
  `database/api_contracts_json/`.
- Don't bypass `@PreAuthorize` or the JWT filter "temporarily" for
  convenience during development.
- Don't let Hibernate auto-create or alter tables — Flyway owns the schema.
- Don't run `docker compose down -v` (or anything else that drops the
  `x46-postgres-data` volume) without explicit user confirmation.
- Don't chain multiple chunks in one pass — each chunk gets its own
  implement → test → Postman → progress.md cycle so a failure is traceable
  to a single chunk.
