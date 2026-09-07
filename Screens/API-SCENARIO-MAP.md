# API scenario → screen mapping

One row per requested API test scenario. `Status` is one of:

- **covered** — the screen already demonstrates it, no change needed
- **added** — UI/validation added in this pass
- **pending** — planned, not yet built (batch noted)
- **backend-only** — cannot be represented in the UI

Scope for every scoped contract is the session context: **X46 Diagnostics (ORG001) · Pune Main Branch (PUNE-01)**, held in `lims-api.js` (`LIMS.session`). Requests are built by `LIMS.request(<endpoint>, { contract, params, body, query, resolve })` — no screen invents an endpoint.

---

## Test Management — Lab Master

| Scenario | Contract | Screen | UI field / action | Expected UI state | Status |
|---|---|---|---|---|---|
| Toggle status for valid test | API-009 | Lab Master · Tests | Row action **Status** → Status select (Active/Inactive) → *Update Status* | `200 OK — Test status updated successfully`, row status pill flips | added |
| isActive is not boolean | API-009 | Lab Master · Tests | Status select set to **Not set** | field error *isActive must be true or false* + `400 Bad Request — Invalid status value` | added |
| Test ID does not exist / outside org+branch scope | API-009 | Lab Master · Tests | Status modal shows **Test ID**; Branch select | `404 Not Found — Test not found` (test has no master row, or branch ≠ PUNE-01) | added |
| Organization/branch does not exist or branch not in organization | API-006 / API-009 | Lab Master · Tests | Create Test with code `FAIL-404` (existing product convention, as in Branches/Users) | `404 Not Found — Organization or branch not found` | added |
| Duplicate test code / name | API-006 | Lab Master · Tests | Test Code field | `409 Conflict — Duplicate test code` on the field | covered |
| Search tests, empty query | API-011 | Lab Master · Tests | Search box, Enter with empty value | `400 Bad Request — Search query is required` banner; live filter unchanged | added |
| No results | API-011 | Lab Master · Tests | Search box | *No tests found* empty state | covered |

## Parameter / Reference Range — Lab Master · Parameters & Ranges (new tab)

| Scenario | Contract | UI field / action | Expected UI state | Status |
|---|---|---|---|---|
| Create Parameter | API-111 | **Create Parameter** → parameterCode, parameterName, unit, defaultReferenceRange | `201 Created`, row appears in Parameters table | added |
| Duplicate Parameter Code | API-115 | parameterCode field | field error *Duplicate parameter code* + `409 Conflict` | added |
| Create Reference Range | API-112 | **Add Reference Range** (or *Add Range* on a parameter row) | `201 Created`, band appears in Reference Ranges table | added |
| Invalid Parameter (create reference range) | API-114 | Parameter Code field in the range form | field error *Parameter not found…* + `404 Not Found — Parameter not found` | added |
| Overlapping Demographic Band | API-116 | gender + age band + effective dates | `409 Conflict — Overlapping demographic band` naming the clashing band | added |
| Invalid Age Range | API-117 | Age Min / Age Max | field error + `400 Bad Request — Invalid age range` | added |
| Invalid Effective Date Range | API-118 | Effective From / Effective To | field error + `400 Bad Request — Invalid effective date range` | added |
| Invalid Reference Bounds | API-119 | Reference Min / Reference Max | field error + `400 Bad Request — Invalid reference bounds` | added |
| Lookup Reference Range | API-113 | Reference Range Lookup panel (parameter, gender, age, age unit, pregnancy, as-of date) | `200 OK` result card, or `404 — No matching reference range found`, or `400` when required inputs are blank | added |

## Package / Billing — Lab Master · Packages, Bill Details

| Scenario | Contract | Screen | UI field / action | Expected UI state | Status |
|---|---|---|---|---|---|
| Duplicate Package Code | API-123 | Lab Master · Packages | Package Code field | field error *Duplicate package code* + `409 Conflict` | added |
| Duplicate Package Name | API-124 | Lab Master · Packages | Package Name field | field error *Duplicate package name* + `409 Conflict` | added |
| Invalid Test ID in Package | API-125 | Lab Master · Packages | Package detail → **Add Test** (test code) | `404 Not Found — Test not found` | added |
| Duplicate Test in Package | API-126 | Lab Master · Packages | Package detail → **Add Test** with a member test | `409 Conflict — Test already in package` | added |
| Bill Test Package | API-122 | Bill Details | Add Test / Package modal → Test Package | package expands into billing test rows | covered |
| Invalid Package ID (billing) | API-127 | Bill Details | Add Package modal → *Add* | `404 — Test package not found` in the modal error strip | covered (see Billing) |

## Billing — Bill Details, Registration & Billing

| Scenario | Contract | Screen | UI field / action | Expected UI state | Status |
|---|---|---|---|---|---|
| Duplicate Bill Number | API-041 / API-033 | Registration & Billing | **Bill No.** field in the page header (now editable) → Save | field turns red + `409 Conflict — Duplicate bill number — <no> already exists in this organization and branch` | added |
| billNumber missing | API-033 | Registration & Billing | **Bill No.** cleared → Save | `400 Bad Request — billNumber is required` | added |
| Invalid Billing ID | API-042 | Bill Details | **Billing ID** field + *Open* (Enter also works) | `404 — Bill not found` (or `400` when the value is not a UUID, guarded before the request is built) | added |
| Bill outside org + branch scope | API-034 | Bill Details | Billing ID open / branch switcher | `404 — Bill does not belong to this organization and branch` | covered |
| View bill, update bill, add test, edit test, remove test, cancel bill, search bills | API-034/035/036/038/039 | Bill Details | existing controls | success + error states | covered |
| Bill Test Package | API-122 | Bill Details | Add Test / Package modal → Test Package | package expands into pro-rata billing test rows | covered |
| Invalid Package ID (billing) | API-127 | Bill Details | Add Package modal → *Add* | `404 — Test package not found` in the modal error strip (fires when the selected packageId is no longer in the package master) | covered |

## Payment — Bill Payment Details

| Scenario | Contract | UI field / action | Expected UI state | Status |
|---|---|---|---|---|
| Payment Against Bill | API-060 | **Collect Payment** on the bill header → amount, mode, transaction reference, remarks → *Record Payment* | `201 Created — Payment recorded successfully`; payment history, paid and balance recalculate | added |
| Invalid Payment Amount | API-063 | Amount paid = 0, negative or blank | `400 Bad Request — Invalid payment amount` | added |
| Invalid Payment Mode | API-062 | Payment mode select — modes marked *not configured* (WALLET, CORPORATE_CREDIT) are absent from `payment_mode_master` | `400 Bad Request — Invalid payment mode` naming the mode | added |
| Duplicate Transaction Reference | API-064 | Transaction reference reusing an existing one (e.g. `UPI-3391204`) | `409 Conflict — Duplicate transaction reference` | added |
| Invalid Billing ID | API-061 / API-060 | Collect Payment against a bill that no longer exists; cancelled bills show a blocked hint instead of the button | `404 — Bill not found` | added |
| Invalid Payment ID | API-066 | **Payment ID** field in the filter bar → *Open* | `404 — Payment not found` banner | added |
| Organization/Branch Scope | API-067 | Payment ID → *Open* for a payment on another branch's bill | `404 — Payment not accessible. It belongs to another organization or branch.` | added |
| Payment status update | API-068 | Payment drawer → **Update payment status** select + *Update* | `200 OK — Payment status updated from X to Y`; bill paid/balance recomputed from successful payments | added |
| Invalid payment status | API-068 | Status select set to **Not set** | `400 Bad Request — Invalid status` | added |
| View payment / search payments | API-058 / API-065 | Payment history rows, drawer, Payment Mode Collection | covered | covered |
| Create Payment (standalone) | API-057 | not surfaced — the screens always collect against a bill (API-060) | — | backend-only |

## Clinical History — Registration & Billing, Patients

| Scenario | Contract | UI field / action | Status |
|---|---|---|---|
| Valid Search Clinical History | API-027/028 | Clinical history search (patient scoped) | pending (batch 3) |
| Patient does not exist / out of scope | API-029 | patient lookup field | pending (batch 3) |

*Contract gap: `lims-api.js` has no clinical-history endpoints yet (API-026…032). They must be added before the screen can build the request.*

## Accession — Accession

| Scenario | Contract | UI field / action | Status |
|---|---|---|---|
| Invalid Accession ID | API-052 | Accession search / open | pending (batch 3) |
| Duplicate Accession Number | API-053 | Accession Number field | pending (batch 3) |
| Invalid Billing ID | API-054 | Bill reference field | pending (batch 3) |
| Invalid Registration ID | API-055 | Registration reference field | pending (batch 3) |
| Query missing or empty | API-056 | Accession search box | pending (batch 3) |

*The Accession screen is not yet on the contract layer (no `LIMS.request` calls) — batch 3 wires it.*

## Sample Collection — Accession, Worklist Processing

| Scenario | Contract | UI field / action | Status |
|---|---|---|---|
| Invalid Accession Test ID | API-070 | collection row | pending (batch 3) |
| Invalid Collector | API-071 | collected-by select | pending (batch 3) |
| Invalid Sample Condition | API-072 | sample condition select | pending (batch 3) |
| Invalid Collection Status | API-073 | collection status control | pending (batch 3) |
| Invalid Quantity | API-074 | quantity field | pending (batch 3) |
| Duplicate Sample Collection | API-075 | collect action on an already-collected test | pending (batch 3) |
| Invalid Organization/Branch scope | API-076 | branch context | pending (batch 3) |

## Worklist / Worksheet — Worklist, Worklist Processing

| Scenario | Contract | UI field / action | Status |
|---|---|---|---|
| Assign Sample to Worklist | API-079 | Worklist → assign pending tests | covered |
| Invalid Accession Test (assignment) | API-085 | assignment action | covered (404 surfaces in the banner) |
| Invalid Worklist ID (assignment) | API-086 | worklist select | covered |
| Invalid Worksheet ID (assignment) | API-087 | worksheet select | pending (batch 4) |
| Invalid Department | API-080 | worklist create → department | pending (batch 4) |
| Duplicate Worklist Code / Name | API-081/082 | worklist create form | pending (batch 4) |
| Duplicate Worksheet Code / Name | API-083/084 | worksheet create form | pending (batch 4) |

*No create-worklist / create-worksheet form exists yet — batch 4 adds it to the Worklist screen.*

## Result — Result Entry, Result Validation

| Scenario | Contract | UI field / action | Status |
|---|---|---|---|
| Invalid Accession Test | API-091 | result entry header | pending (batch 4) |
| Duplicate Result Entry | API-092 | create result entry | pending (batch 4) |
| Invalid Parameter | API-093 | parameter row | pending (batch 4) |
| Duplicate Result Detail | API-094 | parameter row | pending (batch 4) |
| Invalid Result Flag | API-095 | flag select | pending (batch 4) |
| Invalid Result Status | API-096 | status control | pending (batch 4) |
| Invalid Result Entry ID | API-098 | authorize action | pending (batch 4) |
| Result Entry Not Completed | API-099 | authorize action | pending (batch 4) |

## Report — Reports, Report and Dispatch

| Scenario | Contract | UI field / action | Status |
|---|---|---|---|
| Invalid Accession | API-101 | generate report | pending (batch 5) |
| Duplicate Report Number | API-102 | report number field | pending (batch 5) |
| Duplicate Report for Accession | API-103 | generate report | pending (batch 5) |
| Invalid Report Status | API-104 | report status control | covered |
| Log Report Delivery | API-105 | delivery form | covered |
| Invalid Report ID (delivery) | API-107 | delivery form | covered |
| Invalid Delivery Type | API-108 | delivery mode select | pending (batch 5) |
| Invalid Recipient Type | API-109 | recipient select | pending (batch 5) |
| Invalid Report ID (release) | API-110 | release action | covered |

---

## Backend-only / not representable in the UI

- `500 Internal server error` paths — demonstrated only through the existing sentinel code convention (`FAIL-500`), not a real UI state.
- Uniqueness enforced by DB triggers or constraints that the UI cannot pre-check without a lookup endpoint (e.g. duplicate transaction reference across branches).
- Tenant isolation at row level (org/branch filtering inside queries) — visible only as *not found*, which is what the screens show.

## Contract ↔ screen mismatches found

1. **No clinical-history endpoints** in `lims-api.js` (API-026…032) even though Registration & Billing captures clinical type, condition, severity and duration. Needs adding before the search scenario can be wired.
2. **No list-parameters contract** — the Parameters table reads the local parameter master; only create (API-111) and lookup (API-113) are contract-backed.
3. **Test master codes differ** between the Lab Master screen (`FBS`, `LIP`, `CBC`, `CULT`) and the contract test master (`CBC001`, `LIPID1`, `TSH001`…). Rows are matched by test name; a row with no master row correctly demonstrates *Test not found*.
4. **Billing test update/delete** (`PUT`/`DELETE …/billing/{billingId}/tests/{billingTestId}`) is still marked *proposed* — no contract issued.
6. **API-057 vs API-060**: API-057 (create payment) requires `accessionId` as well as `billingMasterId`, so it cannot be called from a bill that has no accession yet. Collection is therefore wired to API-060 (payment against bill), whose body is only amount/mode/reference/remarks. If the intended flow is always API-057, the contract needs to state how `accessionId` is resolved at counter-collection time.
7. **No payment-mode master endpoint** — `payment_mode_master` is referenced by API-062 but has no read contract, so the configured-mode list lives in `lims-api.js` (`LIMS.PAYMENT_MODES`).
8. **API-065 query parameter mismatch**: the contract requires `billNumber`, while Bill Payment Details and Payment Mode Collection pass `billingId` when listing a bill's payments. One of the two needs to change.
9. **Payment Transactions** is a reporting screen on local mock data (no `LIMS.request`); its filters are not contract-backed. Left unchanged so the report keeps its own dataset.
5. **Package master duplication**: Lab Master keeps its own package list (PKG001…) while `lims-api.js` holds the contract package master (PKG-MHC…). API-121 calls resolve against the contract master; the two should be unified once a list-packages contract exists.
