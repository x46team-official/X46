INSERT INTO test_master (
    organization_id,
    department_id,
    test_category_id,
    sample_type_id,
    container_type_id,
    outsource_center_id,
    test_code,
    test_name,
    display_name,
    print_name,
    short_code,
    selling_price,
    cost_price,
    cprr,
    tat_minutes,
    machine_test_code,
    nabl_accredited,
    outsource_test,
    automatically_authorize,
    is_active,
    created_at,
    updated_at
)

SELECT
    org.id,
    d.id,
    tc.id,
    st.id,
    ct.id,
    oc.id,

    TRIM(s.test_code),
    TRIM(s.test_name),

    NULLIF(TRIM(s.short_text),''),
    NULLIF(TRIM(s.short_text),''),

    TRIM(s.test_code),

    ----
    -- Selling Price
    ----
    CASE
        WHEN s.test_amount IS NULL THEN 0
        WHEN REGEXP_REPLACE(COALESCE(s.test_amount,''),'[^0-9.]','','g')='' THEN 0
        ELSE REGEXP_REPLACE(s.test_amount,'[^0-9.]','','g')::numeric
    END,

    ----
    -- Cost Price
    ----
    CASE
        WHEN s.outsource_amount IS NULL THEN 0
        WHEN REGEXP_REPLACE(COALESCE(s.outsource_amount,''),'[^0-9.]','','g')='' THEN 0
        ELSE REGEXP_REPLACE(s.outsource_amount,'[^0-9.]','','g')::numeric
    END,

    0,

    ----
    -- TAT
    ----
    CASE

        WHEN s.target_tat IS NULL
             OR TRIM(s.target_tat)=''
             OR TRIM(s.target_tat)='-'
        THEN 0

        WHEN LOWER(s.target_tat) LIKE '%day%'
        THEN (
            REGEXP_REPLACE(s.target_tat,'[^0-9.]','','g')::numeric
            *24*60
        )::int

        WHEN LOWER(s.target_tat) LIKE '%hr%'
        THEN (
            REGEXP_REPLACE(s.target_tat,'[^0-9.]','','g')::numeric
            *60
        )::int

        ELSE
            COALESCE(
                NULLIF(
                    REGEXP_REPLACE(s.target_tat,'[^0-9.]','','g'),
                    ''
                )::numeric,
                0
            )::int

    END,

    NULLIF(TRIM(s.integration_code),''),

    ----
    -- NABL
    ----
    CASE
        WHEN LOWER(COALESCE(s.accreditation,'')) LIKE '%nabl%'
        THEN TRUE
        ELSE FALSE
    END,

    ----
    -- Outsource
    ----
    CASE
        WHEN s.outsource_center IS NULL
          OR TRIM(s.outsource_center)=''
          OR TRIM(s.outsource_center)='-'
        THEN FALSE
        ELSE TRUE
    END,

    ----
    -- Verification
    ----
    CASE
        WHEN LOWER(COALESCE(s.verification_status,'')) IN
        ('verified','approved','yes','true')
        THEN TRUE
        ELSE FALSE
    END,

    TRUE,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP

FROM staging_livehealth_tests s

CROSS JOIN (
    SELECT id
    FROM organizations
    LIMIT 1
) org

JOIN department_master d
ON LOWER(TRIM(d.department_name))
 =
LOWER(TRIM(s.department_name))

LEFT JOIN test_category_master tc
ON LOWER(TRIM(tc.category_name))
 =
LOWER(TRIM(s.test_category))

LEFT JOIN sample_type_master st
ON LOWER(TRIM(st.sample_name))
 =
LOWER(TRIM(s.sample_type))

LEFT JOIN container_type_master ct
ON LOWER(TRIM(ct.container_name))
 =
LOWER(TRIM(s.container_type))

LEFT JOIN outsource_center_master oc
ON LOWER(TRIM(oc.center_name))
 =
LOWER(TRIM(s.outsource_center))

WHERE NOT EXISTS (

    SELECT 1
    FROM test_master tm

    WHERE tm.organization_id=org.id
      AND LOWER(tm.test_code)=LOWER(TRIM(s.test_code))

)

ORDER BY s.test_name

LIMIT 10;