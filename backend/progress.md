# X46 LIMS Backend — Progress Tracker

Update this file at the end of every chunk (the chunk execution prompt in
`CHUNK_PROMPT.md` requires it). One row per chunk from `plan.md`. Do not
reopen a chunk marked ✅ — file a new chunk instead if something needs to change.

Status legend: `⬜ not started` · `🔄 in progress` · `✅ done` · `🚧 blocked`

## M0 — Platform Foundation

| Chunk | Title | Status | Tests | Postman |
|---|---|---|---|---|
| 0.1 | Flyway baseline + entity base classes | ⬜ | ⬜ | n/a |
| 0.2 | API response envelope + exception handling | ⬜ | ⬜ | n/a |
| 0.3 | JWT auth core (`/api/auth/login`) | ⬜ | ⬜ | ⬜ |
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

- *(none yet)*
