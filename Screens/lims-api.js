/* X46 LIMS — contract request layer.
 *
 * Purpose: every screen action that has an API contract builds its request HERE,
 * using contract field names, contract endpoints and real UUIDs — never display
 * codes. There is no backend attached to this prototype, so requests resolve
 * against a local resolver; the built request is recorded verbatim so screens
 * (and reviewers) can see exactly what would go over the wire.
 *
 * Nothing in this file invents an endpoint. Each builder is annotated with the
 * contract id it comes from.
 */
(function (global) {
  'use strict';

  /* Idempotent: a second evaluation must not replace the live store, or writes
     made by an already-mounted screen would be silently discarded. */
  if (global.LIMS) return;

  /* ---------------------------------------------------------------- session */
  /* Organization / branch identity. The UI shows label + code; the API layer
     only ever sends `id`. Seeded UUIDs stand in for what a real session would
     hand the client after login. */
  var ORGANIZATIONS = [
    { id: '8f14e45f-ea1c-4d2b-9b4a-1c7b2f0a9e31', code: 'ORG001', name: 'X46 Diagnostics' }
  ];

  var BRANCHES = [
    { id: 'c9b1f2a6-4d38-4f51-8a2e-6b0d3c7e15aa', organizationId: ORGANIZATIONS[0].id, code: 'PUNE-01', name: 'Pune Main Branch' },
    { id: 'd41d8cd9-8f00-4204-a980-0998ecf8427e', organizationId: ORGANIZATIONS[0].id, code: 'MUM-01', name: 'Mumbai Lab' },
    { id: 'a3f5c1e0-77b9-4c62-8d15-2e9a4b6f0c73', organizationId: ORGANIZATIONS[0].id, code: 'BNG-01', name: 'Bangalore Center' }
  ];

  /* Roles are contract entities too — the UI shows "TECH · Lab Technician",
     the API only ever receives roleId. */
  var ROLES = [
    { id: '1f2e3d4c-5b6a-4798-8123-a1b2c3d4e5f6', code: 'ADMIN', name: 'Administrator' },
    { id: '2a3b4c5d-6e7f-4801-9234-b2c3d4e5f6a7', code: 'TECH', name: 'Lab Technician' },
    { id: '3b4c5d6e-7f80-4912-a345-c3d4e5f6a7b8', code: 'PATHO', name: 'Pathologist' },
    { id: '4c5d6e7f-8091-4a23-b456-d4e5f6a7b8c9', code: 'RECEPT', name: 'Front Desk Receptionist' }
  ];

  /* Seeded user records. The screens render `username`; every request uses `id`. */
  var USERS = [
    { id: '6d7e8f90-a1b2-4c34-8567-e5f6a7b8c9d0', username: 'admin.pune' },
    { id: '7e8f90a1-b2c3-4d45-9678-f6a7b8c9d0e1', username: 'r.kulkarni' },
    { id: '8f90a1b2-c3d4-4e56-a789-a7b8c9d0e1f2', username: 's.iyer' }
  ];
  function userByUsername(u) { return USERS.filter(function (x) { return x.username === u; })[0] || null; }
  function userIdFor(u) { var x = userByUsername(u); return x ? x.id : null; }

  /* Test master (API-006/010). UI shows "CBC001 — Complete Blood Count"; the
     API only ever receives testId. */
  var TESTS = [
    { id: '9a0b1c2d-3e4f-4506-8718-b8c9d0e1f2a3', testCode: 'CBC001', testName: 'Complete Blood Count', rate: 350 },
    { id: 'a1b2c3d4-e5f6-4718-9829-c9d0e1f2a3b4', testCode: 'LIPID1', testName: 'Lipid Profile', rate: 700 },
    { id: 'b2c3d4e5-f6a7-4829-a93a-d0e1f2a3b4c5', testCode: 'HBA1C', testName: 'Glycated Haemoglobin (HbA1c)', rate: 520 },
    { id: 'c3d4e5f6-a7b8-493a-ba4b-e1f2a3b4c5d6', testCode: 'TSH001', testName: 'Thyroid Stimulating Hormone', rate: 400 },
    { id: 'd4e5f6a7-b8c9-4a4b-cb5c-f2a3b4c5d6e7', testCode: 'UR1', testName: 'Urine Routine', rate: 180 },
    { id: 'e5f6a7b8-c9d0-4b5c-dc6d-a3b4c5d6e7f8', testCode: 'CULT1', testName: 'Culture & Sensitivity', rate: 750 }
  ];
  function testById(id) { return TESTS.filter(function (t) { return t.id === id; })[0] || null; }

  /* Test package master (API-120/121). Billed through API-122, which expands
     the package into one billing test row per member test. */
  var TEST_PACKAGES = [
    { id: '1c2d3e4f-5a6b-4c7d-8e9f-0a1b2c3d4e5f', packageCode: 'PKG-MHC', packageName: 'Master Health Checkup', packageRate: 1450, testIds: [TESTS[0].id, TESTS[1].id, TESTS[2].id, TESTS[4].id] },
    { id: '2d3e4f5a-6b7c-4d8e-9f0a-1b2c3d4e5f6a', packageCode: 'PKG-DIAB', packageName: 'Diabetes Care Panel', packageRate: 780, testIds: [TESTS[2].id, TESTS[4].id] },
    { id: '3e4f5a6b-7c8d-4e9f-a0b1-2c3d4e5f6a7b', packageCode: 'PKG-THY', packageName: 'Thyroid & Lipid Screen', packageRate: 980, testIds: [TESTS[1].id, TESTS[3].id] }
  ];
  function packageById(id) { return TEST_PACKAGES.filter(function (p) { return p.id === id; })[0] || null; }

  /* Local bill store. Stands in for the billing tables until a backend is
     configured; every mutation happens only after a resolver returns 2xx. */
  function recalc(b) {
    b.payableAmount = Number(b.totalAmount) - Number(b.discountAmount) - Number(b.concessionAmount) + Number(b.additionalAmount);
    b.balanceAmount = b.payableAmount - Number(b.paidAmount);
    b.paymentStatus = b.balanceAmount <= 0 ? 'Paid' : (Number(b.paidAmount) > 0 ? 'Partial' : 'Pending');
    return b;
  }

  var BILLS = [
    recalc({ id: 'f6a7b8c9-d0e1-4c6d-ed7e-b4c5d6e7f8a9', organizationId: ORGANIZATIONS[0].id, branchId: BRANCHES[0].id, patientRegistrationId: '11223344-5566-4778-899a-bbccddeeff00', billNumber: 'BILL0001', billDate: '2026-08-27T09:42:00+05:30', totalAmount: 1050, discountAmount: 0, concessionAmount: 0, additionalAmount: 0, paidAmount: 0, paymentMode: null, remarks: null, isCancelled: false }),
    recalc({ id: '0a1b2c3d-4e5f-4607-8819-c5d6e7f8a9b0', organizationId: ORGANIZATIONS[0].id, branchId: BRANCHES[0].id, patientRegistrationId: '22334455-6677-4889-9aab-ccddeeff0011', billNumber: 'BILL0002', billDate: '2026-08-27T10:15:00+05:30', totalAmount: 520, discountAmount: 20, concessionAmount: 0, additionalAmount: 0, paidAmount: 500, paymentMode: 'UPI', remarks: 'Staff concession applied', isCancelled: false }),
    recalc({ id: '1b2c3d4e-5f60-4718-892a-d6e7f8a9b0c1', organizationId: ORGANIZATIONS[0].id, branchId: BRANCHES[0].id, patientRegistrationId: '33445566-7788-499a-abbc-ddeeff001122', billNumber: 'BILL0003', billDate: '2026-08-26T16:04:00+05:30', totalAmount: 930, discountAmount: 0, concessionAmount: 130, additionalAmount: 50, paidAmount: 850, paymentMode: 'CASH', remarks: null, isCancelled: true })
  ];

  var BILLING_TESTS = [
    { id: '2c3d4e5f-6071-4829-9a3b-e7f8a9b0c1d2', billingId: BILLS[0].id, testId: TESTS[0].id, quantity: 1, rate: 350, netAmount: 350, barcode: null, status: 'Pending' },
    { id: '3d4e5f60-7182-493a-ab4c-f8a9b0c1d2e3', billingId: BILLS[0].id, testId: TESTS[1].id, quantity: 1, rate: 700, netAmount: 700, barcode: 'BC-8842117', status: 'Pending' },
    { id: '4e5f6071-8293-4a4b-bc5d-a9b0c1d2e3f4', billingId: BILLS[1].id, testId: TESTS[2].id, quantity: 1, rate: 520, netAmount: 520, barcode: null, status: 'Pending' }
  ];

  function billById(id) { return BILLS.filter(function (b) { return b.id === id; })[0] || null; }
  function billByNumber(no) {
    var key = String(no || '').trim().toUpperCase();
    if (!key) return null;
    return BILLS.filter(function (b) { return b.billNumber.toUpperCase() === key; })[0] || null;
  }
  function testsForBill(id) { return BILLING_TESTS.filter(function (t) { return t.billingId === id; }); }

  /* Patient records. Screens show MRN; the API only ever receives patientId. */
  var PATIENTS = [
    { id: '5a6b7c8d-9e0f-4123-8456-a1b2c3d4e5f0', mrn: 'MRN-193210', title: 'Mr', firstName: 'Rohan', middleName: '', lastName: 'Deshpande', gender: 'MALE', ageY: 42, ageM: 0, ageD: 0, phone: '9822014577', email: 'rohan.d@example.com', referringDoctor: 'DR-ANAND', isActive: true, lastVisit: '17 Aug 2026', recentTests: ['CBC', 'HBA1C', 'LIPID'] },
    { id: '6b7c8d9e-0f12-4234-9567-b2c3d4e5f001', mrn: 'MRN-193044', title: 'Ms', firstName: 'Saniya', middleName: '', lastName: 'Shaikh', gender: 'FEMALE', ageY: 29, ageM: 0, ageD: 0, phone: '9011245880', email: '', referringDoctor: 'DR-MEHTA', isActive: true, lastVisit: '17 Aug 2026', recentTests: ['UR1', 'CULT'] },
    { id: '7c8d9e0f-1223-4345-a678-c3d4e5f00112', mrn: 'MRN-192877', title: 'Mr', firstName: 'Harishchandra', middleName: '', lastName: 'Shinde', gender: 'MALE', ageY: 85, ageM: 0, ageD: 0, phone: '9890123344', email: '', referringDoctor: 'SELF', isActive: true, lastVisit: '14 Aug 2026', recentTests: ['HBSAG', 'KFT', 'ESR'] }
  ];
  function patientById(id) { return PATIENTS.filter(function (p) { return p.id === id; })[0] || null; }
  function patientByMrn(mrn) {
    var key = String(mrn || '').trim().toUpperCase();
    return PATIENTS.filter(function (p) { return p.mrn.toUpperCase() === key; })[0] || null;
  }
  function patientByPhone(phone) {
    var key = String(phone || '').replace(/\D/g, '');
    if (!key) return null;
    return PATIENTS.filter(function (p) { return p.phone.replace(/\D/g, '') === key; })[0] || null;
  }

  /* ------------------------------------------------------- lab-ops stores */
  /* Local stand-ins for the accession / result / report / payment / worklist
     tables, seeded so the screens that read them exercise real contract
     resolvers. Field names are the contract's, not display labels. */

  /* API-111 parameters. There is no list-parameters contract, so options are
     read from this master rather than a fabricated endpoint. */
  var PARAMETERS = [
    { id: '10a1b2c3-d4e5-4f60-8a71-0b1c2d3e4f50', organizationId: ORGANIZATIONS[0].id, branchId: BRANCHES[0].id, testId: TESTS[0].id, parameterCode: 'WBC', parameterName: 'WBC Count', unit: '10^3/uL', defaultReferenceRange: '4 - 11' },
    { id: '20b2c3d4-e5f6-4071-8b82-1c2d3e4f5061', organizationId: ORGANIZATIONS[0].id, branchId: BRANCHES[0].id, testId: TESTS[0].id, parameterCode: 'HGB', parameterName: 'Haemoglobin', unit: 'g/dL', defaultReferenceRange: '13 - 17' },
    { id: '30c3d4e5-f607-4182-8c93-2d3e4f506172', organizationId: ORGANIZATIONS[0].id, branchId: BRANCHES[0].id, testId: TESTS[1].id, parameterCode: 'CHOL', parameterName: 'Total Cholesterol', unit: 'mg/dL', defaultReferenceRange: '< 200' },
    { id: '40d4e5f6-0718-4293-8da4-3e4f50617283', organizationId: ORGANIZATIONS[0].id, branchId: BRANCHES[0].id, testId: TESTS[2].id, parameterCode: 'HBA1C', parameterName: 'HbA1c', unit: '%', defaultReferenceRange: '4 - 5.7' },
    { id: '50e5f607-1829-43a4-8eb5-4f5061728394', organizationId: ORGANIZATIONS[0].id, branchId: BRANCHES[0].id, testId: TESTS[3].id, parameterCode: 'TSH', parameterName: 'TSH', unit: 'uIU/mL', defaultReferenceRange: '0.4 - 4.2' }
  ];
  function parameterById(id) { return PARAMETERS.filter(function (p) { return p.id === id; })[0] || null; }
  function parametersForTest(testId) { return PARAMETERS.filter(function (p) { return p.testId === testId; }); }
  /* API-111 uniqueness is (organizationId, branchId, parameterCode). */
  function parameterByCode(code, organizationId, branchId) {
    var key = String(code || '').trim().toUpperCase();
    if (!key) return null;
    return PARAMETERS.filter(function (p) {
      return String(p.parameterCode || '').toUpperCase() === key
        && (!organizationId || p.organizationId === organizationId)
        && (!branchId || p.branchId === branchId);
    })[0] || null;
  }

  /* API-112 / API-113 reference ranges. */
  /* Contract field names (gender / ageMin / ageMax / ageUnit / pregnancyFlag /
     referenceMin / referenceMax / effectiveFrom / effectiveTo) are authoritative.
     ageMinYears / normalLow / normalHigh are kept as display aliases for screens
     that were built before API-112 landed. */
  var REFERENCE_RANGES = [
    { id: '60f60718-2930-44b5-8fc6-5061728394a5', parameterId: PARAMETERS[0].id, gender: 'ANY', ageMin: 18, ageMax: 120, ageUnit: 'YEARS', pregnancyFlag: false, referenceMin: 4, referenceMax: 11, effectiveFrom: '2020-01-01', effectiveTo: null, ageMinYears: 18, ageMaxYears: 99, normalLow: 4, normalHigh: 11, unit: '10^3/uL' },
    { id: '70071829-3041-45c6-8fd7-61728394a5b6', parameterId: PARAMETERS[1].id, gender: 'MALE', ageMin: 18, ageMax: 120, ageUnit: 'YEARS', pregnancyFlag: false, referenceMin: 13, referenceMax: 17, effectiveFrom: '2020-01-01', effectiveTo: null, ageMinYears: 18, ageMaxYears: 99, normalLow: 13, normalHigh: 17, unit: 'g/dL' },
    { id: '80182930-4152-46d7-8fe8-728394a5b6c7', parameterId: PARAMETERS[2].id, gender: 'ANY', ageMin: 18, ageMax: 120, ageUnit: 'YEARS', pregnancyFlag: false, referenceMin: 0, referenceMax: 200, effectiveFrom: '2020-01-01', effectiveTo: null, ageMinYears: 18, ageMaxYears: 99, normalLow: 0, normalHigh: 200, unit: 'mg/dL' },
    { id: '90293041-5263-47e8-8ff9-8394a5b6c7d8', parameterId: PARAMETERS[3].id, gender: 'ANY', ageMin: 18, ageMax: 120, ageUnit: 'YEARS', pregnancyFlag: false, referenceMin: 4, referenceMax: 5.7, effectiveFrom: '2020-01-01', effectiveTo: null, ageMinYears: 18, ageMaxYears: 99, normalLow: 4, normalHigh: 5.7, unit: '%' },
    { id: 'a0304152-6374-48f9-8f0a-94a5b6c7d8e9', parameterId: PARAMETERS[4].id, gender: 'ANY', ageMin: 18, ageMax: 120, ageUnit: 'YEARS', pregnancyFlag: false, referenceMin: 0.4, referenceMax: 4.2, effectiveFrom: '2020-01-01', effectiveTo: null, ageMinYears: 18, ageMaxYears: 99, normalLow: 0.4, normalHigh: 4.2, unit: 'uIU/mL' }
  ];
  /* API-113 lookup: matches parameter + gender + age band + pregnancy + as-of date. */
  function lookupRange(q) {
    var age = Number(q.age);
    var unit = String(q.ageUnit || 'YEARS').toUpperCase();
    var g = String(q.gender || 'ANY').toUpperCase();
    var asOf = q.asOfDate || new Date().toISOString().slice(0, 10);
    var preg = !!q.pregnancyFlag;
    var toYears = function (v, u) { return u === 'DAYS' ? v / 365 : u === 'MONTHS' ? v / 12 : v; };
    var ageY = toYears(age, unit);
    return REFERENCE_RANGES.filter(function (r) {
      var lo = toYears(Number(r.ageMin), String(r.ageUnit || 'YEARS').toUpperCase());
      var hi = toYears(Number(r.ageMax), String(r.ageUnit || 'YEARS').toUpperCase());
      return r.parameterId === q.parameterId
        && (r.gender === g || r.gender === 'ANY' || r.gender === 'ALL')
        && ageY >= lo && ageY <= hi
        && (!!r.pregnancyFlag === preg || !r.pregnancyFlag)
        && (!r.effectiveFrom || r.effectiveFrom <= asOf)
        && (!r.effectiveTo || r.effectiveTo >= asOf);
    })[0] || null;
  }
  /* API-116 overlap guard: same parameter + gender + pregnancy, overlapping age
     band and overlapping effective-date window. */
  function overlappingRange(candidate) {
    return REFERENCE_RANGES.filter(function (r) {
      if (r.parameterId !== candidate.parameterId) return false;
      if (r.id === candidate.id) return false;
      var sameDemo = (r.gender === candidate.gender) || r.gender === 'ANY' || candidate.gender === 'ANY';
      if (!sameDemo) return false;
      if (!!r.pregnancyFlag !== !!candidate.pregnancyFlag) return false;
      var ageOverlap = Number(candidate.ageMin) <= Number(r.ageMax) && Number(candidate.ageMax) >= Number(r.ageMin);
      if (!ageOverlap) return false;
      var aFrom = candidate.effectiveFrom || '0000-01-01';
      var aTo = candidate.effectiveTo || '9999-12-31';
      var bFrom = r.effectiveFrom || '0000-01-01';
      var bTo = r.effectiveTo || '9999-12-31';
      return aFrom <= bTo && aTo >= bFrom;
    })[0] || null;
  }
  function rangeForParameter(parameterId, gender) {
    var g = String(gender || 'ALL').toUpperCase();
    var hit = REFERENCE_RANGES.filter(function (r) { return r.parameterId === parameterId && (r.gender === g || r.gender === 'ALL' || r.gender === 'ANY'); });
    return hit[0] || null;
  }

  /* API-043..047 accessions and their tests. */
  var ACCESSIONS = [
    { id: 'b0415263-7485-490a-8f1b-a5b6c7d8e9f0', organizationId: ORGANIZATIONS[0].id, branchId: BRANCHES[0].id, patientRegistrationId: BILLS[0].patientRegistrationId, patientId: PATIENTS[0].id, accessionNumber: 'ACC-0001', accessionDate: '2026-08-27T10:05:00+05:30', status: 'IN_PROCESS', priority: 'ROUTINE' },
    { id: 'c0526374-8596-4a1b-8f2c-b6c7d8e9f001', organizationId: ORGANIZATIONS[0].id, branchId: BRANCHES[0].id, patientRegistrationId: BILLS[1].patientRegistrationId, patientId: PATIENTS[1].id, accessionNumber: 'ACC-0002', accessionDate: '2026-08-27T11:20:00+05:30', status: 'IN_PROCESS', priority: 'URGENT' },
    { id: 'd0637485-96a7-4b2c-8f3d-c7d8e9f00112', organizationId: ORGANIZATIONS[0].id, branchId: BRANCHES[0].id, patientRegistrationId: BILLS[2].patientRegistrationId, patientId: PATIENTS[2].id, accessionNumber: 'ACC-0003', accessionDate: '2026-08-26T16:40:00+05:30', status: 'COMPLETED', priority: 'ROUTINE' }
  ];
  function accessionById(id) { return ACCESSIONS.filter(function (a) { return a.id === id; })[0] || null; }
  function accessionByNumber(no) {
    var key = String(no || '').trim().toUpperCase();
    return ACCESSIONS.filter(function (a) { return a.accessionNumber.toUpperCase() === key; })[0] || null;
  }

  var ACCESSION_TESTS = [
    { id: 'e0748596-a7b8-4c3d-8f4e-d8e9f0011223', accessionId: ACCESSIONS[0].id, testId: TESTS[0].id, barcode: 'BC-8842117', sampleStatus: 'RECEIVED', collectionStatus: 'COLLECTED', authorizationStatus: 'PENDING', reportStatus: 'PENDING', worklistId: null, assignedUserId: USERS[1].id },
    { id: 'f08596a7-b8c9-4d4e-8f5f-e9f001122334', accessionId: ACCESSIONS[0].id, testId: TESTS[1].id, barcode: 'BC-8842118', sampleStatus: 'PROCESSING', collectionStatus: 'COLLECTED', authorizationStatus: 'PENDING', reportStatus: 'PENDING', worklistId: null, assignedUserId: USERS[1].id },
    { id: '0196a7b8-c9d0-4e5f-8f60-f00112233445', accessionId: ACCESSIONS[1].id, testId: TESTS[2].id, barcode: 'BC-8842119', sampleStatus: 'COLLECTED', collectionStatus: 'COLLECTED', authorizationStatus: 'PENDING', reportStatus: 'PENDING', worklistId: null, assignedUserId: USERS[2].id },
    { id: '12a7b8c9-d0e1-4f60-8f71-001122334455', accessionId: ACCESSIONS[2].id, testId: TESTS[3].id, barcode: 'BC-8842120', sampleStatus: 'COMPLETED', collectionStatus: 'COLLECTED', authorizationStatus: 'AUTHORIZED', reportStatus: 'READY', worklistId: null, assignedUserId: USERS[2].id }
  ];
  function accessionTestById(id) { return ACCESSION_TESTS.filter(function (t) { return t.id === id; })[0] || null; }
  function accessionTestsFor(accessionId) { return ACCESSION_TESTS.filter(function (t) { return t.accessionId === accessionId; }); }

  /* API-088/089/090/097 result entries. */
  var RESULT_ENTRIES = [
    { id: '23b8c9d0-e1f2-4071-8f82-112233445566', accessionTestId: ACCESSION_TESTS[3].id, enteredBy: 'S. Iyer', enteredAt: '2026-08-26T18:12:00+05:30', status: 'AUTHORIZED', remarks: null },
    { id: '34c9d0e1-f203-4182-8f93-223344556677', accessionTestId: ACCESSION_TESTS[0].id, enteredBy: 'R. Kulkarni', enteredAt: '2026-08-27T12:30:00+05:30', status: 'PENDING_AUTH', remarks: null },
    { id: '45d0e1f2-0314-4293-8fa4-334455667788', accessionTestId: ACCESSION_TESTS[2].id, enteredBy: 'R. Kulkarni', enteredAt: '2026-08-27T13:05:00+05:30', status: 'ENTERED', remarks: null }
  ];
  var RESULT_DETAILS = [
    { id: '56e1f203-1425-43a4-8fb5-445566778899', resultEntryId: RESULT_ENTRIES[0].id, parameterId: PARAMETERS[4].id, resultValue: '3.1', unit: 'uIU/mL', resultFlag: 'NORMAL', remarks: null },
    { id: '67f20314-2536-44b5-8fc6-556677889900', resultEntryId: RESULT_ENTRIES[1].id, parameterId: PARAMETERS[0].id, resultValue: '7.5', unit: '10^3/uL', resultFlag: 'NORMAL', remarks: null },
    { id: '78031425-3647-45c6-8fd7-667788990011', resultEntryId: RESULT_ENTRIES[2].id, parameterId: PARAMETERS[3].id, resultValue: '6.4', unit: '%', resultFlag: 'HIGH', remarks: 'Repeat after fasting' }
  ];
  function resultEntryById(id) { return RESULT_ENTRIES.filter(function (r) { return r.id === id; })[0] || null; }
  function resultDetailsFor(resultEntryId) { return RESULT_DETAILS.filter(function (d) { return d.resultEntryId === resultEntryId; }); }

  /* API-057..068 payments. */
  var PAYMENTS = [
    { id: '89142536-4758-46d7-8fe8-778899001122', billingId: BILLS[1].id, paymentAmount: 500, paymentMode: 'UPI', paymentStatus: 'SUCCESS', transactionReference: 'UPI-3391204', paymentDate: '2026-08-27T10:22:00+05:30', remarks: null },
    { id: '9a253647-5869-47e8-8ff9-889900112233', billingId: BILLS[2].id, paymentAmount: 850, paymentMode: 'CASH', paymentStatus: 'SUCCESS', transactionReference: null, paymentDate: '2026-08-26T16:20:00+05:30', remarks: 'Counter collection' }
  ];
  function paymentById(id) { return PAYMENTS.filter(function (p) { return p.id === id; })[0] || null; }
  function paymentsForBill(billingId) { return PAYMENTS.filter(function (p) { return p.billingId === billingId; }); }
  function paymentByReference(ref) {
    var key = String(ref || '').trim().toUpperCase();
    if (!key) return null;
    return PAYMENTS.filter(function (p) {
      return String(p.transactionReference || '').toUpperCase() === key;
    })[0] || null;
  }

  /* payment_mode_master (API-057/060/062). The enum in the contract lists every
     mode the schema allows; `configured` records whether the branch actually has
     that code in payment_mode_master — an unconfigured code is the API-062
     "Invalid payment mode" condition. */
  var PAYMENT_MODES = [
    { code: 'CASH', label: 'Cash', configured: true },
    { code: 'CARD', label: 'Card', configured: true },
    { code: 'UPI', label: 'UPI', configured: true },
    { code: 'NET_BANKING', label: 'Net banking', configured: true },
    { code: 'CHEQUE', label: 'Cheque', configured: true },
    { code: 'WALLET', label: 'Wallet', configured: false },
    { code: 'CORPORATE_CREDIT', label: 'Corporate credit', configured: false }
  ];
  function paymentModeByCode(code) {
    var key = String(code || '').toUpperCase();
    return PAYMENT_MODES.filter(function (m) { return m.code === key; })[0] || null;
  }
  /* API-057/059/068 paymentStatus enum. */
  var PAYMENT_STATUSES = ['SUCCESS', 'PENDING', 'FAILED', 'PARTIAL'];

  /* API-100..135 reports and deliveries. */
  var REPORTS = [
    { id: 'ab364758-697a-48f9-8f0a-990011223344', accessionId: ACCESSIONS[2].id, patientRegistrationId: ACCESSIONS[2].patientRegistrationId, reportNumber: 'RPT-0001', reportStatus: 'RELEASED', verificationStatus: 'VERIFIED', dispatchStatus: 'DISPATCHED', generatedAt: '2026-08-26T18:40:00+05:30', releasedAt: '2026-08-26T19:02:00+05:30' },
    { id: 'bc475869-7a8b-490a-8f1b-001122334455', accessionId: ACCESSIONS[0].id, patientRegistrationId: ACCESSIONS[0].patientRegistrationId, reportNumber: 'RPT-0002', reportStatus: 'READY', verificationStatus: 'VERIFIED', dispatchStatus: 'PENDING', generatedAt: '2026-08-27T13:10:00+05:30', releasedAt: null },
    { id: 'cd58697a-8b9c-4a1b-8f2c-112233445566', accessionId: ACCESSIONS[1].id, patientRegistrationId: ACCESSIONS[1].patientRegistrationId, reportNumber: 'RPT-0003', reportStatus: 'PENDING', verificationStatus: 'PENDING', dispatchStatus: 'PENDING', generatedAt: '2026-08-27T13:45:00+05:30', releasedAt: null }
  ];
  var DELIVERIES = [
    { id: 'de697a8b-9c0d-4b2c-8f3d-223344556677', reportId: REPORTS[0].id, deliveryMode: 'EMAIL', recipient: 'harish.s@example.com', deliveryStatus: 'DELIVERED', deliveredAt: '2026-08-26T19:05:00+05:30', remarks: null }
  ];
  function reportById(id) { return REPORTS.filter(function (r) { return r.id === id; })[0] || null; }
  function deliveriesFor(reportId) { return DELIVERIES.filter(function (d) { return d.reportId === reportId; }); }

  /* API-077/079/130 worklists. */
  var WORKLISTS = [
    { id: 'ef7a8b9c-0d1e-4c3d-8f4e-334455667788', organizationId: ORGANIZATIONS[0].id, branchId: BRANCHES[0].id, worklistNumber: 'WL-0001', worklistDate: '2026-08-27T09:00:00+05:30', departmentName: 'Biochemistry', status: 'OPEN', assignedUserId: USERS[1].id },
    { id: 'f08b9c0d-1e2f-4d4e-8f5f-445566778899', organizationId: ORGANIZATIONS[0].id, branchId: BRANCHES[0].id, worklistNumber: 'WL-0002', worklistDate: '2026-08-27T09:30:00+05:30', departmentName: 'Haematology', status: 'IN_PROGRESS', assignedUserId: USERS[2].id }
  ];
  function worklistById(id) { return WORKLISTS.filter(function (w) { return w.id === id; })[0] || null; }

  var session = {
    organizationId: ORGANIZATIONS[0].id,
    branchId: BRANCHES[0].id,
    userId: '5e3f7a92-1b8c-4d06-9f21-7c4e8a05b3d1' /* created_by — resolved server-side in production */
  };

  function orgById(id) { return ORGANIZATIONS.filter(function (o) { return o.id === id; })[0] || null; }
  function branchById(id) { return BRANCHES.filter(function (b) { return b.id === id; })[0] || null; }
  function branchByCode(code) { return BRANCHES.filter(function (b) { return b.code === code; })[0] || null; }
  function roleById(id) { return ROLES.filter(function (r) { return r.id === id; })[0] || null; }
  function roleByCode(code) { return ROLES.filter(function (r) { return r.code === code; })[0] || null; }
  function roleIdFromCode(code) { var r = roleByCode(code); return r ? r.id : null; }
  function roleCode(id) { var r = roleById(id); return r ? r.code : ''; }
  function roleLabel(id) { var r = roleById(id); return r ? r.code + ' \u00b7 ' + r.name : '\u2014'; }
  function roleOptions() {
    return ROLES.map(function (r) { return { value: r.id, label: r.code + ' \u00b7 ' + r.name }; });
  }

  /* Generates a v4-shaped id — stands in for the id a real POST would return,
     so downstream contracts that take it as a path param stay valid. */
  function newId() {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
      var r = (Math.random() * 16) | 0;
      return (c === 'x' ? r : (r & 0x3) | 0x8).toString(16);
    });
  }

  /* Display helpers — human-friendly text, never used as an identifier. */
  function branchLabel(id) {
    var b = branchById(id);
    return b ? b.name + ' (' + b.code + ')' : '—';
  }
  function orgLabel(id) {
    var o = orgById(id);
    return o ? o.name + ' (' + o.code + ')' : '—';
  }
  function branchOptions() {
    return BRANCHES.map(function (b) { return { value: b.id, label: b.name + ' · ' + b.code }; });
  }

  function setBranch(id) {
    if (branchById(id)) session.branchId = id;
    return session.branchId;
  }

  /* Screens that still hold a branch CODE in their markup can migrate through
     this, so the request carries the UUID even before the control is rebuilt. */
  function branchIdFromCode(code) {
    var b = branchByCode(code);
    return b ? b.id : null;
  }

  /* -------------------------------------------------------------- endpoints */
  /* Path templates copied verbatim from the contract files. */
  var scoped = '/api/organizations/{organizationId}/branches/{branchId}';

  var ENDPOINTS = {
    /* API-001 */ createOrganization: ['POST', '/api/organizations'],
    /* API-002 */ createBranch: ['POST', '/api/organizations/{organizationId}/branches'],

    /* API-003 */ createRole: ['POST', scoped + '/roles'],
    /* API-129 */ listRoles: ['GET', scoped + '/roles'],
    /* API-129 */ viewRole: ['GET', scoped + '/roles/{roleId}'],
    /* API-129 */ updateRole: ['PUT', scoped + '/roles/{roleId}'],
    /* API-129 */ roleStatus: ['PATCH', scoped + '/roles/{roleId}/status'],

    /* API-004 */ createUser: ['POST', scoped + '/users'],
    /* API-005 */ assignRole: ['POST', scoped + '/users/{userId}/roles'],
    /* API-128 */ listUsers: ['GET', scoped + '/users'],
    /* API-128 */ viewUser: ['GET', scoped + '/users/{userId}'],
    /* API-128 */ updateUser: ['PUT', scoped + '/users/{userId}'],
    /* API-128 */ userStatus: ['PATCH', scoped + '/users/{userId}/status'],

    /* API-006 */ createTest: ['POST', scoped + '/tests'],
    /* API-007 */ viewTest: ['GET', scoped + '/tests/{testId}'],
    /* API-008 */ updateTest: ['PUT', scoped + '/tests/{testId}'],
    /* API-009 */ testStatus: ['PATCH', scoped + '/tests/{testId}/status'],
    /* API-010 */ listTests: ['GET', scoped + '/tests'],
    /* API-011 */ searchTests: ['GET', scoped + '/tests/search'],

    /* API-012 */ createDepartment: ['POST', scoped + '/departments'],
    /* API-013 */ viewDepartment: ['GET', scoped + '/departments/{departmentId}'],
    /* API-014 */ updateDepartment: ['PUT', scoped + '/departments/{departmentId}'],
    /* API-015 */ departmentStatus: ['PATCH', scoped + '/departments/{departmentId}/status'],

    /* API-016 */ createPatient: ['POST', scoped + '/patients'],
    /* API-017 */ viewPatient: ['GET', scoped + '/patients/{patientId}'],
    /* API-018 */ updatePatient: ['PUT', scoped + '/patients/{patientId}'],
    /* API-019 */ searchPatients: ['GET', scoped + '/patients/search'],
    /* API-020 */ patientStatus: ['PATCH', scoped + '/patients/{patientId}/status'],

    /* API-021 */ createRegistration: ['POST', scoped + '/patients/{patientId}/registrations'],
    /* API-022 */ viewRegistration: ['GET', scoped + '/registrations/{registrationId}'],
    /* API-023 */ registrationStatus: ['PATCH', scoped + '/registrations/{registrationId}/status'],
    /* API-024 */ registrationHistory: ['GET', scoped + '/patients/{patientId}/registrations'],
    /* API-025 */ searchRegistrations: ['GET', scoped + '/registrations/search'],

    /* API-033 */ createBill: ['POST', scoped + '/billing'],
    /* API-034 */ viewBill: ['GET', scoped + '/billing/{billingId}'],
    /* API-035 */ updateBill: ['PUT', scoped + '/billing/{billingId}'],
    /* API-036 */ addTestToBill: ['POST', scoped + '/billing/{billingId}/tests'],
    /* API-037 */ viewBillingTests: ['GET', scoped + '/billing/{billingId}/tests'],
    /* API-038 */ searchBills: ['GET', scoped + '/billing/search'],
    /* proposed — no contract issued yet, follows the API-036 test family */
    updateBillingTest: ['PUT', scoped + '/billing/{billingId}/tests/{billingTestId}'],
    removeBillingTest: ['DELETE', scoped + '/billing/{billingId}/tests/{billingTestId}'],
    /* API-039 */ cancelBill: ['PATCH', scoped + '/billing/{billingId}/cancel'],

    /* API-043 */ createAccession: ['POST', scoped + '/accessions'],
    /* API-044 */ viewAccession: ['GET', scoped + '/accessions/{accessionId}'],
    /* API-045 */ updateAccession: ['PUT', scoped + '/accessions/{accessionId}'],
    /* API-046 */ accessionStatus: ['PATCH', scoped + '/accessions/{accessionId}/status'],
    /* API-047 */ listAccessionTests: ['GET', scoped + '/accessions/{accessionId}/tests'],
    /* API-048 */ sampleStatus: ['PATCH', scoped + '/accessions/{accessionId}/tests/{accessionTestId}/sample-status'],
    /* API-049 */ collectionStatus: ['PATCH', scoped + '/accessions/{accessionId}/tests/{accessionTestId}/collection-status'],
    /* API-050 */ authorizationStatus: ['PATCH', scoped + '/accessions/{accessionId}/tests/{accessionTestId}/authorization-status'],
    /* API-051 */ reportStatus: ['PATCH', scoped + '/accessions/{accessionId}/tests/{accessionTestId}/report-status'],
    /* API-056 */ searchAccessions: ['GET', scoped + '/accessions/search'],

    /* API-057 */ createPayment: ['POST', '/api/payments'],
    /* API-058 */ viewPayment: ['GET', '/api/payments/{paymentId}'],
    /* API-059 */ updatePayment: ['PUT', '/api/payments/{paymentId}'],
    /* API-060 */ paymentAgainstBill: ['POST', '/api/bills/{billingId}/payments'],
    /* API-065 */ searchPayments: ['GET', '/api/payments'],
    /* API-068 */ paymentStatus: ['PATCH', '/api/payments/{paymentId}/status'],

    /* API-069 */ createSampleCollection: ['POST', '/api/sample-collections'],

    /* API-077 */ createWorklist: ['POST', '/api/worklists'],
    /* API-078 */ createWorksheet: ['POST', '/api/worksheets'],
    /* API-079 */ assignToWorklist: ['PATCH', scoped + '/accession-tests/{accessionTestId}/worklist'],
    /* API-130 */ listWorklists: ['GET', scoped + '/worklists'],

    /* API-088 */ createResultEntry: ['POST', '/api/result-entries'],
    /* API-089 */ addResultDetail: ['POST', '/api/result-entries/{resultEntryId}/details'],
    /* API-090 */ resultEntryStatus: ['PATCH', '/api/result-entries/{resultEntryId}/status'],
    /* API-131 */ viewResultEntry: ['GET', '/api/result-entries/{resultEntryId}'],
    /* API-132 */ listResultEntries: ['GET', scoped + '/result-entries'],
    /* API-097 */ authorizeResultEntry: ['PATCH', '/api/result-entries/{resultEntryId}/authorize'],

    /* API-100 */ generateReport: ['POST', '/api/reports'],
    /* API-104 */ reportRecordStatus: ['PATCH', '/api/reports/{reportId}/status'],
    /* API-105 */ logDelivery: ['POST', '/api/reports/{reportId}/deliveries'],
    /* API-106 */ releaseReport: ['PATCH', '/api/reports/{reportId}/release'],
    /* API-133 */ viewReport: ['GET', '/api/reports/{reportId}'],
    /* API-134 */ patientReportHistory: ['GET', scoped + '/patients/{patientRegistrationId}/reports'],
    /* API-135 */ batchDelivery: ['POST', '/api/reports/deliveries/batch'],

    /* API-111 */ createParameter: ['POST', '/api/parameters'],
    /* API-112 */ createReferenceRange: ['POST', '/api/reference-ranges'],
    /* API-113 */ lookupReferenceRange: ['GET', '/api/reference-ranges/lookup'],

    /* API-120 */ createTestPackage: ['POST', scoped + '/test-packages'],
    /* API-121 */ addTestToPackage: ['POST', scoped + '/test-packages/{packageId}/tests'],
    /* API-122 */ billTestPackage: ['POST', scoped + '/billings/{billingId}/test-packages'],

    /* API-136 */ outsourceAccessionTest: ['PATCH', scoped + '/accession-tests/{accessionTestId}/outsource'],
    /* API-137 */ financeDashboard: ['GET', scoped + '/finance/dashboard'],
    /* API-138 */ financeReports: ['GET', scoped + '/finance/reports'],
    /* API-139 */ mostTestedTests: ['GET', scoped + '/reports/most-tested-tests']
  };

  var UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
  function isUuid(v) { return typeof v === 'string' && UUID_RE.test(v); }

  /* Fills a path template. Every {param} must be supplied; any parameter whose
     name ends in `Id` must be a UUID — this is the guard that stops a display
     code like PUNE-01 reaching the wire. */
  function buildPath(template, params) {
    var p = params || {};
    var missing = [];
    var notUuid = [];
    var url = template.replace(/\{(\w+)\}/g, function (_, key) {
      var v = p[key];
      if (v === undefined || v === null || v === '') { missing.push(key); return '{' + key + '}'; }
      if (/Id$/.test(key) && !isUuid(v)) notUuid.push(key + '=' + v);
      return encodeURIComponent(v);
    });
    if (missing.length) throw new Error('Missing path parameter(s): ' + missing.join(', '));
    if (notUuid.length) throw new Error('Path parameter must be a UUID, got a display value: ' + notUuid.join(', '));
    return url;
  }

  /* Resolves the scope params a contract needs, from session unless overridden. */
  function scopeParams(extra) {
    var out = { organizationId: session.organizationId, branchId: session.branchId };
    for (var k in (extra || {})) if (Object.prototype.hasOwnProperty.call(extra, k)) out[k] = extra[k];
    return out;
  }

  /* ------------------------------------------------------------- transport */
  var log = [];

  /* Real transport, per the project's convention. Used when a backend base URL
     is configured; otherwise `request` falls back to the local resolver. */
  async function apiRequest(url, options) {
    options = options || {};
    var response = await fetch(url, Object.assign({}, options, {
      headers: Object.assign({ 'Content-Type': 'application/json' }, options.headers || {})
    }));
    var data = await response.json().catch(function () { return null; });
    if (!response.ok) {
      var error = new Error((data && (data.error || data.message)) || 'API request failed');
      error.status = response.status;
      error.data = data;
      throw error;
    }
    return data;
  }

  var baseUrl = null; /* set via LIMS.configure({baseUrl}) once a backend exists */

  /* Builds + records a contract request, then resolves it. `resolve` is the
     screen-supplied function that decides the outcome from local data; it
     returns either {status, ...body} for a failure or {data, message} for 200/201.
     Nothing here fabricates success — the screen's own rules do, and the
     recorded request shows precisely what was sent. */
  async function request(name, opts) {
    var def = ENDPOINTS[name];
    if (!def) throw new Error('No contract endpoint named "' + name + '" — do not invent one.');
    var method = def[0];
    var path = buildPath(def[1], scopeParams((opts || {}).params));
    var query = (opts || {}).query;
    var qs = '';
    if (query) {
      var parts = [];
      for (var k in query) {
        if (Object.prototype.hasOwnProperty.call(query, k) && query[k] !== '' && query[k] != null) {
          parts.push(encodeURIComponent(k) + '=' + encodeURIComponent(query[k]));
        }
      }
      if (parts.length) qs = '?' + parts.join('&');
    }
    var body = (opts || {}).body;
    var entry = {
      contract: (opts || {}).contract || name,
      method: method,
      url: path + qs,
      body: body || null,
      at: new Date().toISOString()
    };
    log.push(entry);
    if (log.length > 200) log.shift();

    if (baseUrl) {
      return apiRequest(baseUrl + entry.url, {
        method: method,
        body: body ? JSON.stringify(body) : undefined
      });
    }

    var resolver = (opts || {}).resolve;
    if (typeof resolver !== 'function') {
      var e = new Error('NOT VERIFIED — no backend configured and no local resolver supplied for ' + entry.contract);
      e.status = 0;
      e.request = entry;
      throw e;
    }
    var out = await resolver();
    if (out && out.status && out.status >= 400) {
      var err = new Error(out.error || 'API request failed');
      err.status = out.status;
      err.data = out;
      err.request = entry;
      throw err;
    }
    return {
      success: true,
      status: out && out.status ? out.status : 200,
      message: (out && out.message) || 'OK',
      data: (out && out.data) || null,
      request: entry
    };
  }

  function describe(name, params) {
    var def = ENDPOINTS[name];
    if (!def) return '—';
    try { return def[0] + ' ' + buildPath(def[1], scopeParams(params)); }
    catch (e) { return def[0] + ' ' + def[1]; }
  }

  global.LIMS = {
    ORGANIZATIONS: ORGANIZATIONS,
    BRANCHES: BRANCHES,
    ROLES: ROLES,
    PATIENTS: PATIENTS,
    patientById: patientById,
    patientByMrn: patientByMrn,
    patientByPhone: patientByPhone,
    TESTS: TESTS,
    testById: testById,
    TEST_PACKAGES: TEST_PACKAGES,
    packageById: packageById,
    BILLS: BILLS,
    BILLING_TESTS: BILLING_TESTS,
    billById: billById,
    billByNumber: billByNumber,
    testsForBill: testsForBill,
    recalcBill: recalc,
    PARAMETERS: PARAMETERS,
    parameterById: parameterById,
    parameterByCode: parameterByCode,
    lookupRange: lookupRange,
    overlappingRange: overlappingRange,
    parametersForTest: parametersForTest,
    REFERENCE_RANGES: REFERENCE_RANGES,
    rangeForParameter: rangeForParameter,
    ACCESSIONS: ACCESSIONS,
    accessionById: accessionById,
    accessionByNumber: accessionByNumber,
    ACCESSION_TESTS: ACCESSION_TESTS,
    accessionTestById: accessionTestById,
    accessionTestsFor: accessionTestsFor,
    RESULT_ENTRIES: RESULT_ENTRIES,
    RESULT_DETAILS: RESULT_DETAILS,
    resultEntryById: resultEntryById,
    resultDetailsFor: resultDetailsFor,
    PAYMENTS: PAYMENTS,
    paymentById: paymentById,
    paymentsForBill: paymentsForBill,
    paymentByReference: paymentByReference,
    PAYMENT_MODES: PAYMENT_MODES,
    paymentModeByCode: paymentModeByCode,
    PAYMENT_STATUSES: PAYMENT_STATUSES,
    REPORTS: REPORTS,
    DELIVERIES: DELIVERIES,
    reportById: reportById,
    deliveriesFor: deliveriesFor,
    WORKLISTS: WORKLISTS,
    worklistById: worklistById,
    USERS: USERS,
    userIdFor: userIdFor,
    roleById: roleById,
    roleByCode: roleByCode,
    roleIdFromCode: roleIdFromCode,
    roleCode: roleCode,
    roleLabel: roleLabel,
    roleOptions: roleOptions,
    newId: newId,
    session: session,
    setBranch: setBranch,
    branchIdFromCode: branchIdFromCode,
    branchById: branchById,
    branchLabel: branchLabel,
    orgLabel: orgLabel,
    branchOptions: branchOptions,
    ENDPOINTS: ENDPOINTS,
    isUuid: isUuid,
    buildPath: buildPath,
    describe: describe,
    apiRequest: apiRequest,
    request: request,
    requestLog: log,
    configure: function (cfg) { if (cfg && cfg.baseUrl) baseUrl = cfg.baseUrl; }
  };
})(window);
