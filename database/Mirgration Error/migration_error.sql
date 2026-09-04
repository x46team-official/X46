CREATE TABLE migration_errors(

id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

accession_number BIGINT,

test_name TEXT,

parameter_name TEXT,

error_message TEXT,

created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP

);