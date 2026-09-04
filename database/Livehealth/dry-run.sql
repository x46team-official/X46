INSERT INTO test_category_master (
    organization_id,
    category_name,
    category_code,
    is_active,
    created_at
)
SELECT DISTINCT
    (SELECT id FROM organizations LIMIT 1),
    TRIM(s.test_category),
    LEFT(
        UPPER(REGEXP_REPLACE(TRIM(s.test_category), '[^A-Za-z0-9]', '', 'g')),
        30
    ),
    TRUE,
    CURRENT_TIMESTAMP
FROM staging_livehealth_tests s
WHERE s.test_category IS NOT NULL
  AND TRIM(s.test_category) <> ''
  AND NOT EXISTS (
      SELECT 1
      FROM test_category_master t
      WHERE LOWER(TRIM(t.category_name)) =
            LOWER(TRIM(s.test_category))
  );