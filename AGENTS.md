# X46 LIMS — Agent Instructions

Standing instructions for any automated coding agent (Claude Code, a
subagent, a CI bot) working in this repository. These apply automatically —
no need to paste them per request. Pairs with `CLAUDE.md` (coding
standards/architecture constraints), `backend/plan.md` (the chunk
blueprint), `backend/progress.md` (the tracker), and
`backend/CHUNK_PROMPT.md` (the exact prompt used to kick off one chunk).

## Before starting any chunk

1. Read `backend/plan.md` and find the chunk by ID.
2. Read `backend/progress.md` and confirm every chunk this one depends on is
   `✅`. If not, **stop and report the blocker** instead of implementing out
   of order.
3. Read every `API-XXX_*.json` contract file the chunk references, in full,
   from `database/api_contracts_json/`. That JSON is the source of truth for
   fields, validation, and the error catalog — not `plan.md`'s summary of it.

## While implementing

- **Constrain edits strictly to the requested chunk.** Touch only the files
  that chunk's scope names in `plan.md`. If you notice something broken or
  missing in an earlier chunk, do not fix it inline — add a line to
  `progress.md`'s Log describing it and keep going.
- Reuse Module 0 infrastructure (`ApiResponse`, `GlobalExceptionHandler`,
  `ScopeGuard`, `PermissionEvaluatorService`, `AuditLogService`) — never fork
  or duplicate it.
- Follow `CLAUDE.md`'s architecture constraints and coding rules without
  re-deriving them from scratch.

## Before reporting completion

1. **Run and verify unit tests.** From `backend/`, run `mvn test` (or
   `mvn clean compile` first if new files were added). A chunk is not
   complete until this is green. Paste the final summary line
   (`Tests run: X, Failures: 0, Errors: 0`). A failing test gets fixed —
   never disabled, skipped, or deleted to force a green build.
2. **Postman payload.** For every endpoint the chunk added or changed,
   produce a Postman v2.1 request item: method, `{{baseUrl}}` URL with
   path/query params as collection variables, `Authorization: Bearer
   {{token}}` header, request body from the contract's `request.body`, and a
   saved example response from `success.response`. Add it to
   `backend/postman/<module-slug>.postman_collection.json` (create it with a
   minimal v2.1 skeleton — `info` + `item[]` — if it doesn't exist yet).
   **Show the exact JSON snippet added** — "updated Postman" is not
   sufficient.
3. **Update `progress.md`.** Flip the chunk's Status/Tests/Postman columns
   and append one dated line to the Log noting anything a future chunk needs
   to know (deviations from `plan.md`, follow-ups filed, blockers hit).
   **Show the diff.**

## Every response for a chunk must include, in this order

1. What was built — files touched, one line each.
2. The `mvn test` summary line.
3. The Postman JSON snippet added.
4. The `progress.md` diff.

## Hard stops — do not proceed, ask the user instead

- The chunk's dependency isn't `✅` in `progress.md`.
- The contract carries a `database_gap`/`requires_confirmation` note with no
  resolution recorded in `plan.md` § 2 (Known gaps).
- Implementing the chunk would require a schema change not already listed in
  `plan.md` § 2.
- Any step that would drop or recreate the `x46-postgres-data` Docker volume.

## Scope discipline

One chunk per work session. If asked to "do the next few chunks," implement
one, report per the format above, and stop — don't silently chain multiple
chunks in a single pass. Each chunk needs its own implement → test →
Postman → progress.md cycle so a failure is traceable to exactly one chunk.
