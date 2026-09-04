ALTER TABLE patients
ADD COLUMN title VARCHAR(20),
ADD COLUMN designation VARCHAR(100),
ADD COLUMN nationality VARCHAR(100);

ALTER TABLE patient_registrations
ADD COLUMN client_id UUID,
ADD COLUMN referral_doctor_id UUID,
ADD COLUMN agent_id UUID,
ADD COLUMN membership_id UUID,
ADD COLUMN is_home_collection BOOLEAN DEFAULT FALSE;