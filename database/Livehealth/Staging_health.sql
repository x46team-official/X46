CREATE TABLE staging_livehealth_results (
    patient_id BIGINT,
    lab_bill_id BIGINT,
    order_number TEXT,
    sex TEXT,
    contact TEXT,
    dob TEXT,
    patient_name TEXT,
    mrn TEXT,
    test_name TEXT,
    department_name TEXT,
    bill_time TEXT,
    report_date TEXT,
    sample_date TEXT,
    accession_number BIGINT,
    email_id TEXT,
    dictionary_name TEXT,
    reported_by TEXT,
    parameter_type TEXT,
    reference_range TEXT,
    accession_date TEXT,
    approval_date TEXT,
    parameter_name TEXT,
    value TEXT,
    referral_name TEXT,
    abnormal TEXT
);

\copy staging_livehealth_results FROM 'database/Livehealth/Test-Values-Export 24-07-2026.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');