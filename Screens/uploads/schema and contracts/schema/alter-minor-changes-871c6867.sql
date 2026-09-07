SELECT DISTINCT s.test_category
FROM staging_livehealth_tests s
WHERE s.test_category IS NOT NULL
  AND TRIM(s.test_category) <> ''
  AND NOT EXISTS (
      SELECT 1
      FROM test_category_master t
      WHERE LOWER(TRIM(t.category_name)) =
            LOWER(TRIM(s.test_category))
  );

SELECT DISTINCT s.test_category
FROM staging_livehealth_tests s
LEFT JOIN test_category_master t
ON LOWER(TRIM(s.test_category)) = LOWER(TRIM(t.category_name))
WHERE t.id IS NULL
  AND s.test_category IS NOT NULL
  AND TRIM(s.test_category) <> '';