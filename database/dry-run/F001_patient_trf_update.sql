-- Verify Before Update

SELECT
    trf_number,
    trf_file_url,
    remarks,
    is_active
FROM patient_trf
ORDER BY uploaded_at DESC
LIMIT 1;

-- Update TRF

UPDATE patient_trf
SET
    trf_file_url = 'https://updated.example.com/trf_updated.pdf',
    remarks = 'TRF Updated - Dry Run'
WHERE id =
(
    SELECT id
    FROM patient_trf
    ORDER BY uploaded_at DESC
    LIMIT 1
);

-- Verify

SELECT
    trf_number,
    trf_file_url,
    remarks
FROM patient_trf
WHERE id =
(
    SELECT id
    FROM patient_trf
    ORDER BY uploaded_at DESC
    LIMIT 1
);

-- Verify Before Cancel

SELECT
    trf_number,
    is_active
FROM patient_trf
ORDER BY uploaded_at DESC
LIMIT 1;

-- Cancel TRF

UPDATE patient_trf
SET
    is_active = FALSE,
    remarks = 'TRF Cancelled - Dry Run'
WHERE id =
(
    SELECT id
    FROM patient_trf
    ORDER BY uploaded_at DESC
    LIMIT 1
);

-- Verify

SELECT
    trf_number,
    is_active,
    remarks
FROM patient_trf
WHERE id =
(
    SELECT id
    FROM patient_trf
    ORDER BY uploaded_at DESC
    LIMIT 1
);
