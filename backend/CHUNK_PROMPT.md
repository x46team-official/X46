# Reusable chunk execution prompt

Copy this into a new request (with `<CHUNK_ID>` filled in) to implement one
chunk. One chunk per request — do not batch chunks, that's what defeats the
context-window-safe chunking in the first place.

---

```
Implement chunk <CHUNK_ID> of the X46 LIMS backend, and only that chunk.

1. Read backend/plan.md and find chunk <CHUNK_ID>. Read backend/progress.md
   to confirm every chunk it depends on is already ✅ — if not, stop and say
   so instead of implementing out of order.

2. Read every API-XXX contract file the chunk references, in full, from
   database/api_contracts_json/. That JSON is the source of truth for
   request/response fields, validation rules, and the error catalog — do not
   invent fields plan.md didn't mention and the contract doesn't have.

3. Implement only this chunk's scope:
   - Entities/DTOs/repositories, service logic (including every RBAC
     @PreAuthorize check the chunk specifies), controller endpoints.
   - Reuse what backend/plan.md's M0 chunks already built (ApiResponse
     envelope, GlobalExceptionHandler, ScopeGuard, PermissionEvaluatorService,
     AuditLogService) — do not re-implement or fork them.
   - Do not touch files outside this chunk's scope. Do not "improve" earlier
     chunks while you're in there — file it as a note in progress.md's Log
     instead and move on.
   - If the contract documents a schema gap or asks for confirmation
     (`database_gap`, `schema_gap_note`, `requires_confirmation` fields),
     follow plan.md § 2's resolution for it. Don't invent a schema change
     that isn't already spelled out there.

4. Write unit tests for every scenario in the chunk's "Unit test
   requirements" list in plan.md (which maps 1:1 to each contract's
   `errors[]` plus its success path). Run `mvn test` from backend/ and get a
   clean pass before declaring the chunk done — paste the final test summary
   line.

5. Produce the Postman payload for this chunk: for each endpoint, a
   Postman v2.1 request item (method, URL with `{{baseUrl}}` and path/query
   params as collection variables, headers including
   `Authorization: Bearer {{token}}`, body from the contract's
   `request.body`, and a saved example response from `success.response`).
   Add these items to backend/postman/<file-named-in-plan.md>, creating the
   collection file (minimal v2.1 skeleton: info + item[]) if it doesn't
   exist yet, folder-per-chunk inside it. Show me the diff/snippet you added.

6. Update backend/progress.md: flip this chunk's Status/Tests/Postman
   columns, and add one line to the Log with today's date, the chunk id, and
   anything a future chunk needs to know (deviations, follow-ups filed).

Report back: what you built, the mvn test summary, and the progress.md diff.
```
