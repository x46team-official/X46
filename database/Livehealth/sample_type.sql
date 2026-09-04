SELECT DISTINCT s.sample_type
FROM staging_livehealth_tests s
WHERE s.sample_type IS NOT NULL
  AND TRIM(s.sample_type) <> ''
  AND NOT EXISTS (
      SELECT 1
      FROM sample_type_master st
      WHERE LOWER(TRIM(st.sample_name)) =
            LOWER(TRIM(s.sample_type))
  );

INSERT INTO sample_type_master (
    organization_id,
    sample_code,
    sample_name,
    print_name,
    container_type,
    is_active,
    created_at
)
SELECT DISTINCT
    (SELECT id FROM organizations LIMIT 1),

    LEFT(
        UPPER(REGEXP_REPLACE(TRIM(s.sample_type), '[^A-Za-z0-9]', '', 'g')),
        30
    ) AS sample_code,

    TRIM(s.sample_type) AS sample_name,

    TRIM(s.sample_type) AS print_name,

    TRIM(s.container_type),

    TRUE,

    CURRENT_TIMESTAMP

FROM staging_livehealth_tests s

WHERE s.sample_type IS NOT NULL
  AND TRIM(s.sample_type) <> ''

AND NOT EXISTS (
    SELECT 1
    FROM sample_type_master st
    WHERE LOWER(TRIM(st.sample_name)) =
          LOWER(TRIM(s.sample_type))
);