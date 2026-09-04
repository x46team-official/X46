INSERT INTO container_type_master (
    organization_id,
    container_name,
    is_active,
    created_at
)
SELECT DISTINCT
    (SELECT id FROM organizations LIMIT 1),
    TRIM(s.container_type),
    TRUE,
    CURRENT_TIMESTAMP
FROM staging_livehealth_tests s
WHERE s.container_type IS NOT NULL
  AND TRIM(s.container_type) <> ''
  AND TRIM(s.container_type) <> '-'
  AND NOT EXISTS (
      SELECT 1
      FROM container_type_master ct
      WHERE LOWER(TRIM(ct.container_name)) =
            LOWER(TRIM(s.container_type))
  );