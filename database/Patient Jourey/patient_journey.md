# End-to-End Patient Journey Validation

## Patient Journey

### Step 1 – Organization Selection
The workflow begins by identifying the laboratory organization (`LAB002`). All subsequent records are created within the scope of this organization.

Status: PASS

---

### Step 2 – Branch Selection
The branch (`PUNE002`) is identified using the organization ID. All patient-related records are created under this branch.

Status: PASS

---

### Step 3 – User Identification
The administrator user is retrieved and used as the creator of all records in this workflow.

Status: PASS

---

### Step 4 – Patient Registration
A new outpatient named **Manas Gaikwad** is registered in the system.

Information captured:
- Patient Type: OUTPATIENT
- Gender: Male
- Date of Birth: 2005-01-01
- Category: GENERAL

Output:
- Patient ID generated successfully.

Status: PASS

---

### Step 5 – Patient Identifier Creation
A unique MRN is assigned to the patient.

Identifier Type:
MRN2

Identifier Value:
MMRN-20260806-002

Status: PASS

---

### Step 6 – Patient Contact Creation
Primary mobile number is recorded for the patient.

Contact Type:
MOBILE (9000001002)

Status: PASS

---

### Step 7 – Patient Address Creation
Primary residential address is stored for the patient (Yerwaada, Pune, Maharashtra, INDIA - 411041).

Status: PASS

---

### Step 8 – Patient Registration (Visit)
A laboratory visit is created for the patient.

Registration Number:
REG003

Registration Status:
REGISTERED

Output:
Registration ID generated successfully.

Status: PASS

---

### Step 9 – Clinical Master Setup
Reference clinical entries are seeded (idempotent via `ON CONFLICT DO NOTHING`):

- DISEASE — `DIS001` Diabetes Mellitus
- SYMPTOM — `SYM001` Fever
- ALLERGY — `ALG001` Penicillin Allergy

Status: PASS

---

### Step 10 – Patient Clinical History
Three clinical history records are linked to the patient's registration:

- **Diabetes Mellitus** — status ACTIVE, notes "Known diabetic patient"
- **Fever** — status ACTIVE, severity MODERATE, duration 3 DAY, notes "Fever since last three days"
- **Penicillin Allergy** — status ACTIVE, notes "Patient allergic to Penicillin"

Status: PASS

---

### Step 11 – Billing Master
A bill is generated against the registration for test `CBC001` under billing category `PATH`.

Bill Number:
BILL0002

Initial Payment Status:
Pending

Status: PASS

---

### Step 12 – Billing Tests
The `CBC001` (Complete Blood Count) test is attached to the bill with rate, discount, and net amount computed from `test_master`.

Status: PASS

---

### Step 13 – Accession Creation
An accession is created against the bill and registration.

Accession Number:
ACC0003

Priority:
NORMAL

Initial Status:
PENDING

Status: PASS

---

### Step 14 – Accession Tests
An accession test record is created for `CBC001` with an auto-generated barcode, sample status `PENDING`, collection status `NOT_COLLECTED`, authorization status `PENDING`, and report status `PENDING`.

Status: PASS

---

### Step 15 – Payment
Full payment is captured against the bill/accession.

Payment Mode:
CASH

Transaction Reference:
TXN0001

Payment Status:
SUCCESS

Status: PASS

---

### Step 16 – Billing Update
The billing master record is updated to reflect the payment: `paid_amount` = `payable_amount`, `balance_amount` = 0, `payment_status` = Paid.

Status: PASS

---

### Step 17 – Sample Collection
The sample for the accessioned test is collected.

Quantity:
5 mL

Sample Condition:
GOOD

Collection Status:
COLLECTED

Status: PASS

---

### Step 18 – Accession Test Status Update
The accession test's `sample_status` and `collection_status` are updated to `COLLECTED` following sample collection.

Status: PASS

---

### Step 19 – Result Entry
A result entry is created for the accession test with status `COMPLETED`.

Status: PASS

---

### Step 20 – Result Entry Details
Result values are recorded for every parameter mapped to the test (8 CBC parameters — HCT, HGB, MCH, MCHC, MCV, PLT, RBC, WBC), each with value `10` and flag `NORMAL`.

Status: PASS

---

### Step 21 – Result Entry & Accession Test Completion
The result entry is confirmed `COMPLETED` and the accession test's `sample_status` is updated to `COMPLETED`.

Status: PASS

---

### Step 22 – Result Authorization
The result entry is authorized.

Result Status:
AUTHORIZED

The accession test's `authorization_status` is updated to `AUTHORIZED` accordingly.

Status: PASS

---

### Step 23 – Report Generation
A report is generated for the accession.

Report Number:
RPT-ACC0003

Report Status:
GENERATED

The accession test's `report_status` is updated to `READY`.

Status: PASS

---

## Validation Summary

The following entities were successfully created and progressed through their full lifecycle:

- Patient
- Patient Identifier
- Patient Contact
- Patient Address
- Patient Registration (Visit)
- Clinical Master (Disease, Symptom, Allergy)
- Patient Clinical History
- Billing Master
- Billing Tests
- Accession Master
- Accession Tests
- Payment
- Sample Collection
- Result Entry
- Result Entry Details
- Report Master

Full workflow coverage:
Registration → Clinical History → Billing → Accession → Payment → Sample Collection → Result Entry → Authorization → Report Generation.

All foreign-key relationships were maintained successfully, and idempotency guards (`ON CONFLICT` / `NOT EXISTS`) allow the script to be re-run safely.

The workflow executed without any constraint violations.

--output
\i database/e2e-validation/E001_patient_journey.sql
BEGIN
Admin User ID = 71a8f563-3e86-4505-8a0d-b4c642044444
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 0
INSERT 0 0
INSERT 0 0
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
UPDATE 1
INSERT 0 1
UPDATE 1
INSERT 0 1
INSERT 0 8
UPDATE 0
UPDATE 1
UPDATE 1
UPDATE 1
INSERT 0 1
UPDATE 1
COMMIT
                  id                  |           organization_id            |              branch_id               | patient_type | first_name | middle_name | last_name | gender | date_of_birth | patient_category | is_active |            created_at            |              created_by              |            updated_at            | updated_by | title | designation | nationality 
--------------------------------------+--------------------------------------+--------------------------------------+--------------+------------+-------------+-----------+--------+---------------+------------------+-----------+----------------------------------+--------------------------------------+----------------------------------+------------+-------+-------------+-------------
 f099a95f-0c36-439b-a064-ad211e2e1df6 | 4511ab2a-fac9-4bf9-ab93-91f695502c88 | 58f472a9-647c-4ff8-a760-d08b81bf1b66 | OUTPATIENT   | Manas      |             | Gaikwad   | Male   | 2005-01-01    | GENERAL          | t         | 2026-08-06 21:22:16.660494+05:30 | 71a8f563-3e86-4505-8a0d-b4c642044444 | 2026-08-06 21:22:16.660494+05:30 |            |       |             | 
(1 row)


                  id                  |           organization_id            |              branch_id               |              patient_id              | contact_type | contact_value | belongs_to | whatsapp_consent | is_primary |            created_at            |              created_by              |            updated_at            | updated_by 
--------------------------------------+--------------------------------------+--------------------------------------+--------------------------------------+--------------+---------------+------------+------------------+------------+----------------------------------+--------------------------------------+----------------------------------+------------
 5cdaf7d7-b28d-45c9-a0dc-6ad2e0967e6a | 4511ab2a-fac9-4bf9-ab93-91f695502c88 | 58f472a9-647c-4ff8-a760-d08b81bf1b66 | f099a95f-0c36-439b-a064-ad211e2e1df6 | MOBILE       | 9000001002    |            | t                | t          | 2026-08-06 21:22:16.660494+05:30 | 71a8f563-3e86-4505-8a0d-b4c642044444 | 2026-08-06 21:22:16.660494+05:30 | 
(1 row)


                  id                  |           organization_id            |              branch_id               |              patient_id              | address_type | address_line1 | address_line2 | city | district |    state    | country | pincode | is_primary |            created_at            |              created_by              |            updated_at            | updated_by 
--------------------------------------+--------------------------------------+--------------------------------------+--------------------------------------+--------------+---------------+---------------+------+----------+-------------+---------+---------+------------+----------------------------------+--------------------------------------+----------------------------------+------------
 fcff6627-b84d-4041-b5ad-1d13c2cb78f7 | 4511ab2a-fac9-4bf9-ab93-91f695502c88 | 58f472a9-647c-4ff8-a760-d08b81bf1b66 | f099a95f-0c36-439b-a064-ad211e2e1df6 | HOME         | Yerwaada      |               | Pune | PUNE     | Maharashtra | INDIA   | 411041  | t          | 2026-08-06 21:22:16.660494+05:30 | 71a8f563-3e86-4505-8a0d-b4c642044444 | 2026-08-06 21:22:16.660494+05:30 | 
(1 row)


                  id                  |           organization_id            |              branch_id               |              patient_id              | identifier_type | identifier_value  | is_primary |            created_at            
--------------------------------------+--------------------------------------+--------------------------------------+--------------------------------------+-----------------+-------------------+------------+----------------------------------
 3420ef41-7db2-46db-9c1d-812b1ba85b83 | 4511ab2a-fac9-4bf9-ab93-91f695502c88 | 58f472a9-647c-4ff8-a760-d08b81bf1b66 | f099a95f-0c36-439b-a064-ad211e2e1df6 | MRN2            | MMRN-20260806-002 | t          | 2026-08-06 21:22:16.660494+05:30
(1 row)


                  id                  |           organization_id            |              branch_id               |              patient_id              | registration_number | registration_status |          registered_at           |              created_by              |            created_at            | client_id | referral_doctor_id | agent_id | membership_id | is_home_collection 
--------------------------------------+--------------------------------------+--------------------------------------+--------------------------------------+---------------------+---------------------+----------------------------------+--------------------------------------+----------------------------------+-----------+--------------------+----------+---------------+--------------------
 7d9c0005-576b-4e23-8cc0-3c982de1eabc | 4511ab2a-fac9-4bf9-ab93-91f695502c88 | 58f472a9-647c-4ff8-a760-d08b81bf1b66 | f099a95f-0c36-439b-a064-ad211e2e1df6 | REG003              | REGISTERED          | 2026-08-06 21:22:16.660494+05:30 | 71a8f563-3e86-4505-8a0d-b4c642044444 | 2026-08-06 21:22:16.660494+05:30 |           |                    |          |               | f
(1 row)


                  id                  |           organization_id            |              branch_id               | clinical_type |  clinical_code  |             clinical_name             |                     description                     | is_active |            created_at            |              created_by              |            updated_at            | updated_by 
--------------------------------------+--------------------------------------+--------------------------------------+---------------+-----------------+---------------------------------------+-----------------------------------------------------+-----------+----------------------------------+--------------------------------------+----------------------------------+------------
 3de72dd0-b381-4fa4-8fe1-736ea8509e66 | 4511ab2a-fac9-4bf9-ab93-91f695502c88 | 58f472a9-647c-4ff8-a760-d08b81bf1b66 | ALLERGY       | ALG001          | Penicillin Allergy                    | Drug Allergy                                        | t         | 2026-08-01 16:09:02.140668+05:30 | 71a8f563-3e86-4505-8a0d-b4c642044444 | 2026-08-01 16:09:02.140668+05:30 | 
 ff542500-3a39-4a3e-8715-9f04fddd290d | 4511ab2a-fac9-4bf9-ab93-91f695502c88 | 58f472a9-647c-4ff8-a760-d08b81bf1b66 | CONDITION     | MC-TEST-001     | Dry Run Hypertension                  | Dummy medical condition for F001 validation         | t         | 2026-08-01 16:15:00.2998+05:30   | 71a8f563-3e86-4505-8a0d-b4c642044444 | 2026-08-01 16:15:00.2998+05:30   | 
 d0254c86-967e-4b5f-ba01-fac20dbcd2ad | 33a6bf08-2efe-4b2c-904f-41b2412e0cb8 | ca1ec92e-31c9-4b5c-ad79-8e2bcad55328 | CONDITION     | MC-DRYRUN-001   | Dry Run Hypertension                  | Dummy medical condition for F001 Phase 2 validation | t         | 2026-08-05 17:59:44.701978+05:30 | 78974ff2-a73a-4cf5-9b37-56669db345e2 | 2026-08-05 17:59:44.701978+05:30 | 
 a6d10a50-0080-4dfa-ace8-b2db8d941160 | 4511ab2a-fac9-4bf9-ab93-91f695502c88 | 58f472a9-647c-4ff8-a760-d08b81bf1b66 | DISEASE       | DIS001          | Diabetes Mellitus                     | type 2 diabetes                                     | t         | 2026-08-01 16:09:02.140668+05:30 | 71a8f563-3e86-4505-8a0d-b4c642044444 | 2026-08-01 16:09:02.140668+05:30 |                                                     
 3b68a845-5830-4051-bac7-13d25e17af8c | 4511ab2a-fac9-4bf9-ab93-91f695502c88 | 58f472a9-647c-4ff8-a760-d08b81bf1b66 | DISEASE       | DM-TEST-001     | Dry Run Diabetes                      | Dummy disease created for F001 Phase 2 validation   | t         | 2026-08-01 16:15:00.2998+05:30   | 71a8f563-3e86-4505-8a0d-b4c642044444 | 2026-08-01 16:15:00.2998+05:30   |                                                     
 8502b1d0-0845-472b-834f-208e880a65fa | 33a6bf08-2efe-4b2c-904f-41b2412e0cb8 | ca1ec92e-31c9-4b5c-ad79-8e2bcad55328 | DISEASE       | DIS-DRYRUN-001  | Dry Run Diabetes                      | Dummy disease created for F001 Phase 2 validation   | t         | 2026-08-05 17:59:44.701978+05:30 | 78974ff2-a73a-4cf5-9b37-56669db345e2 | 2026-08-05 17:59:44.701978+05:30 |                                                     
 01713a95-597d-49ef-9142-3e765f8cf7f7 | 33a6bf08-2efe-4b2c-904f-41b2412e0cb8 | ca1ec92e-31c9-4b5c-ad79-8e2bcad55328 | DISEASE       | CH-UPD-TEST-001 | Dry Run Update Test Disease - Updated | Updated during CH008 dry run                        | t         | 2026-08-05 18:00:17.7402+05:30   | 78974ff2-a73a-4cf5-9b37-56669db345e2 | 2026-08-05 18:00:17.7402+05:30   |                                                     
 8094da74-7062-44f2-bbe2-699fe86c0f56 | 4511ab2a-fac9-4bf9-ab93-91f695502c88 | 58f472a9-647c-4ff8-a760-d08b81bf1b66 | SYMPTOM       | SYM-TEST-001    | Dry Run Fever                         | Dummy symptom created for F001 validation           | t         | 2026-08-01 16:15:00.2998+05:30   | 71a8f563-3e86-4505-8a0d-b4c642044444 | 2026-08-01 16:15:00.2998+05:30   |                                                     
 b9d5fb8d-bf06-413f-b094-38b422366d03 | 33a6bf08-2efe-4b2c-904f-41b2412e0cb8 | ca1ec92e-31c9-4b5c-ad79-8e2bcad55328 | SYMPTOM       | SYM-DRYRUN-001  | Dry Run Fever                         | Dummy symptom created for F001 Phase 2 validation   | t         | 2026-08-05 17:59:44.701978+05:30 | 78974ff2-a73a-4cf5-9b37-56669db345e2 | 2026-08-05 17:59:44.701978+05:30 |                                                     
 4dd6afd1-c54a-4a91-ac0a-a2951017e644 | 4511ab2a-fac9-4bf9-ab93-91f695502c88 | 58f472a9-647c-4ff8-a760-d08b81bf1b66 | SYMPTOM       | SYM001          | Fever                                 | High body temperature                               | t         | 2026-08-01 16:09:02.140668+05:30 | 71a8f563-3e86-4505-8a0d-b4c642044444 | 2026-08-01 16:09:02.140668+05:30 |                                                     
(10 rows)                                                                                                                                  
                                                                                                                                           
                                                                                                                                           
 first_name | last_name | clinical_type |   clinical_name    | status | severity | duration_value | duration_unit |             notes              
------------+-----------+---------------+--------------------+--------+----------+----------------+---------------+--------------------------------
 Manas      | Gaikwad   | ALLERGY       | Penicillin Allergy | ACTIVE |          |                |               | Patient allergic to Penicillin
 Manas      | Gaikwad   | DISEASE       | Diabetes Mellitus  | ACTIVE |          |                |               | Known diabetic patient
 Manas      | Gaikwad   | SYMPTOM       | Fever              | ACTIVE | MODERATE |              3 | DAY           | Fever since last three days
(3 rows)


 organization_code | bill_number | registration_number | total_amount | payable_amount | payment_status                                    
-------------------+-------------+---------------------+--------------+----------------+----------------
 LAB002            | BILL0002    | REG003              |       350.00 |         350.00 | Paid
(1 row)


 organization_code | test_code |      test_name       |  rate  | net_amount | status                                                       
-------------------+-----------+----------------------+--------+------------+---------
 LAB002            | CBC001    | Complete Blood Count | 350.00 |     350.00 | Pending
(1 row)


 organization_code | accession_number | priority | status                                                                                  
-------------------+------------------+----------+---------
 LAB002            | ACC0003          | NORMAL   | PENDING
(1 row)


 organization_code | test_code |      test_name       |       barcode       | sample_status | collection_status | authorization_status | report_status 
-------------------+-----------+----------------------+---------------------+---------------+-------------------+----------------------+---------------
 LAB002            | CBC001    | Complete Blood Count | BC20260806212216660 | COMPLETED     | COLLECTED         | AUTHORIZED           | READY
(1 row)


 organization_code | accession_number | test_code |      test_name       |       collection_datetime        |   collection_location    | sample_condition | quantity | quantity_unit | collection_status | collector 
-------------------+------------------+-----------+----------------------+----------------------------------+--------------------------+------------------+----------+---------------+-------------------+-----------
 LAB002            | ACC0003          | CBC001    | Complete Blood Count | 2026-08-06 21:22:16.660494+05:30 | Sample Collection Center | GOOD             |     5.00 | mL            | COLLECTED         | admin
(1 row)


 organization_code | accession_number |       barcode       | sample_status | collection_status | authorization_status | report_status     
-------------------+------------------+---------------------+---------------+-------------------+----------------------+---------------
 LAB002            | ACC0003          | BC20260806212216660 | COMPLETED     | COLLECTED         | AUTHORIZED           | READY
(1 row)


 organization_code | accession_number | test_code |      test_name       | result_status | parameter_count                                 
-------------------+------------------+-----------+----------------------+---------------+-----------------
 LAB002            | ACC0003          | CBC001    | Complete Blood Count | AUTHORIZED    |               8
(1 row)


 parameter_code |              parameter_name               | result_value | result_flag                                                   
----------------+-------------------------------------------+--------------+-------------
 HCT            | Hematocrit                                | 10           | NORMAL
 HGB            | Hemoglobin                                | 10           | NORMAL
 MCH            | Mean Corpuscular Hemoglobin               | 10           | NORMAL
 MCHC           | Mean Corpuscular Hemoglobin Concentration | 10           | NORMAL
 MCV            | Mean Corpuscular Volume                   | 10           | NORMAL
 PLT            | Platelet Count                            | 10           | NORMAL
 RBC            | Red Blood Cell                            | 10           | NORMAL
 WBC            | White Blood Cell                          | 10           | NORMAL
(8 rows)


 organization_code | accession_number | report_number | report_status | report_status |           generated_at           | generated_by    
-------------------+------------------+---------------+---------------+---------------+----------------------------------+--------------
 LAB002            | ACC0003          | RPT-ACC0003   | GENERATED     | READY         | 2026-08-06 21:22:16.660494+05:30 | admin
(1 row)


                        status                                                                                                             
-------------------------------------------------------
 Patient Journey E2E Validation Completed Successfully
(1 row)


 organization_code |                  id                                                                                                   
-------------------+--------------------------------------
 LAB002            | 4511ab2a-fac9-4bf9-ab93-91f695502c88
 DEMO-LAB          | 33a6bf08-2efe-4b2c-904f-41b2412e0cb8
 DEMO-LAB 2        | 45e92f65-ce43-4ba6-9f21-9ca17b2dfe3a
(3 rows)
