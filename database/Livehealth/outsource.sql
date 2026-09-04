INSERT INTO outsource_center_master (
    organization_id,
    center_code,
    center_name,
    is_active,
    created_at
)
SELECT DISTINCT
    (SELECT id FROM organizations LIMIT 1),

    LEFT(
        UPPER(
            REGEXP_REPLACE(TRIM(s.outsource_center), '[^A-Za-z0-9]', '', 'g')
        ),
        30
    ) AS center_code,

    TRIM(s.outsource_center) AS center_name,

    TRUE,

    CURRENT_TIMESTAMP

FROM staging_livehealth_tests s

WHERE s.outsource_center IS NOT NULL
  AND TRIM(s.outsource_center) <> ''
  AND TRIM(s.outsource_center) <> '-'

AND NOT EXISTS (
    SELECT 1
    FROM outsource_center_master oc
    WHERE LOWER(TRIM(oc.center_name)) =
          LOWER(TRIM(s.outsource_center))
);