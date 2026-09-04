INSERT INTO migration_errors(
accession_number,
test_name,
parameter_name,
error_message
)

SELECT

accession_number,

test_name,

parameter_name,

'Test not found'

FROM staging_livehealth_results s

LEFT JOIN test_master tm
ON upper(trim(s.test_name))
=
upper(trim(tm.test_name))

WHERE tm.id IS NULL;