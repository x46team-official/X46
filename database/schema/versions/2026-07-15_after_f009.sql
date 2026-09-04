--
-- PostgreSQL database dump
--

\restrict psXVtFJo0XO3FlWBTlVBIoOkeHZxIFDQNX5w6CYUecDCXB0LTYe09QI2J7gnqKX

-- Dumped from database version 18.4
-- Dumped by pg_dump version 18.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: appointment_assignments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.appointment_assignments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    appointment_id uuid NOT NULL,
    assigned_to uuid NOT NULL,
    assignment_role character varying(50),
    assigned_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    assigned_status character varying(50) DEFAULT 'ASSIGNED'::character varying,
    remarks text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid
);


ALTER TABLE public.appointment_assignments OWNER TO postgres;

--
-- Name: appointment_status_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.appointment_status_history (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    appointment_id uuid NOT NULL,
    status character varying(50) NOT NULL,
    remarks text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid
);


ALTER TABLE public.appointment_status_history OWNER TO postgres;

--
-- Name: appointment_tests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.appointment_tests (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    appointment_id uuid NOT NULL,
    test_code character varying(50),
    test_name character varying(200) NOT NULL,
    department character varying(100),
    priority character varying(50) DEFAULT 'NORMAL'::character varying NOT NULL,
    remarks text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid
);


ALTER TABLE public.appointment_tests OWNER TO postgres;

--
-- Name: appointment_type_master; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.appointment_type_master (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    appointment_type_code character varying(30),
    appointment_type_name character varying(100) NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid
);


ALTER TABLE public.appointment_type_master OWNER TO postgres;

--
-- Name: appointments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.appointments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    registration_id uuid,
    appointment_type_id uuid,
    appointment_number character varying(100) NOT NULL,
    appointment_date date NOT NULL,
    appointment_time time without time zone NOT NULL,
    appointment_status character varying(50) DEFAULT 'BOOKED'::character varying NOT NULL,
    remarks text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid
);


ALTER TABLE public.appointments OWNER TO postgres;

--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audit_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid,
    user_id uuid,
    action_type character varying(50) NOT NULL,
    entity_type character varying(100) NOT NULL,
    entity_id uuid,
    old_values jsonb,
    new_values jsonb,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.audit_logs OWNER TO postgres;

--
-- Name: branches; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.branches (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_code character varying(50) NOT NULL,
    branch_name character varying(200) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.branches OWNER TO postgres;

--
-- Name: department_master; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.department_master (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    department_name character varying(100) NOT NULL,
    department_code character varying(30),
    description text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid
);


ALTER TABLE public.department_master OWNER TO postgres;

--
-- Name: disease_master; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.disease_master (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    disease_code character varying(50),
    disease_name character varying(200) NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid
);


ALTER TABLE public.disease_master OWNER TO postgres;

--
-- Name: medical_condition_master; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.medical_condition_master (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    condition_code character varying(50),
    condition_name character varying(200) NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid
);


ALTER TABLE public.medical_condition_master OWNER TO postgres;

--
-- Name: organizations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.organizations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_code character varying(50) NOT NULL,
    organization_name character varying(200) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.organizations OWNER TO postgres;

--
-- Name: outsource_center_master; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.outsource_center_master (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    center_code character varying(30) NOT NULL,
    center_name character varying(100) NOT NULL,
    contact_person character varying(150),
    phone_number character varying(20),
    email character varying(100),
    address text,
    city character varying(100),
    state character varying(100),
    country character varying(100),
    pincode character varying(20),
    gst_number character varying(30),
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    update_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid
);


ALTER TABLE public.outsource_center_master OWNER TO postgres;

--
-- Name: patient_addresses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_addresses (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    patient_id uuid NOT NULL,
    address_type character varying(50),
    address_line1 character varying(255),
    address_line2 character varying(255),
    city character varying(100),
    district character varying(100),
    state character varying(100),
    country character varying(100),
    pincode character varying(20),
    is_primary boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid
);


ALTER TABLE public.patient_addresses OWNER TO postgres;

--
-- Name: patient_contacts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_contacts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    patient_id uuid NOT NULL,
    contact_type character varying(30) NOT NULL,
    contact_value character varying(255) NOT NULL,
    belongs_to character varying(100),
    whatsapp_consent boolean DEFAULT false NOT NULL,
    is_primary boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid
);


ALTER TABLE public.patient_contacts OWNER TO postgres;

--
-- Name: patient_diseases; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_diseases (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    patient_id uuid NOT NULL,
    disease_id uuid NOT NULL,
    diagnosed_date date,
    disease_status character varying(50) DEFAULT 'ACTIVE'::character varying NOT NULL,
    notes text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid
);


ALTER TABLE public.patient_diseases OWNER TO postgres;

--
-- Name: patient_identifiers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_identifiers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    patient_id uuid NOT NULL,
    identifier_type character varying(50) NOT NULL,
    identifier_value character varying(200) NOT NULL,
    is_primary boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.patient_identifiers OWNER TO postgres;

--
-- Name: patient_medical_conditions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_medical_conditions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    patient_id uuid NOT NULL,
    condition_id uuid NOT NULL,
    diagnosed_date date,
    condition_status character varying(50) DEFAULT 'ACTIVE'::character varying NOT NULL,
    notes text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid
);


ALTER TABLE public.patient_medical_conditions OWNER TO postgres;

--
-- Name: patient_photos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_photos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    photo_url text NOT NULL,
    is_primary boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid
);


ALTER TABLE public.patient_photos OWNER TO postgres;

--
-- Name: patient_registrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_registrations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    registration_number character varying(100) NOT NULL,
    registration_status character varying(50) DEFAULT 'REGISTERED'::character varying NOT NULL,
    registered_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    client_id uuid,
    referral_doctor_id uuid,
    agent_id uuid,
    membership_id uuid,
    is_home_collection boolean DEFAULT false
);


ALTER TABLE public.patient_registrations OWNER TO postgres;

--
-- Name: patient_trf; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patient_trf (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    registration_id uuid NOT NULL,
    trf_number character varying(50),
    trf_file_url text NOT NULL,
    uploaded_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    uploaded_by uuid,
    remarks text,
    is_active boolean DEFAULT true
);


ALTER TABLE public.patient_trf OWNER TO postgres;

--
-- Name: patients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.patients (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    patient_type character varying(50),
    first_name character varying(100) NOT NULL,
    middle_name character varying(100),
    last_name character varying(100),
    gender character varying(30),
    date_of_birth date,
    patient_category character varying(100),
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid,
    title character varying(20),
    designation character varying(100),
    nationality character varying(100)
);


ALTER TABLE public.patients OWNER TO postgres;

--
-- Name: registration_clinical_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.registration_clinical_history (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    registration_id uuid NOT NULL,
    clinical_history text NOT NULL,
    recorded_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid
);


ALTER TABLE public.registration_clinical_history OWNER TO postgres;

--
-- Name: registration_symptoms; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.registration_symptoms (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    registration_id uuid NOT NULL,
    symptom_id uuid NOT NULL,
    severity character varying(30),
    duration_value integer,
    duration_unit character varying(30),
    notes text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid
);


ALTER TABLE public.registration_symptoms OWNER TO postgres;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    role_code character varying(50) NOT NULL,
    role_name character varying(100) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: sample_type_master; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sample_type_master (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    sample_code character varying(30) NOT NULL,
    sample_name character varying(100) NOT NULL,
    print_name character varying(100),
    description text,
    container_type character varying(100),
    container_color character varying(50),
    minimum_volume numeric(10,2),
    volume_unit character varying(20),
    storage_temperature character varying(50),
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid
);


ALTER TABLE public.sample_type_master OWNER TO postgres;

--
-- Name: symptom_master; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.symptom_master (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    symptom_code character varying(50),
    symptom_name character varying(200) NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid
);


ALTER TABLE public.symptom_master OWNER TO postgres;

--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_roles (
    user_id uuid NOT NULL,
    role_id uuid NOT NULL,
    assigned_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.user_roles OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid,
    username character varying(100) NOT NULL,
    email character varying(255),
    password_hash text NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100),
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: worksheet_master; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.worksheet_master (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    worksheet_code character varying(30) NOT NULL,
    worksheet_name character varying(100) NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid
);


ALTER TABLE public.worksheet_master OWNER TO postgres;

--
-- Name: appointment_assignments appointment_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointment_assignments
    ADD CONSTRAINT appointment_assignments_pkey PRIMARY KEY (id);


--
-- Name: appointment_status_history appointment_status_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointment_status_history
    ADD CONSTRAINT appointment_status_history_pkey PRIMARY KEY (id);


--
-- Name: appointment_tests appointment_tests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointment_tests
    ADD CONSTRAINT appointment_tests_pkey PRIMARY KEY (id);


--
-- Name: appointment_type_master appointment_type_master_organization_id_appointment_type_na_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointment_type_master
    ADD CONSTRAINT appointment_type_master_organization_id_appointment_type_na_key UNIQUE (organization_id, appointment_type_name);


--
-- Name: appointment_type_master appointment_type_master_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointment_type_master
    ADD CONSTRAINT appointment_type_master_pkey PRIMARY KEY (id);


--
-- Name: appointments appointments_organization_id_appointment_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_organization_id_appointment_number_key UNIQUE (organization_id, appointment_number);


--
-- Name: appointments appointments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_pkey PRIMARY KEY (id);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: branches branches_organization_id_branch_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.branches
    ADD CONSTRAINT branches_organization_id_branch_code_key UNIQUE (organization_id, branch_code);


--
-- Name: branches branches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.branches
    ADD CONSTRAINT branches_pkey PRIMARY KEY (id);


--
-- Name: department_master department_master_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.department_master
    ADD CONSTRAINT department_master_pkey PRIMARY KEY (id);


--
-- Name: disease_master disease_master_organization_id_disease_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.disease_master
    ADD CONSTRAINT disease_master_organization_id_disease_name_key UNIQUE (organization_id, disease_name);


--
-- Name: disease_master disease_master_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.disease_master
    ADD CONSTRAINT disease_master_pkey PRIMARY KEY (id);


--
-- Name: medical_condition_master medical_condition_master_organization_id_condition_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medical_condition_master
    ADD CONSTRAINT medical_condition_master_organization_id_condition_name_key UNIQUE (organization_id, condition_name);


--
-- Name: medical_condition_master medical_condition_master_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medical_condition_master
    ADD CONSTRAINT medical_condition_master_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_organization_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_organization_code_key UNIQUE (organization_code);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: outsource_center_master outsource_center_master_organization_id_center_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.outsource_center_master
    ADD CONSTRAINT outsource_center_master_organization_id_center_code_key UNIQUE (organization_id, center_code);


--
-- Name: outsource_center_master outsource_center_master_organization_id_center_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.outsource_center_master
    ADD CONSTRAINT outsource_center_master_organization_id_center_name_key UNIQUE (organization_id, center_name);


--
-- Name: outsource_center_master outsource_center_master_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.outsource_center_master
    ADD CONSTRAINT outsource_center_master_pkey PRIMARY KEY (id);


--
-- Name: patient_addresses patient_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_addresses
    ADD CONSTRAINT patient_addresses_pkey PRIMARY KEY (id);


--
-- Name: patient_contacts patient_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_contacts
    ADD CONSTRAINT patient_contacts_pkey PRIMARY KEY (id);


--
-- Name: patient_diseases patient_diseases_patient_id_disease_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_diseases
    ADD CONSTRAINT patient_diseases_patient_id_disease_id_key UNIQUE (patient_id, disease_id);


--
-- Name: patient_diseases patient_diseases_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_diseases
    ADD CONSTRAINT patient_diseases_pkey PRIMARY KEY (id);


--
-- Name: patient_identifiers patient_identifiers_identifier_type_identifier_value_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_identifiers
    ADD CONSTRAINT patient_identifiers_identifier_type_identifier_value_key UNIQUE (identifier_type, identifier_value);


--
-- Name: patient_identifiers patient_identifiers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_identifiers
    ADD CONSTRAINT patient_identifiers_pkey PRIMARY KEY (id);


--
-- Name: patient_medical_conditions patient_medical_conditions_patient_id_condition_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_medical_conditions
    ADD CONSTRAINT patient_medical_conditions_patient_id_condition_id_key UNIQUE (patient_id, condition_id);


--
-- Name: patient_medical_conditions patient_medical_conditions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_medical_conditions
    ADD CONSTRAINT patient_medical_conditions_pkey PRIMARY KEY (id);


--
-- Name: patient_photos patient_photos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_photos
    ADD CONSTRAINT patient_photos_pkey PRIMARY KEY (id);


--
-- Name: patient_registrations patient_registrations_organization_id_registration_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_registrations
    ADD CONSTRAINT patient_registrations_organization_id_registration_number_key UNIQUE (organization_id, registration_number);


--
-- Name: patient_registrations patient_registrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_registrations
    ADD CONSTRAINT patient_registrations_pkey PRIMARY KEY (id);


--
-- Name: patient_trf patient_trf_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_trf
    ADD CONSTRAINT patient_trf_pkey PRIMARY KEY (id);


--
-- Name: patients patients_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_pkey PRIMARY KEY (id);


--
-- Name: registration_clinical_history registration_clinical_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registration_clinical_history
    ADD CONSTRAINT registration_clinical_history_pkey PRIMARY KEY (id);


--
-- Name: registration_symptoms registration_symptoms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registration_symptoms
    ADD CONSTRAINT registration_symptoms_pkey PRIMARY KEY (id);


--
-- Name: registration_symptoms registration_symptoms_registration_id_symptom_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registration_symptoms
    ADD CONSTRAINT registration_symptoms_registration_id_symptom_id_key UNIQUE (registration_id, symptom_id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: roles roles_role_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_role_code_key UNIQUE (role_code);


--
-- Name: sample_type_master sample_type_master_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sample_type_master
    ADD CONSTRAINT sample_type_master_pkey PRIMARY KEY (id);


--
-- Name: symptom_master symptom_master_organization_id_symptom_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.symptom_master
    ADD CONSTRAINT symptom_master_organization_id_symptom_name_key UNIQUE (organization_id, symptom_name);


--
-- Name: symptom_master symptom_master_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.symptom_master
    ADD CONSTRAINT symptom_master_pkey PRIMARY KEY (id);


--
-- Name: sample_type_master uq_sample_type_code; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sample_type_master
    ADD CONSTRAINT uq_sample_type_code UNIQUE (organization_id, sample_code);


--
-- Name: sample_type_master uq_sample_type_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sample_type_master
    ADD CONSTRAINT uq_sample_type_name UNIQUE (organization_id, sample_name);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (user_id, role_id);


--
-- Name: users users_organization_id_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_organization_id_username_key UNIQUE (organization_id, username);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: worksheet_master worksheet_master_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.worksheet_master
    ADD CONSTRAINT worksheet_master_pkey PRIMARY KEY (id);


--
-- Name: idx_appointment_assignments_appointment_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_appointment_assignments_appointment_id ON public.appointment_assignments USING btree (appointment_id);


--
-- Name: idx_appointment_assignments_assigned_to; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_appointment_assignments_assigned_to ON public.appointment_assignments USING btree (assigned_to);


--
-- Name: idx_appointment_status_history_appointment_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_appointment_status_history_appointment_id ON public.appointment_status_history USING btree (appointment_id);


--
-- Name: idx_appointment_status_history_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_appointment_status_history_status ON public.appointment_status_history USING btree (status);


--
-- Name: idx_appointment_tests_appointment_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_appointment_tests_appointment_id ON public.appointment_tests USING btree (appointment_id);


--
-- Name: idx_appointment_type_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_appointment_type_org ON public.appointment_type_master USING btree (organization_id);


--
-- Name: idx_appointments_branch; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_appointments_branch ON public.appointments USING btree (branch_id);


--
-- Name: idx_appointments_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_appointments_date ON public.appointments USING btree (appointment_date);


--
-- Name: idx_appointments_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_appointments_org ON public.appointments USING btree (organization_id);


--
-- Name: idx_appointments_patient; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_appointments_patient ON public.appointments USING btree (patient_id);


--
-- Name: idx_appointments_registration; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_appointments_registration ON public.appointments USING btree (registration_id);


--
-- Name: idx_appointments_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_appointments_status ON public.appointments USING btree (appointment_status);


--
-- Name: idx_clinical_history_registration; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_clinical_history_registration ON public.registration_clinical_history USING btree (registration_id);


--
-- Name: idx_department_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_department_name ON public.department_master USING btree (department_name);


--
-- Name: idx_department_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_department_org ON public.department_master USING btree (organization_id);


--
-- Name: idx_disease_master_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_disease_master_org ON public.disease_master USING btree (organization_id);


--
-- Name: idx_medical_condition_master_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_medical_condition_master_org ON public.medical_condition_master USING btree (organization_id);


--
-- Name: idx_outsource_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_outsource_active ON public.outsource_center_master USING btree (is_active);


--
-- Name: idx_outsource_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_outsource_name ON public.outsource_center_master USING btree (center_name);


--
-- Name: idx_outsource_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_outsource_org ON public.outsource_center_master USING btree (organization_id);


--
-- Name: idx_patient_contact_value; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_patient_contact_value ON public.patient_contacts USING btree (contact_value);


--
-- Name: idx_patient_diseases_disease; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_patient_diseases_disease ON public.patient_diseases USING btree (disease_id);


--
-- Name: idx_patient_diseases_patient; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_patient_diseases_patient ON public.patient_diseases USING btree (patient_id);


--
-- Name: idx_patient_identifier_value; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_patient_identifier_value ON public.patient_identifiers USING btree (identifier_value);


--
-- Name: idx_patient_medical_conditions_condition; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_patient_medical_conditions_condition ON public.patient_medical_conditions USING btree (condition_id);


--
-- Name: idx_patient_medical_conditions_patient; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_patient_medical_conditions_patient ON public.patient_medical_conditions USING btree (patient_id);


--
-- Name: idx_patient_registration_patient; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_patient_registration_patient ON public.patient_registrations USING btree (patient_id);


--
-- Name: idx_patients_dob; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_patients_dob ON public.patients USING btree (date_of_birth);


--
-- Name: idx_patients_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_patients_name ON public.patients USING btree (first_name, last_name);


--
-- Name: idx_patients_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_patients_org ON public.patients USING btree (organization_id);


--
-- Name: idx_registration_symptoms_registration; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_registration_symptoms_registration ON public.registration_symptoms USING btree (registration_id);


--
-- Name: idx_registration_symptoms_symptom; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_registration_symptoms_symptom ON public.registration_symptoms USING btree (symptom_id);


--
-- Name: idx_sample_type_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sample_type_active ON public.sample_type_master USING btree (is_active);


--
-- Name: idx_sample_type_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sample_type_code ON public.sample_type_master USING btree (sample_code);


--
-- Name: idx_sample_type_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sample_type_name ON public.sample_type_master USING btree (sample_name);


--
-- Name: idx_sample_type_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sample_type_org ON public.sample_type_master USING btree (organization_id);


--
-- Name: idx_symptom_master_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_symptom_master_org ON public.symptom_master USING btree (organization_id);


--
-- Name: idx_worksheet_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_worksheet_code ON public.worksheet_master USING btree (worksheet_code);


--
-- Name: idx_worksheet_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_worksheet_name ON public.worksheet_master USING btree (worksheet_name);


--
-- Name: idx_worksheet_org; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_worksheet_org ON public.worksheet_master USING btree (organization_id);


--
-- Name: appointment_assignments appointment_assignments_appointment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointment_assignments
    ADD CONSTRAINT appointment_assignments_appointment_id_fkey FOREIGN KEY (appointment_id) REFERENCES public.appointments(id);


--
-- Name: appointment_assignments appointment_assignments_assigned_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointment_assignments
    ADD CONSTRAINT appointment_assignments_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.users(id);


--
-- Name: appointment_assignments appointment_assignments_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointment_assignments
    ADD CONSTRAINT appointment_assignments_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: appointment_assignments appointment_assignments_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointment_assignments
    ADD CONSTRAINT appointment_assignments_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: appointment_status_history appointment_status_history_appointment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointment_status_history
    ADD CONSTRAINT appointment_status_history_appointment_id_fkey FOREIGN KEY (appointment_id) REFERENCES public.appointments(id);


--
-- Name: appointment_status_history appointment_status_history_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointment_status_history
    ADD CONSTRAINT appointment_status_history_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: appointment_tests appointment_tests_appointment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointment_tests
    ADD CONSTRAINT appointment_tests_appointment_id_fkey FOREIGN KEY (appointment_id) REFERENCES public.appointments(id);


--
-- Name: appointment_tests appointment_tests_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointment_tests
    ADD CONSTRAINT appointment_tests_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: appointment_tests appointment_tests_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointment_tests
    ADD CONSTRAINT appointment_tests_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: appointment_type_master appointment_type_master_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointment_type_master
    ADD CONSTRAINT appointment_type_master_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: appointment_type_master appointment_type_master_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointment_type_master
    ADD CONSTRAINT appointment_type_master_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: appointment_type_master appointment_type_master_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointment_type_master
    ADD CONSTRAINT appointment_type_master_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: appointments appointments_appointment_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_appointment_type_id_fkey FOREIGN KEY (appointment_type_id) REFERENCES public.appointment_type_master(id);


--
-- Name: appointments appointments_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: appointments appointments_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: appointments appointments_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: appointments appointments_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- Name: appointments appointments_registration_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_registration_id_fkey FOREIGN KEY (registration_id) REFERENCES public.patient_registrations(id);


--
-- Name: appointments appointments_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: audit_logs audit_logs_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: audit_logs audit_logs_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: audit_logs audit_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: branches branches_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.branches
    ADD CONSTRAINT branches_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: department_master department_master_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.department_master
    ADD CONSTRAINT department_master_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: department_master department_master_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.department_master
    ADD CONSTRAINT department_master_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: department_master department_master_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.department_master
    ADD CONSTRAINT department_master_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: disease_master disease_master_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.disease_master
    ADD CONSTRAINT disease_master_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: disease_master disease_master_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.disease_master
    ADD CONSTRAINT disease_master_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: disease_master disease_master_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.disease_master
    ADD CONSTRAINT disease_master_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: medical_condition_master medical_condition_master_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medical_condition_master
    ADD CONSTRAINT medical_condition_master_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: medical_condition_master medical_condition_master_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medical_condition_master
    ADD CONSTRAINT medical_condition_master_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: medical_condition_master medical_condition_master_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medical_condition_master
    ADD CONSTRAINT medical_condition_master_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: outsource_center_master outsource_center_master_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.outsource_center_master
    ADD CONSTRAINT outsource_center_master_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: outsource_center_master outsource_center_master_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.outsource_center_master
    ADD CONSTRAINT outsource_center_master_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: outsource_center_master outsource_center_master_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.outsource_center_master
    ADD CONSTRAINT outsource_center_master_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: patient_addresses patient_addresses_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_addresses
    ADD CONSTRAINT patient_addresses_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: patient_addresses patient_addresses_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_addresses
    ADD CONSTRAINT patient_addresses_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- Name: patient_addresses patient_addresses_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_addresses
    ADD CONSTRAINT patient_addresses_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: patient_contacts patient_contacts_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_contacts
    ADD CONSTRAINT patient_contacts_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: patient_contacts patient_contacts_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_contacts
    ADD CONSTRAINT patient_contacts_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- Name: patient_contacts patient_contacts_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_contacts
    ADD CONSTRAINT patient_contacts_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: patient_diseases patient_diseases_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_diseases
    ADD CONSTRAINT patient_diseases_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: patient_diseases patient_diseases_disease_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_diseases
    ADD CONSTRAINT patient_diseases_disease_id_fkey FOREIGN KEY (disease_id) REFERENCES public.disease_master(id);


--
-- Name: patient_diseases patient_diseases_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_diseases
    ADD CONSTRAINT patient_diseases_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- Name: patient_diseases patient_diseases_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_diseases
    ADD CONSTRAINT patient_diseases_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: patient_identifiers patient_identifiers_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_identifiers
    ADD CONSTRAINT patient_identifiers_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- Name: patient_medical_conditions patient_medical_conditions_condition_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_medical_conditions
    ADD CONSTRAINT patient_medical_conditions_condition_id_fkey FOREIGN KEY (condition_id) REFERENCES public.medical_condition_master(id);


--
-- Name: patient_medical_conditions patient_medical_conditions_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_medical_conditions
    ADD CONSTRAINT patient_medical_conditions_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: patient_medical_conditions patient_medical_conditions_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_medical_conditions
    ADD CONSTRAINT patient_medical_conditions_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- Name: patient_medical_conditions patient_medical_conditions_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_medical_conditions
    ADD CONSTRAINT patient_medical_conditions_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: patient_photos patient_photos_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_photos
    ADD CONSTRAINT patient_photos_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: patient_photos patient_photos_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_photos
    ADD CONSTRAINT patient_photos_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: patient_photos patient_photos_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_photos
    ADD CONSTRAINT patient_photos_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- Name: patient_registrations patient_registrations_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_registrations
    ADD CONSTRAINT patient_registrations_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: patient_registrations patient_registrations_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_registrations
    ADD CONSTRAINT patient_registrations_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: patient_registrations patient_registrations_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_registrations
    ADD CONSTRAINT patient_registrations_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: patient_registrations patient_registrations_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_registrations
    ADD CONSTRAINT patient_registrations_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- Name: patient_trf patient_trf_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_trf
    ADD CONSTRAINT patient_trf_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: patient_trf patient_trf_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_trf
    ADD CONSTRAINT patient_trf_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- Name: patient_trf patient_trf_registration_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_trf
    ADD CONSTRAINT patient_trf_registration_id_fkey FOREIGN KEY (registration_id) REFERENCES public.patient_registrations(id);


--
-- Name: patient_trf patient_trf_uploaded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patient_trf
    ADD CONSTRAINT patient_trf_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES public.users(id);


--
-- Name: patients patients_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: patients patients_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: patients patients_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: registration_clinical_history registration_clinical_history_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registration_clinical_history
    ADD CONSTRAINT registration_clinical_history_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: registration_clinical_history registration_clinical_history_registration_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registration_clinical_history
    ADD CONSTRAINT registration_clinical_history_registration_id_fkey FOREIGN KEY (registration_id) REFERENCES public.patient_registrations(id);


--
-- Name: registration_clinical_history registration_clinical_history_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registration_clinical_history
    ADD CONSTRAINT registration_clinical_history_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: registration_symptoms registration_symptoms_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registration_symptoms
    ADD CONSTRAINT registration_symptoms_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: registration_symptoms registration_symptoms_registration_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registration_symptoms
    ADD CONSTRAINT registration_symptoms_registration_id_fkey FOREIGN KEY (registration_id) REFERENCES public.patient_registrations(id);


--
-- Name: registration_symptoms registration_symptoms_symptom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registration_symptoms
    ADD CONSTRAINT registration_symptoms_symptom_id_fkey FOREIGN KEY (symptom_id) REFERENCES public.symptom_master(id);


--
-- Name: registration_symptoms registration_symptoms_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.registration_symptoms
    ADD CONSTRAINT registration_symptoms_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: sample_type_master sample_type_master_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sample_type_master
    ADD CONSTRAINT sample_type_master_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: sample_type_master sample_type_master_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sample_type_master
    ADD CONSTRAINT sample_type_master_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: sample_type_master sample_type_master_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sample_type_master
    ADD CONSTRAINT sample_type_master_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: symptom_master symptom_master_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.symptom_master
    ADD CONSTRAINT symptom_master_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: symptom_master symptom_master_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.symptom_master
    ADD CONSTRAINT symptom_master_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: symptom_master symptom_master_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.symptom_master
    ADD CONSTRAINT symptom_master_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: user_roles user_roles_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: user_roles user_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: users users_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: users users_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: worksheet_master worksheet_master_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.worksheet_master
    ADD CONSTRAINT worksheet_master_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: worksheet_master worksheet_master_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.worksheet_master
    ADD CONSTRAINT worksheet_master_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: worksheet_master worksheet_master_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.worksheet_master
    ADD CONSTRAINT worksheet_master_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

\unrestrict psXVtFJo0XO3FlWBTlVBIoOkeHZxIFDQNX5w6CYUecDCXB0LTYe09QI2J7gnqKX

