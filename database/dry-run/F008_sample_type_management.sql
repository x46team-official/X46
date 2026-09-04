INSERT INTO sample_type_master (
    organization_id,
    branch_id,
    sample_code,
    sample_name,
    print_name,
    container_type,
    container_color,
    minimum_volume,
    volume_unit
)
SELECT
    o.id,
    b.id,
    v.sample_code,
    v.sample_name,
    v.print_name,
    v.container_type,
    v.container_color,
    v.minimum_volume,
    v.volume_unit
FROM organizations o
JOIN branches b
    ON b.organization_id = o.id
CROSS JOIN (
    VALUES
        ('BLD', 'Blood', 'Blood', 'Vacutainer', 'Purple', 2, 'ml'),
        ('SER', 'Serum', 'Serum', 'Plain Tube', 'Red', 2, 'ml'),
        ('PLA', 'Plasma', 'Plasma', 'Fluoride Tube', 'Grey', 2, 'ml'),
        ('URN', 'Urine', 'Urine', 'Urine Container', 'Yellow', 10, 'ml'),
        ('STL', 'Stool', 'Stool', 'Stool Container', 'White', 5, 'gm'),
        ('SPT', 'Sputum', 'Sputum', 'Sterile Container', 'Transparent', 2, 'ml'),
        ('CSF', 'CSF', 'CSF', 'Sterile Tube', 'Transparent', 1, 'ml'),
        ('SWB', 'Swab', 'Swab', 'Swab Kit', 'Blue', 1, 'piece')
) AS v(
    sample_code,
    sample_name,
    print_name,
    container_type,
    container_color,
    minimum_volume,
    volume_unit
)
WHERE o.organization_code = 'DEMO-LAB'
  AND b.branch_code = 'PUNE-01';
