WITH org AS (
    SELECT
        o.id,
        b.id AS branch_id
    FROM organizations o
    JOIN branches b
        ON b.organization_id = o.id
    WHERE o.organization_code = 'DEMO-LAB'
      AND b.branch_code = 'PUNE-01'
    LIMIT 1
)
INSERT INTO test_category_master (
    organization_id,
    branch_id,
    category_code,
    category_name,
    description,
    display_order
)
SELECT
    org.id,
    org.branch_id,
    v.category_code,
    v.category_name,
    v.description,
    v.display_order
FROM org
CROSS JOIN (
    VALUES
        ('BIO', 'Biochemistry', 'Biochemistry Tests', 1),
        ('HEM', 'Hematology', 'Hematology Tests', 2)
) AS v(category_code, category_name, description, display_order);

SELECT * FROM test_category_master;
