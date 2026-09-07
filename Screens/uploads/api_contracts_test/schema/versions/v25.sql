--
-- PostgreSQL database dump
--

\restrict CQfiUJBZddKBjt1i0GIQS0sfctwxwLf9EnZux8bBkTHd7ncfoFWEZtNlu28w3Rk

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
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: prevent_reference_range_overlap(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.prevent_reference_range_overlap() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_conflict_id UUID;
BEGIN

    IF NEW.is_active THEN

        SELECT id
        INTO v_conflict_id
        FROM reference_range_master
        WHERE organization_id = NEW.organization_id
          AND branch_id = NEW.branch_id
          AND parameter_id = NEW.parameter_id
          AND gender = NEW.gender
          AND age_unit = NEW.age_unit
          AND pregnancy_flag = NEW.pregnancy_flag
          AND is_active = TRUE
          AND id IS DISTINCT FROM NEW.id
          AND NEW.age_min <= age_max
          AND NEW.age_max >= age_min
          AND NEW.effective_from <= COALESCE(effective_to, DATE 'infinity')
          AND COALESCE(NEW.effective_to, DATE 'infinity') >= effective_from
        LIMIT 1;

        IF v_conflict_id IS NOT NULL THEN
            RAISE EXCEPTION
                'reference_range_master: overlapping demographic band for parameter_id=%, gender=%, pregnancy_flag=% conflicts with existing row %',
                NEW.parameter_id, NEW.gender, NEW.pregnancy_flag, v_conflict_id;
        END IF;

    END IF;

    RETURN NEW;

END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: accession_master; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accession_master (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    billing_id uuid NOT NULL,
    patient_registration_id uuid NOT NULL,
    accession_number character varying(30) NOT NULL,
    accession_date timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    priority character varying(20) DEFAULT 'NORMAL'::character varying NOT NULL,
    status character varying(30) DEFAULT 'PENDING'::character varying NOT NULL,
    remarks text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid,
    is_active boolean DEFAULT true NOT NULL,
    CONSTRAINT accession_master_priority_check CHECK (((priority)::text = ANY ((ARRAY['NORMAL'::character varying, 'URGENT'::character varying, 'STAT'::character varying])::text[]))),
    CONSTRAINT accession_master_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'PARTIALLY_COLLECTED'::character varying, 'COLLECTED'::character varying, 'PROCESSING'::character varying, 'COMPLETED'::character varying, 'CANCELLED'::character varying])::text[])))
);


--
-- Name: accession_tests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accession_tests (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    accession_id uuid NOT NULL,
    billing_test_id uuid NOT NULL,
    test_id uuid NOT NULL,
    sample_type_id uuid,
    performing_lab_id uuid,
    worksheet_id uuid,
    worklist_id uuid,
    barcode character varying(30),
    barcode_status character varying(20) DEFAULT 'GENERATED'::character varying NOT NULL,
    print_count integer DEFAULT 0 NOT NULL,
    last_printed_at timestamp with time zone,
    last_printed_by uuid,
    sample_status character varying(30) DEFAULT 'PENDING'::character varying NOT NULL,
    collection_status character varying(30) DEFAULT 'NOT_COLLECTED'::character varying NOT NULL,
    authorization_status character varying(30) DEFAULT 'PENDING'::character varying NOT NULL,
    report_status character varying(30) DEFAULT 'PENDING'::character varying NOT NULL,
    remarks text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by uuid,
    is_active boolean DEFAULT true,
    CONSTRAINT accession_tests_authorization_status_check CHECK (((authorization_status)::text = ANY ((ARRAY['PENDING'::character varying, 'AUTHORIZED'::character varying, 'REJECTED'::character varying])::text[]))),
    CONSTRAINT accession_tests_barcode_status_check CHECK (((barcode_status)::text = ANY ((ARRAY['GENERATED'::character varying, 'PRINTED'::character varying, 'REPRINTED'::character varying, 'CANCELLED'::character varying])::text[]))),
    CONSTRAINT accession_tests_collection_status_check CHECK (((collection_status)::text = ANY ((ARRAY['NOT_COLLECTED'::character varying, 'COLLECTED'::character varying, 'PARTIALLY_COLLECTED'::character varying])::text[]))),
    CONSTRAINT accession_tests_report_status_check CHECK (((report_status)::text = ANY ((ARRAY['PENDING'::character varying, 'READY'::character varying, 'RELEASED'::character varying])::text[])))
);


--
-- Name: application_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.application_settings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    config_key character varying(100) NOT NULL,
    config_value text NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid,
    deleted_at timestamp with time zone,
    deleted_by uuid
);


--
-- Name: appointment_assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.appointment_assignments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
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


--
-- Name: appointment_status_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.appointment_status_history (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    appointment_id uuid NOT NULL,
    status character varying(50) NOT NULL,
    remarks text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid
);


--
-- Name: appointment_tests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.appointment_tests (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
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


--
-- Name: appointment_type_master; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.appointment_type_master (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    appointment_type_code character varying(30),
    appointment_type_name character varying(100) NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid
);


--
-- Name: appointments; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    user_id uuid,
    action_type character varying(50) NOT NULL,
    entity_type character varying(100) NOT NULL,
    entity_id uuid,
    old_values jsonb,
    new_values jsonb,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: billing_category_master; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.billing_category_master (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    billing_category_code character varying(30) NOT NULL,
    billing_category_name character varying(100) NOT NULL,
    description text,
    is_default boolean DEFAULT false,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid
);


--
-- Name: billing_master; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.billing_master (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    patient_registration_id uuid NOT NULL,
    bill_number character varying(30) NOT NULL,
    bill_date timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    billing_category_id uuid,
    referring_doctor_id uuid,
    total_amount numeric(10,2) DEFAULT 0,
    discount_amount numeric(10,2) DEFAULT 0,
    concession_amount numeric(10,2) DEFAULT 0,
    additional_amount numeric(10,2) DEFAULT 0,
    payable_amount numeric(10,2) DEFAULT 0,
    paid_amount numeric(10,2) DEFAULT 0,
    balance_amount numeric(10,2) DEFAULT 0,
    refund_amount numeric(10,2) DEFAULT 0,
    payment_mode character varying(30),
    transaction_reference character varying(100),
    payment_status character varying(30) DEFAULT 'Pending'::character varying,
    remarks text,
    is_cancelled boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid
);


--
-- Name: billing_tests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.billing_tests (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    billing_id uuid NOT NULL,
    test_id uuid NOT NULL,
    sample_type_id uuid,
    performing_lab_id uuid,
    quantity integer DEFAULT 1 NOT NULL,
    rate numeric(10,2) DEFAULT 0 NOT NULL,
    discount_amount numeric(10,2) DEFAULT 0,
    concession_amount numeric(10,2) DEFAULT 0,
    net_amount numeric(10,2) DEFAULT 0,
    tat_minutes integer,
    barcode character varying(100),
    status character varying(30) DEFAULT 'Pending'::character varying,
    remarks text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid
);


--
-- Name: branches; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: clinical_master; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.clinical_master (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    clinical_type character varying(30) NOT NULL,
    clinical_code character varying(50),
    clinical_name character varying(200) NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid
);


--
-- Name: container_type_master; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.container_type_master (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    container_name character varying(100) NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid,
    deleted_at timestamp with time zone,
    deleted_by uuid
);


--
-- Name: dashboard_cache; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dashboard_cache (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    dashboard_key character varying(100) NOT NULL,
    dashboard_value jsonb NOT NULL,
    generated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid,
    deleted_at timestamp with time zone,
    deleted_by uuid
);


--
-- Name: department_master; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.department_master (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    department_name character varying(100) NOT NULL,
    department_code character varying(30),
    description text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid
);


--
-- Name: instrument_configuration; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.instrument_configuration (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    instrument_id uuid NOT NULL,
    communication_protocol character varying(20),
    connection_type character varying(20),
    interface_mode character varying(20),
    ip_address character varying(50),
    port integer,
    com_port character varying(20),
    baud_rate integer,
    parity character varying(20),
    data_bits integer,
    stop_bits integer,
    driver_name character varying(100),
    workstation_name character varying(100),
    status character varying(20) DEFAULT 'ACTIVE'::character varying NOT NULL,
    remarks text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone,
    updated_by uuid,
    deleted_at timestamp with time zone,
    deleted_by uuid,
    CONSTRAINT instrument_configuration_communication_protocol_check CHECK (((communication_protocol)::text = ANY ((ARRAY['HL7'::character varying, 'ASTM'::character varying])::text[]))),
    CONSTRAINT instrument_configuration_connection_type_check CHECK (((connection_type)::text = ANY ((ARRAY['TCP/IP'::character varying, 'RS232'::character varying, 'USB'::character varying])::text[]))),
    CONSTRAINT instrument_configuration_interface_mode_check CHECK (((interface_mode)::text = ANY ((ARRAY['UNIDIRECTIONAL'::character varying, 'BIDIRECTIONAL'::character varying])::text[]))),
    CONSTRAINT instrument_configuration_parity_check CHECK (((parity)::text = ANY ((ARRAY['NONE'::character varying, 'EVEN'::character varying, 'ODD'::character varying])::text[]))),
    CONSTRAINT instrument_configuration_status_check CHECK (((status)::text = ANY ((ARRAY['ACTIVE'::character varying, 'INACTIVE'::character varying])::text[])))
);


--
-- Name: instrument_master; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.instrument_master (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    department_id uuid NOT NULL,
    instrument_code character varying(30) NOT NULL,
    instrument_name character varying(100) NOT NULL,
    manufacture character varying(100),
    model character varying(100),
    serial_number character varying(100),
    analyzer_type character varying(50),
    status character varying(20) DEFAULT 'ACTIVE'::character varying NOT NULL,
    remarks text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    update_at timestamp with time zone,
    updated_by uuid,
    CONSTRAINT instrument_master_analyzer_type_check CHECK (((analyzer_type)::text = ANY ((ARRAY['HEMATOLOGY'::character varying, 'BIOCHEMISTRY'::character varying, 'IMMUNOASSAY'::character varying, 'MICROBIOLOGY'::character varying, 'URINE_ANALYZER'::character varying, 'COAGULATION'::character varying, 'BLOOD_GAS'::character varying, 'OTHER'::character varying])::text[]))),
    CONSTRAINT instrument_master_status_check CHECK (((status)::text = ANY ((ARRAY['ACTIVE'::character varying, 'INACTIVE'::character varying, 'MAINTENANCE'::character varying])::text[])))
);


--
-- Name: instrument_test_mapping; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.instrument_test_mapping (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    instrument_id uuid NOT NULL,
    test_id uuid NOT NULL,
    parameter_id uuid NOT NULL,
    machine_test_code character varying(50) NOT NULL,
    machine_parameter_code character varying(50) NOT NULL,
    display_order integer DEFAULT 1 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    remarks text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone,
    updated_by uuid,
    deleted_at timestamp with time zone,
    deleted_by uuid
);


--
-- Name: instrument_transaction_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.instrument_transaction_log (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    instrument_id uuid NOT NULL,
    accession_test_id uuid,
    sample_barcode character varying(100),
    message_type character varying(20),
    protocol character varying(20),
    direction character varying(20),
    raw_message text NOT NULL,
    parsed_data jsonb,
    processing_status character varying(20) DEFAULT 'RECEIVED'::character varying NOT NULL,
    error_message text,
    received_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    processed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone,
    updated_by uuid,
    deleted_at timestamp with time zone,
    deleted_by uuid,
    CONSTRAINT instrument_transaction_log_direction_check CHECK (((direction)::text = ANY ((ARRAY['INBOUND'::character varying, 'OUTBOUND'::character varying])::text[]))),
    CONSTRAINT instrument_transaction_log_message_type_check CHECK (((message_type)::text = ANY ((ARRAY['ORDER'::character varying, 'RESULT'::character varying, 'ACK'::character varying, 'ERROR'::character varying])::text[]))),
    CONSTRAINT instrument_transaction_log_processing_status_check CHECK (((processing_status)::text = ANY ((ARRAY['RECEIVED'::character varying, 'PROCESSED'::character varying, 'FAILED'::character varying])::text[]))),
    CONSTRAINT instrument_transaction_log_protocol_check CHECK (((protocol)::text = ANY ((ARRAY['HL7'::character varying, 'ASTM'::character varying])::text[])))
);


--
-- Name: menu_permission; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.menu_permission (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    role_id uuid NOT NULL,
    menu_name character varying(100) NOT NULL,
    is_visible boolean DEFAULT true NOT NULL,
    display_order integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid,
    deleted_at timestamp with time zone,
    deleted_by uuid
);


--
-- Name: notification_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notification_log (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    template_id uuid,
    patient_registration_id uuid,
    notification_type character varying(20) NOT NULL,
    recipient character varying(255) NOT NULL,
    subject character varying(255),
    message_body text NOT NULL,
    status character varying(20) DEFAULT 'PENDING'::character varying NOT NULL,
    sent_at timestamp with time zone,
    error_message text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid,
    deleted_at timestamp with time zone,
    deleted_by uuid,
    CONSTRAINT notification_log_notification_type_check CHECK (((notification_type)::text = ANY ((ARRAY['EMAIL'::character varying, 'SMS'::character varying, 'WHATSAPP'::character varying])::text[]))),
    CONSTRAINT notification_log_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'SENT'::character varying, 'FAILED'::character varying])::text[])))
);


--
-- Name: notification_template; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notification_template (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    template_name character varying(100) NOT NULL,
    notification_type character varying(20) NOT NULL,
    subject character varying(255),
    message_body text NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid,
    deleted_at timestamp with time zone,
    deleted_by uuid,
    CONSTRAINT notification_template_notification_type_check CHECK (((notification_type)::text = ANY ((ARRAY['EMAIL'::character varying, 'SMS'::character varying, 'WHATSAPP'::character varying])::text[])))
);


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organizations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_code character varying(50) NOT NULL,
    organization_name character varying(200) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: outsource_center_master; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.outsource_center_master (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
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


--
-- Name: parameter_master; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parameter_master (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    parameter_code character varying(50) NOT NULL,
    parameter_name character varying(255) NOT NULL,
    data_type character varying(20) DEFAULT 'NUMERIC'::character varying NOT NULL,
    result_type character varying(20) DEFAULT 'NUMERIC'::character varying NOT NULL,
    unit character varying(50),
    default_reference_range character varying(255),
    default_min_value numeric(18,4),
    default_max_value numeric(18,4),
    critical_low numeric(18,4),
    critical_high numeric(18,4),
    decimal_places smallint DEFAULT 2 NOT NULL,
    formula text,
    method character varying(255),
    display_order integer DEFAULT 1 NOT NULL,
    remarks text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid,
    is_active boolean DEFAULT true NOT NULL,
    CONSTRAINT parameter_master_data_type_check CHECK (((data_type)::text = ANY ((ARRAY['NUMERIC'::character varying, 'TEXT'::character varying, 'BOOLEAN'::character varying, 'DATE'::character varying, 'DATETIME'::character varying])::text[]))),
    CONSTRAINT parameter_master_result_type_check CHECK (((result_type)::text = ANY ((ARRAY['NUMERIC'::character varying, 'TEXT'::character varying, 'BOOLEAN'::character varying, 'DATE'::character varying, 'DATETIME'::character varying])::text[])))
);


--
-- Name: patient_addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.patient_addresses (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
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


--
-- Name: patient_clinical_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.patient_clinical_history (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    registration_id uuid,
    clinical_id uuid NOT NULL,
    severity character varying(30),
    duration_value integer,
    duration_unit character varying(20),
    status character varying(30),
    diagnosed_date date,
    notes text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid
);


--
-- Name: patient_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.patient_contacts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
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


--
-- Name: patient_identifiers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.patient_identifiers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    identifier_type character varying(50) NOT NULL,
    identifier_value character varying(200) NOT NULL,
    is_primary boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: patient_photos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.patient_photos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    photo_url text NOT NULL,
    is_primary boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid
);


--
-- Name: patient_registrations; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: patient_trf; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.patient_trf (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    patient_id uuid NOT NULL,
    registration_id uuid NOT NULL,
    trf_number character varying(50),
    trf_file_url text NOT NULL,
    uploaded_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    uploaded_by uuid,
    remarks text,
    is_active boolean DEFAULT true
);


--
-- Name: patients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.patients (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
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


--
-- Name: payment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    accession_id uuid NOT NULL,
    billing_master_id uuid NOT NULL,
    patient_registration_id uuid NOT NULL,
    payment_mode character varying(20) NOT NULL,
    amount_paid numeric(12,2) NOT NULL,
    transaction_reference character varying(100),
    payment_status character varying(20) DEFAULT 'SUCCESS'::character varying NOT NULL,
    payment_date timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    remarks text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone,
    updated_by uuid,
    deleted_at timestamp with time zone,
    deleted_by uuid,
    CONSTRAINT payment_amount_paid_check CHECK ((amount_paid >= (0)::numeric)),
    CONSTRAINT payment_payment_status_check CHECK (((payment_status)::text = ANY ((ARRAY['SUCCESS'::character varying, 'PENDING'::character varying, 'FAILED'::character varying, 'PARTIAL'::character varying])::text[])))
);


--
-- Name: payment_mode_master; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment_mode_master (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    payment_mode_code character varying(30) NOT NULL,
    payment_mode_name character varying(100) NOT NULL,
    sort_order integer DEFAULT 1 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid
);


--
-- Name: performing_lab_master; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.performing_lab_master (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    lab_code character varying(30) NOT NULL,
    lab_name character varying(100) NOT NULL,
    alternate_lab_name character varying(150),
    legal_name character varying(150),
    contact_person_name character varying(100),
    contact_person_email character varying(100),
    alternate_contact_person_name character varying(100),
    email character varying(150),
    address text,
    city character varying(100),
    state character varying(100),
    country character varying(100),
    pincode character varying(20),
    gstin_number character varying(30),
    lab_type character varying(50) DEFAULT 'Private'::character varying,
    is_default boolean DEFAULT false,
    is_result_lab boolean DEFAULT false,
    auto_email_report boolean DEFAULT false,
    auto_sms_report boolean DEFAULT false,
    auto_whatsapp_report boolean DEFAULT false,
    remarks text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid
);


--
-- Name: qc_master; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.qc_master (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    instrument_id uuid NOT NULL,
    test_id uuid NOT NULL,
    parameter_id uuid NOT NULL,
    qc_level character varying(20) NOT NULL,
    lot_number character varying(50) NOT NULL,
    manufacturer character varying(100),
    mean_value numeric(10,3) NOT NULL,
    standard_deviation numeric(10,3) NOT NULL,
    acceptable_min numeric(10,3) NOT NULL,
    acceptable_max numeric(10,3) NOT NULL,
    expiry_date date,
    status character varying(20) DEFAULT 'ACTIVE'::character varying NOT NULL,
    remarks text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone,
    updated_by uuid,
    deleted_at timestamp with time zone,
    deleted_by uuid,
    CONSTRAINT qc_master_qc_level_check CHECK (((qc_level)::text = ANY ((ARRAY['LEVEL_1'::character varying, 'LEVEL_2'::character varying, 'LEVEL_3'::character varying])::text[]))),
    CONSTRAINT qc_master_status_check CHECK (((status)::text = ANY ((ARRAY['ACTIVE'::character varying, 'INACTIVE'::character varying, 'EXPIRED'::character varying])::text[])))
);


--
-- Name: qc_run_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.qc_run_log (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    qc_master_id uuid NOT NULL,
    instrument_id uuid NOT NULL,
    actual_value numeric(10,3) NOT NULL,
    z_score numeric(10,3),
    result_status character varying(20) NOT NULL,
    rule_triggered character varying(20),
    remarks text,
    run_datetime timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone,
    updated_by uuid,
    deleted_at timestamp with time zone,
    deleted_by uuid,
    CONSTRAINT qc_run_log_result_status_check CHECK (((result_status)::text = ANY ((ARRAY['PASS'::character varying, 'FAIL'::character varying])::text[]))),
    CONSTRAINT qc_run_log_rule_triggered_check CHECK (((rule_triggered)::text = ANY ((ARRAY['1-2S'::character varying, '1-3S'::character varying, '2-2S'::character varying, 'R-4S'::character varying, '4-1S'::character varying, '10X'::character varying])::text[])))
);


--
-- Name: reference_range_master; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reference_range_master (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    parameter_id uuid NOT NULL,
    gender character varying(10) DEFAULT 'ANY'::character varying NOT NULL,
    age_min numeric(6,2) DEFAULT 0 NOT NULL,
    age_max numeric(6,2) DEFAULT 150 NOT NULL,
    age_unit character varying(10) DEFAULT 'YEARS'::character varying NOT NULL,
    pregnancy_flag boolean DEFAULT false NOT NULL,
    reference_min numeric(18,4),
    reference_max numeric(18,4),
    reference_range character varying(255),
    critical_low numeric(18,4),
    critical_high numeric(18,4),
    effective_from date DEFAULT CURRENT_DATE NOT NULL,
    effective_to date,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid,
    CONSTRAINT chk_reference_range_master_age CHECK ((age_max >= age_min)),
    CONSTRAINT chk_reference_range_master_bounds CHECK (((reference_max IS NULL) OR (reference_min IS NULL) OR (reference_max >= reference_min))),
    CONSTRAINT chk_reference_range_master_effective CHECK (((effective_to IS NULL) OR (effective_to >= effective_from))),
    CONSTRAINT reference_range_master_age_unit_check CHECK (((age_unit)::text = ANY ((ARRAY['DAYS'::character varying, 'MONTHS'::character varying, 'YEARS'::character varying])::text[]))),
    CONSTRAINT reference_range_master_gender_check CHECK (((gender)::text = ANY ((ARRAY['MALE'::character varying, 'FEMALE'::character varying, 'ANY'::character varying])::text[])))
);


--
-- Name: refund; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.refund (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    payment_id uuid NOT NULL,
    refund_amount numeric(12,2) NOT NULL,
    refund_reason text,
    refund_status character varying(20) DEFAULT 'APPROVED'::character varying NOT NULL,
    refund_date timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    remarks text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone,
    updated_by uuid,
    deleted_at timestamp with time zone,
    deleted_by uuid,
    CONSTRAINT refund_refund_amount_check CHECK ((refund_amount > (0)::numeric)),
    CONSTRAINT refund_refund_status_check CHECK (((refund_status)::text = ANY ((ARRAY['PENDING'::character varying, 'APPROVED'::character varying, 'REJECTED'::character varying, 'COMPLETED'::character varying])::text[])))
);


--
-- Name: report_delivery_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.report_delivery_log (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    report_id uuid NOT NULL,
    delivery_type character varying(20) NOT NULL,
    recipient_type character varying(30) NOT NULL,
    recipient_name character varying(255),
    recipient_contact character varying(255),
    delivery_status character varying(20) DEFAULT 'PENDING'::character varying NOT NULL,
    delivered_at timestamp with time zone,
    delivered_by uuid,
    remarks text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid,
    is_active boolean DEFAULT true NOT NULL,
    CONSTRAINT report_delivery_log_delivery_status_check CHECK (((delivery_status)::text = ANY ((ARRAY['PENDING'::character varying, 'SENT'::character varying, 'FAILED'::character varying, 'DELIVERED'::character varying])::text[]))),
    CONSTRAINT report_delivery_log_delivery_type_check CHECK (((delivery_type)::text = ANY ((ARRAY['PRINT'::character varying, 'EMAIL'::character varying, 'SMS'::character varying, 'WHATSAPP'::character varying, 'PORTAL'::character varying])::text[]))),
    CONSTRAINT report_delivery_log_recipient_type_check CHECK (((recipient_type)::text = ANY ((ARRAY['PATIENT'::character varying, 'DOCTOR'::character varying, 'REFERRAL'::character varying, 'COLLECTION_CENTER'::character varying, 'LAB'::character varying])::text[])))
);


--
-- Name: report_master; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.report_master (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    accession_id uuid NOT NULL,
    report_number character varying(50) NOT NULL,
    version_no integer DEFAULT 1 NOT NULL,
    report_status character varying(20) DEFAULT 'DRAFT'::character varying NOT NULL,
    generated_at timestamp with time zone,
    generated_by uuid,
    authorized_at timestamp with time zone,
    authorized_by uuid,
    printed_at timestamp with time zone,
    printed_by uuid,
    released_at timestamp with time zone,
    released_by uuid,
    pdf_path text,
    qr_code text,
    remarks text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid,
    is_active boolean DEFAULT true NOT NULL,
    CONSTRAINT report_master_report_status_check CHECK (((report_status)::text = ANY ((ARRAY['DRAFT'::character varying, 'GENERATED'::character varying, 'AUTHORIZED'::character varying, 'RELEASED'::character varying, 'CANCELLED'::character varying])::text[])))
);


--
-- Name: result_authorization; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.result_authorization (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    result_entry_id uuid NOT NULL,
    authorization_status character varying(30) DEFAULT 'PENDING'::character varying NOT NULL,
    authorized_at timestamp with time zone,
    authorized_by uuid,
    rejection_reason text,
    remarks text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid,
    is_active boolean DEFAULT true NOT NULL,
    CONSTRAINT result_authorization_authorization_status_check CHECK (((authorization_status)::text = ANY ((ARRAY['PENDING'::character varying, 'AUTHORIZED'::character varying, 'REJECTED'::character varying])::text[])))
);


--
-- Name: result_entry; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.result_entry (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    accession_test_id uuid NOT NULL,
    result_status character varying(20) DEFAULT 'PENDING'::character varying NOT NULL,
    entered_at timestamp with time zone,
    entered_by uuid,
    verified_at timestamp with time zone,
    verified_by uuid,
    remarks text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid,
    is_active boolean DEFAULT true NOT NULL,
    CONSTRAINT result_entry_result_status_check CHECK (((result_status)::text = ANY ((ARRAY['PENDING'::character varying, 'IN_PROGRESS'::character varying, 'COMPLETED'::character varying, 'AUTHORIZED'::character varying, 'REJECTED'::character varying])::text[])))
);


--
-- Name: result_entry_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.result_entry_details (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    result_entry_id uuid NOT NULL,
    parameter_id uuid NOT NULL,
    result_value character varying(255),
    result_flag character varying(20),
    remarks text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid,
    is_active boolean DEFAULT true NOT NULL,
    CONSTRAINT result_entry_details_result_flag_check CHECK (((result_flag)::text = ANY ((ARRAY['NORMAL'::character varying, 'HIGH'::character varying, 'LOW'::character varying, 'CRITICAL'::character varying, 'ABNORMAL'::character varying])::text[])))
);


--
-- Name: role_permission; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.role_permission (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    role_id uuid NOT NULL,
    module_name character varying(100) NOT NULL,
    can_create boolean DEFAULT false NOT NULL,
    can_view boolean DEFAULT false NOT NULL,
    can_update boolean DEFAULT false NOT NULL,
    can_delete boolean DEFAULT false NOT NULL,
    can_authorize boolean DEFAULT false NOT NULL,
    can_print boolean DEFAULT false NOT NULL,
    can_export boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid,
    deleted_at timestamp with time zone,
    deleted_by uuid
);


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    role_code character varying(50) NOT NULL,
    role_name character varying(100) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: sample_collection; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sample_collection (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    accession_test_id uuid NOT NULL,
    collector_id uuid,
    collection_datetime timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    collection_location character varying(150),
    sample_condition character varying(30) DEFAULT 'GOOD'::character varying NOT NULL,
    quantity numeric(10,2),
    quantity_unit character varying(20),
    temperature numeric(5,2),
    collection_status character varying(30) DEFAULT 'COLLECTED'::character varying NOT NULL,
    rejection_reason character varying(255),
    remarks text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by uuid,
    is_active boolean DEFAULT true,
    CONSTRAINT sample_collection_collection_status_check CHECK (((collection_status)::text = ANY ((ARRAY['COLLECTED'::character varying, 'RECOLLECTION_REQUIRED'::character varying, 'REJECTED'::character varying])::text[]))),
    CONSTRAINT sample_collection_sample_condition_check CHECK (((sample_condition)::text = ANY ((ARRAY['GOOD'::character varying, 'HEMOLYZED'::character varying, 'CLOTTED'::character varying, 'LEAKING'::character varying, 'INSUFFICIENT'::character varying, 'DAMAGED'::character varying])::text[])))
);


--
-- Name: sample_status_master; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sample_status_master (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    sample_status_code character varying(30) NOT NULL,
    sample_status_name character varying(100) NOT NULL,
    sort_order integer DEFAULT 1 NOT NULL,
    is_terminal boolean DEFAULT false NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid
);


--
-- Name: sample_tracking; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sample_tracking (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    sample_collection_id uuid NOT NULL,
    tracking_status character varying(40) NOT NULL,
    location character varying(150),
    remarks text,
    tracked_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    tracked_by uuid,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by uuid,
    is_active boolean DEFAULT true,
    CONSTRAINT sample_tracking_tracking_status_check CHECK (((tracking_status)::text = ANY ((ARRAY['COLLECTED'::character varying, 'RECEIVED'::character varying, 'PROCESSING'::character varying, 'AUTHORIZED'::character varying, 'COMPLETED'::character varying, 'DISPATCHED'::character varying, 'REJECTED'::character varying])::text[])))
);


--
-- Name: sample_type_master; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sample_type_master (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
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


--
-- Name: system_configuration; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.system_configuration (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    config_key character varying(100) NOT NULL,
    config_value text NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid,
    deleted_at timestamp with time zone,
    deleted_by uuid
);


--
-- Name: test_category_master; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.test_category_master (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    category_code character varying(30) NOT NULL,
    category_name character varying(100) NOT NULL,
    description text,
    display_order integer DEFAULT 1,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid
);


--
-- Name: test_master; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.test_master (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    department_id uuid NOT NULL,
    test_category_id uuid,
    billing_category_id uuid,
    sample_type_id uuid,
    performing_lab_id uuid,
    outsource_center_id uuid,
    worksheet_id uuid,
    worklist_id uuid,
    test_code character varying(50) NOT NULL,
    test_name character varying(200) NOT NULL,
    display_name character varying(200),
    print_name character varying(200),
    short_code character varying(50),
    selling_price numeric(10,2) DEFAULT 0 NOT NULL,
    cost_price numeric(10,2) DEFAULT 0 NOT NULL,
    cprr numeric(10,2) DEFAULT 0 NOT NULL,
    test_method character varying(200),
    test_type character varying(100),
    tat_minutes integer DEFAULT 0,
    machine_test_code character varying(100),
    consumption_group character varying(100),
    auto_approval boolean DEFAULT false,
    automatically_authorize boolean DEFAULT false,
    nabl_accredited boolean DEFAULT false,
    mark_as_profile boolean DEFAULT false,
    two_step_verification boolean DEFAULT false,
    authorize_only_by_authorizer boolean DEFAULT false,
    outsource_test boolean DEFAULT false,
    notify_accession boolean DEFAULT false,
    is_active boolean DEFAULT true,
    description text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid
);


--
-- Name: test_parameter_mapping; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.test_parameter_mapping (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    test_id uuid NOT NULL,
    parameter_id uuid NOT NULL,
    display_order integer DEFAULT 1 NOT NULL,
    unit character varying(50),
    reference_range character varying(255),
    min_value numeric(10,3),
    max_value numeric(10,3),
    critical_low numeric(10,3),
    critical_high numeric(10,3),
    is_mandatory boolean DEFAULT true NOT NULL,
    formula text,
    remarks text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid,
    is_active boolean DEFAULT true NOT NULL
);


--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_roles (
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    user_id uuid NOT NULL,
    role_id uuid NOT NULL,
    assigned_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    username character varying(100) NOT NULL,
    email character varying(255),
    password_hash text NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100),
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: worklist_master; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.worklist_master (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    department_id uuid NOT NULL,
    worklist_code character varying(30) NOT NULL,
    worklist_name character varying(100) NOT NULL,
    description text,
    sort_order character varying(30) DEFAULT 'ASC'::character varying NOT NULL,
    estimated_tat_minutes integer,
    allow_generate_worklist boolean DEFAULT true NOT NULL,
    allow_generate_worksheet boolean DEFAULT true NOT NULL,
    allow_print boolean DEFAULT true,
    allow_export boolean DEFAULT true,
    is_default boolean DEFAULT false,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid
);


--
-- Name: worksheet_master; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.worksheet_master (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_id uuid NOT NULL,
    branch_id uuid NOT NULL,
    worksheet_code character varying(30) NOT NULL,
    worksheet_name character varying(100) NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid
);


--
-- Name: accession_master accession_master_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accession_master
    ADD CONSTRAINT accession_master_pkey PRIMARY KEY (id);


--
-- Name: accession_tests accession_tests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accession_tests
    ADD CONSTRAINT accession_tests_pkey PRIMARY KEY (id);


--
-- Name: application_settings application_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_settings
    ADD CONSTRAINT application_settings_pkey PRIMARY KEY (id);


--
-- Name: appointment_assignments appointment_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointment_assignments
    ADD CONSTRAINT appointment_assignments_pkey PRIMARY KEY (id);


--
-- Name: appointment_status_history appointment_status_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointment_status_history
    ADD CONSTRAINT appointment_status_history_pkey PRIMARY KEY (id);


--
-- Name: appointment_tests appointment_tests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointment_tests
    ADD CONSTRAINT appointment_tests_pkey PRIMARY KEY (id);


--
-- Name: appointment_type_master appointment_type_master_organization_id_branch_id_appointme_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointment_type_master
    ADD CONSTRAINT appointment_type_master_organization_id_branch_id_appointme_key UNIQUE (organization_id, branch_id, appointment_type_name);


--
-- Name: appointment_type_master appointment_type_master_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointment_type_master
    ADD CONSTRAINT appointment_type_master_pkey PRIMARY KEY (id);


--
-- Name: appointments appointments_organization_id_branch_id_appointment_number_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_organization_id_branch_id_appointment_number_key UNIQUE (organization_id, branch_id, appointment_number);


--
-- Name: appointments appointments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_pkey PRIMARY KEY (id);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: billing_category_master billing_category_master_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_category_master
    ADD CONSTRAINT billing_category_master_pkey PRIMARY KEY (id);


--
-- Name: billing_master billing_master_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_master
    ADD CONSTRAINT billing_master_pkey PRIMARY KEY (id);


--
-- Name: billing_tests billing_tests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_tests
    ADD CONSTRAINT billing_tests_pkey PRIMARY KEY (id);


--
-- Name: branches branches_organization_id_branch_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branches
    ADD CONSTRAINT branches_organization_id_branch_code_key UNIQUE (organization_id, branch_code);


--
-- Name: branches branches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branches
    ADD CONSTRAINT branches_pkey PRIMARY KEY (id);


--
-- Name: clinical_master clinical_master_organization_id_branch_id_clinical_type_cli_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clinical_master
    ADD CONSTRAINT clinical_master_organization_id_branch_id_clinical_type_cli_key UNIQUE (organization_id, branch_id, clinical_type, clinical_name);


--
-- Name: clinical_master clinical_master_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clinical_master
    ADD CONSTRAINT clinical_master_pkey PRIMARY KEY (id);


--
-- Name: container_type_master container_type_master_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.container_type_master
    ADD CONSTRAINT container_type_master_pkey PRIMARY KEY (id);


--
-- Name: dashboard_cache dashboard_cache_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_cache
    ADD CONSTRAINT dashboard_cache_pkey PRIMARY KEY (id);


--
-- Name: department_master department_master_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.department_master
    ADD CONSTRAINT department_master_pkey PRIMARY KEY (id);


--
-- Name: instrument_configuration instrument_configuration_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instrument_configuration
    ADD CONSTRAINT instrument_configuration_pkey PRIMARY KEY (id);


--
-- Name: instrument_master instrument_master_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instrument_master
    ADD CONSTRAINT instrument_master_pkey PRIMARY KEY (id);


--
-- Name: instrument_test_mapping instrument_test_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instrument_test_mapping
    ADD CONSTRAINT instrument_test_mapping_pkey PRIMARY KEY (id);


--
-- Name: instrument_transaction_log instrument_transaction_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instrument_transaction_log
    ADD CONSTRAINT instrument_transaction_log_pkey PRIMARY KEY (id);


--
-- Name: menu_permission menu_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menu_permission
    ADD CONSTRAINT menu_permission_pkey PRIMARY KEY (id);


--
-- Name: notification_log notification_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_log
    ADD CONSTRAINT notification_log_pkey PRIMARY KEY (id);


--
-- Name: notification_template notification_template_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_template
    ADD CONSTRAINT notification_template_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_organization_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_organization_code_key UNIQUE (organization_code);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: outsource_center_master outsource_center_master_organization_id_branch_id_center_co_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outsource_center_master
    ADD CONSTRAINT outsource_center_master_organization_id_branch_id_center_co_key UNIQUE (organization_id, branch_id, center_code);


--
-- Name: outsource_center_master outsource_center_master_organization_id_branch_id_center_na_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outsource_center_master
    ADD CONSTRAINT outsource_center_master_organization_id_branch_id_center_na_key UNIQUE (organization_id, branch_id, center_name);


--
-- Name: outsource_center_master outsource_center_master_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outsource_center_master
    ADD CONSTRAINT outsource_center_master_pkey PRIMARY KEY (id);


--
-- Name: parameter_master parameter_master_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parameter_master
    ADD CONSTRAINT parameter_master_pkey PRIMARY KEY (id);


--
-- Name: patient_addresses patient_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_addresses
    ADD CONSTRAINT patient_addresses_pkey PRIMARY KEY (id);


--
-- Name: patient_clinical_history patient_clinical_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_clinical_history
    ADD CONSTRAINT patient_clinical_history_pkey PRIMARY KEY (id);


--
-- Name: patient_contacts patient_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_contacts
    ADD CONSTRAINT patient_contacts_pkey PRIMARY KEY (id);


--
-- Name: patient_identifiers patient_identifiers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_identifiers
    ADD CONSTRAINT patient_identifiers_pkey PRIMARY KEY (id);


--
-- Name: patient_photos patient_photos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_photos
    ADD CONSTRAINT patient_photos_pkey PRIMARY KEY (id);


--
-- Name: patient_registrations patient_registrations_organization_id_branch_id_registratio_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_registrations
    ADD CONSTRAINT patient_registrations_organization_id_branch_id_registratio_key UNIQUE (organization_id, branch_id, registration_number);


--
-- Name: patient_registrations patient_registrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_registrations
    ADD CONSTRAINT patient_registrations_pkey PRIMARY KEY (id);


--
-- Name: patient_trf patient_trf_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_trf
    ADD CONSTRAINT patient_trf_pkey PRIMARY KEY (id);


--
-- Name: patients patients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_pkey PRIMARY KEY (id);


--
-- Name: payment_mode_master payment_mode_master_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_mode_master
    ADD CONSTRAINT payment_mode_master_pkey PRIMARY KEY (id);


--
-- Name: payment payment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_pkey PRIMARY KEY (id);


--
-- Name: performing_lab_master performing_lab_master_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.performing_lab_master
    ADD CONSTRAINT performing_lab_master_pkey PRIMARY KEY (id);


--
-- Name: qc_master qc_master_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.qc_master
    ADD CONSTRAINT qc_master_pkey PRIMARY KEY (id);


--
-- Name: qc_run_log qc_run_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.qc_run_log
    ADD CONSTRAINT qc_run_log_pkey PRIMARY KEY (id);


--
-- Name: reference_range_master reference_range_master_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reference_range_master
    ADD CONSTRAINT reference_range_master_pkey PRIMARY KEY (id);


--
-- Name: refund refund_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refund
    ADD CONSTRAINT refund_pkey PRIMARY KEY (id);


--
-- Name: report_delivery_log report_delivery_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_delivery_log
    ADD CONSTRAINT report_delivery_log_pkey PRIMARY KEY (id);


--
-- Name: report_master report_master_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_master
    ADD CONSTRAINT report_master_pkey PRIMARY KEY (id);


--
-- Name: result_authorization result_authorization_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.result_authorization
    ADD CONSTRAINT result_authorization_pkey PRIMARY KEY (id);


--
-- Name: result_entry_details result_entry_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.result_entry_details
    ADD CONSTRAINT result_entry_details_pkey PRIMARY KEY (id);


--
-- Name: result_entry result_entry_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.result_entry
    ADD CONSTRAINT result_entry_pkey PRIMARY KEY (id);


--
-- Name: role_permission role_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permission
    ADD CONSTRAINT role_permission_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: sample_collection sample_collection_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sample_collection
    ADD CONSTRAINT sample_collection_pkey PRIMARY KEY (id);


--
-- Name: sample_status_master sample_status_master_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sample_status_master
    ADD CONSTRAINT sample_status_master_pkey PRIMARY KEY (id);


--
-- Name: sample_tracking sample_tracking_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sample_tracking
    ADD CONSTRAINT sample_tracking_pkey PRIMARY KEY (id);


--
-- Name: sample_type_master sample_type_master_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sample_type_master
    ADD CONSTRAINT sample_type_master_pkey PRIMARY KEY (id);


--
-- Name: system_configuration system_configuration_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_configuration
    ADD CONSTRAINT system_configuration_pkey PRIMARY KEY (id);


--
-- Name: test_category_master test_category_master_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_category_master
    ADD CONSTRAINT test_category_master_pkey PRIMARY KEY (id);


--
-- Name: test_master test_master_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_master
    ADD CONSTRAINT test_master_pkey PRIMARY KEY (id);


--
-- Name: test_parameter_mapping test_parameter_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_parameter_mapping
    ADD CONSTRAINT test_parameter_mapping_pkey PRIMARY KEY (id);


--
-- Name: test_parameter_mapping ug_test_parameter_mapping; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_parameter_mapping
    ADD CONSTRAINT ug_test_parameter_mapping UNIQUE (organization_id, branch_id, test_id, parameter_id);


--
-- Name: accession_master uq_accession_number; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accession_master
    ADD CONSTRAINT uq_accession_number UNIQUE (organization_id, branch_id, accession_number);


--
-- Name: accession_tests uq_accession_test; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accession_tests
    ADD CONSTRAINT uq_accession_test UNIQUE (accession_id, billing_test_id);


--
-- Name: accession_tests uq_accession_tests_barcode; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accession_tests
    ADD CONSTRAINT uq_accession_tests_barcode UNIQUE (organization_id, branch_id, barcode);


--
-- Name: application_settings uq_application_settings; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_settings
    ADD CONSTRAINT uq_application_settings UNIQUE (organization_id, branch_id, config_key);


--
-- Name: billing_master uq_bill_number; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_master
    ADD CONSTRAINT uq_bill_number UNIQUE (organization_id, branch_id, bill_number);


--
-- Name: billing_category_master uq_billing_category_code; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_category_master
    ADD CONSTRAINT uq_billing_category_code UNIQUE (organization_id, branch_id, billing_category_code);


--
-- Name: billing_category_master uq_billing_category_name; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_category_master
    ADD CONSTRAINT uq_billing_category_name UNIQUE (organization_id, branch_id, billing_category_name);


--
-- Name: container_type_master uq_container_type; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.container_type_master
    ADD CONSTRAINT uq_container_type UNIQUE (organization_id, branch_id, container_name);


--
-- Name: dashboard_cache uq_dashboard_cache; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_cache
    ADD CONSTRAINT uq_dashboard_cache UNIQUE (organization_id, branch_id, dashboard_key);


--
-- Name: department_master uq_department_org_code; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.department_master
    ADD CONSTRAINT uq_department_org_code UNIQUE (organization_id, branch_id, department_code);


--
-- Name: department_master uq_department_org_name; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.department_master
    ADD CONSTRAINT uq_department_org_name UNIQUE (organization_id, branch_id, department_name);


--
-- Name: instrument_master uq_instrument_code; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instrument_master
    ADD CONSTRAINT uq_instrument_code UNIQUE (organization_id, branch_id, instrument_code);


--
-- Name: instrument_test_mapping uq_instrument_mapping; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instrument_test_mapping
    ADD CONSTRAINT uq_instrument_mapping UNIQUE (organization_id, branch_id, instrument_id, machine_test_code, machine_parameter_code);


--
-- Name: menu_permission uq_menu_permission; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menu_permission
    ADD CONSTRAINT uq_menu_permission UNIQUE (organization_id, branch_id, role_id, menu_name);


--
-- Name: notification_template uq_notification_template; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_template
    ADD CONSTRAINT uq_notification_template UNIQUE (organization_id, branch_id, template_name, notification_type);


--
-- Name: parameter_master uq_parameter_master_code; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parameter_master
    ADD CONSTRAINT uq_parameter_master_code UNIQUE (organization_id, branch_id, parameter_code);


--
-- Name: parameter_master uq_parameter_master_name; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parameter_master
    ADD CONSTRAINT uq_parameter_master_name UNIQUE (organization_id, branch_id, parameter_name);


--
-- Name: patient_contacts uq_patient_contact; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_contacts
    ADD CONSTRAINT uq_patient_contact UNIQUE (organization_id, branch_id, contact_type, contact_value);


--
-- Name: patient_identifiers uq_patient_identifier; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_identifiers
    ADD CONSTRAINT uq_patient_identifier UNIQUE (organization_id, branch_id, identifier_type, identifier_value);


--
-- Name: payment_mode_master uq_payment_mode_master_code; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_mode_master
    ADD CONSTRAINT uq_payment_mode_master_code UNIQUE (organization_id, branch_id, payment_mode_code);


--
-- Name: performing_lab_master uq_performing_lab_code; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.performing_lab_master
    ADD CONSTRAINT uq_performing_lab_code UNIQUE (organization_id, branch_id, lab_code);


--
-- Name: performing_lab_master uq_performing_lab_name; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.performing_lab_master
    ADD CONSTRAINT uq_performing_lab_name UNIQUE (organization_id, branch_id, lab_name);


--
-- Name: qc_master uq_qc_master; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.qc_master
    ADD CONSTRAINT uq_qc_master UNIQUE (organization_id, branch_id, instrument_id, test_id, parameter_id, qc_level, lot_number);


--
-- Name: reference_range_master uq_reference_range_master; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reference_range_master
    ADD CONSTRAINT uq_reference_range_master UNIQUE (organization_id, branch_id, parameter_id, gender, age_min, age_max, pregnancy_flag, effective_from);


--
-- Name: report_master uq_report_accession; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_master
    ADD CONSTRAINT uq_report_accession UNIQUE (organization_id, branch_id, accession_id);


--
-- Name: report_master uq_report_number; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_master
    ADD CONSTRAINT uq_report_number UNIQUE (organization_id, branch_id, report_number);


--
-- Name: result_authorization uq_result_authorization; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.result_authorization
    ADD CONSTRAINT uq_result_authorization UNIQUE (organization_id, branch_id, result_entry_id);


--
-- Name: result_entry uq_result_entry; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.result_entry
    ADD CONSTRAINT uq_result_entry UNIQUE (organization_id, branch_id, accession_test_id);


--
-- Name: result_entry_details uq_result_parameter; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.result_entry_details
    ADD CONSTRAINT uq_result_parameter UNIQUE (result_entry_id, parameter_id);


--
-- Name: role_permission uq_role_permission; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permission
    ADD CONSTRAINT uq_role_permission UNIQUE (organization_id, branch_id, role_id, module_name);


--
-- Name: roles uq_roles_org_branch_code; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT uq_roles_org_branch_code UNIQUE (organization_id, branch_id, role_code);


--
-- Name: sample_collection uq_sample_collection; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sample_collection
    ADD CONSTRAINT uq_sample_collection UNIQUE (accession_test_id);


--
-- Name: sample_status_master uq_sample_status_master_code; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sample_status_master
    ADD CONSTRAINT uq_sample_status_master_code UNIQUE (organization_id, branch_id, sample_status_code);


--
-- Name: sample_type_master uq_sample_type_code; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sample_type_master
    ADD CONSTRAINT uq_sample_type_code UNIQUE (organization_id, branch_id, sample_code);


--
-- Name: sample_type_master uq_sample_type_name; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sample_type_master
    ADD CONSTRAINT uq_sample_type_name UNIQUE (organization_id, branch_id, sample_name);


--
-- Name: system_configuration uq_system_configuration; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_configuration
    ADD CONSTRAINT uq_system_configuration UNIQUE (organization_id, branch_id, config_key);


--
-- Name: test_category_master uq_test_category_code; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_category_master
    ADD CONSTRAINT uq_test_category_code UNIQUE (organization_id, branch_id, category_code);


--
-- Name: test_category_master uq_test_category_name; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_category_master
    ADD CONSTRAINT uq_test_category_name UNIQUE (organization_id, branch_id, category_name);


--
-- Name: test_master uq_test_code; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_master
    ADD CONSTRAINT uq_test_code UNIQUE (organization_id, branch_id, test_code);


--
-- Name: test_master uq_test_name; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_master
    ADD CONSTRAINT uq_test_name UNIQUE (organization_id, branch_id, test_name);


--
-- Name: worklist_master uq_worklist_code; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worklist_master
    ADD CONSTRAINT uq_worklist_code UNIQUE (organization_id, branch_id, worklist_code);


--
-- Name: worklist_master uq_worklist_name; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worklist_master
    ADD CONSTRAINT uq_worklist_name UNIQUE (organization_id, branch_id, worklist_name);


--
-- Name: worksheet_master uq_worksheet_code; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worksheet_master
    ADD CONSTRAINT uq_worksheet_code UNIQUE (organization_id, branch_id, worksheet_code);


--
-- Name: worksheet_master uq_worksheet_name; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worksheet_master
    ADD CONSTRAINT uq_worksheet_name UNIQUE (organization_id, branch_id, worksheet_name);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (user_id, role_id);


--
-- Name: users users_organization_id_branch_id_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_organization_id_branch_id_username_key UNIQUE (organization_id, branch_id, username);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: worklist_master worklist_master_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worklist_master
    ADD CONSTRAINT worklist_master_pkey PRIMARY KEY (id);


--
-- Name: worksheet_master worksheet_master_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worksheet_master
    ADD CONSTRAINT worksheet_master_pkey PRIMARY KEY (id);


--
-- Name: idx_accession_billing; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_accession_billing ON public.accession_master USING btree (billing_id);


--
-- Name: idx_accession_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_accession_number ON public.accession_master USING btree (accession_number);


--
-- Name: idx_accession_org_billing; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_accession_org_billing ON public.accession_master USING btree (organization_id, billing_id);


--
-- Name: idx_accession_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_accession_org_branch ON public.accession_master USING btree (organization_id, branch_id);


--
-- Name: idx_accession_org_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_accession_org_date ON public.accession_master USING btree (organization_id, accession_date);


--
-- Name: idx_accession_org_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_accession_org_number ON public.accession_master USING btree (organization_id, accession_number);


--
-- Name: idx_accession_org_patient; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_accession_org_patient ON public.accession_master USING btree (organization_id, patient_registration_id);


--
-- Name: idx_accession_org_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_accession_org_status ON public.accession_master USING btree (organization_id, status);


--
-- Name: idx_accession_patient; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_accession_patient ON public.accession_master USING btree (patient_registration_id);


--
-- Name: idx_accession_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_accession_status ON public.accession_master USING btree (status);


--
-- Name: idx_accession_tests_accession; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_accession_tests_accession ON public.accession_tests USING btree (accession_id);


--
-- Name: idx_accession_tests_authorization; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_accession_tests_authorization ON public.accession_tests USING btree (authorization_status);


--
-- Name: idx_accession_tests_barcode; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_accession_tests_barcode ON public.accession_tests USING btree (barcode);


--
-- Name: idx_accession_tests_collection_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_accession_tests_collection_status ON public.accession_tests USING btree (collection_status);


--
-- Name: idx_accession_tests_org_accession; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_accession_tests_org_accession ON public.accession_tests USING btree (organization_id, accession_id);


--
-- Name: idx_accession_tests_org_barcode; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_accession_tests_org_barcode ON public.accession_tests USING btree (organization_id, barcode);


--
-- Name: idx_accession_tests_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_accession_tests_org_branch ON public.accession_tests USING btree (organization_id, branch_id);


--
-- Name: idx_accession_tests_org_branch_barcode; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_accession_tests_org_branch_barcode ON public.accession_tests USING btree (organization_id, branch_id, barcode);


--
-- Name: idx_accession_tests_org_branch_sample_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_accession_tests_org_branch_sample_status ON public.accession_tests USING btree (organization_id, branch_id, sample_status);


--
-- Name: idx_accession_tests_report; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_accession_tests_report ON public.accession_tests USING btree (report_status);


--
-- Name: idx_accession_tests_sample_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_accession_tests_sample_status ON public.accession_tests USING btree (sample_status);


--
-- Name: idx_accession_tests_test; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_accession_tests_test ON public.accession_tests USING btree (test_id);


--
-- Name: idx_application_settings_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_application_settings_active ON public.application_settings USING btree (is_active);


--
-- Name: idx_application_settings_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_application_settings_key ON public.application_settings USING btree (config_key);


--
-- Name: idx_application_settings_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_application_settings_org ON public.application_settings USING btree (organization_id);


--
-- Name: idx_application_settings_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_application_settings_org_branch ON public.application_settings USING btree (organization_id, branch_id);


--
-- Name: idx_appointment_assignments_appointment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_appointment_assignments_appointment_id ON public.appointment_assignments USING btree (appointment_id);


--
-- Name: idx_appointment_assignments_assigned_to; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_appointment_assignments_assigned_to ON public.appointment_assignments USING btree (assigned_to);


--
-- Name: idx_appointment_assignments_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_appointment_assignments_org_branch ON public.appointment_assignments USING btree (organization_id, branch_id);


--
-- Name: idx_appointment_status_history_appointment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_appointment_status_history_appointment_id ON public.appointment_status_history USING btree (appointment_id);


--
-- Name: idx_appointment_status_history_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_appointment_status_history_org_branch ON public.appointment_status_history USING btree (organization_id, branch_id);


--
-- Name: idx_appointment_status_history_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_appointment_status_history_status ON public.appointment_status_history USING btree (status);


--
-- Name: idx_appointment_tests_appointment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_appointment_tests_appointment_id ON public.appointment_tests USING btree (appointment_id);


--
-- Name: idx_appointment_tests_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_appointment_tests_org_branch ON public.appointment_tests USING btree (organization_id, branch_id);


--
-- Name: idx_appointment_type_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_appointment_type_org ON public.appointment_type_master USING btree (organization_id);


--
-- Name: idx_appointment_type_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_appointment_type_org_branch ON public.appointment_type_master USING btree (organization_id, branch_id);


--
-- Name: idx_appointments_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_appointments_branch ON public.appointments USING btree (branch_id);


--
-- Name: idx_appointments_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_appointments_date ON public.appointments USING btree (appointment_date);


--
-- Name: idx_appointments_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_appointments_org ON public.appointments USING btree (organization_id);


--
-- Name: idx_appointments_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_appointments_org_branch ON public.appointments USING btree (organization_id, branch_id);


--
-- Name: idx_appointments_patient; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_appointments_patient ON public.appointments USING btree (patient_id);


--
-- Name: idx_appointments_registration; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_appointments_registration ON public.appointments USING btree (registration_id);


--
-- Name: idx_appointments_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_appointments_status ON public.appointments USING btree (appointment_status);


--
-- Name: idx_audit_logs_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_audit_logs_org_branch ON public.audit_logs USING btree (organization_id, branch_id);


--
-- Name: idx_bill_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bill_date ON public.billing_master USING btree (bill_date);


--
-- Name: idx_bill_number; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bill_number ON public.billing_master USING btree (bill_number);


--
-- Name: idx_bill_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bill_org ON public.billing_master USING btree (organization_id);


--
-- Name: idx_bill_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bill_org_branch ON public.billing_master USING btree (organization_id, branch_id);


--
-- Name: idx_bill_patient; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bill_patient ON public.billing_master USING btree (patient_registration_id);


--
-- Name: idx_bill_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bill_status ON public.billing_master USING btree (payment_status);


--
-- Name: idx_billing_category_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_billing_category_active ON public.billing_category_master USING btree (is_active);


--
-- Name: idx_billing_category_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_billing_category_code ON public.billing_category_master USING btree (billing_category_code);


--
-- Name: idx_billing_category_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_billing_category_name ON public.billing_category_master USING btree (billing_category_name);


--
-- Name: idx_billing_category_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_billing_category_org ON public.billing_category_master USING btree (organization_id);


--
-- Name: idx_billing_category_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_billing_category_org_branch ON public.billing_category_master USING btree (organization_id, branch_id);


--
-- Name: idx_billing_tests_barcode; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_billing_tests_barcode ON public.billing_tests USING btree (barcode);


--
-- Name: idx_billing_tests_bill; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_billing_tests_bill ON public.billing_tests USING btree (billing_id);


--
-- Name: idx_billing_tests_lab; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_billing_tests_lab ON public.billing_tests USING btree (performing_lab_id);


--
-- Name: idx_billing_tests_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_billing_tests_org ON public.billing_tests USING btree (organization_id);


--
-- Name: idx_billing_tests_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_billing_tests_org_branch ON public.billing_tests USING btree (organization_id, branch_id);


--
-- Name: idx_billing_tests_sample; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_billing_tests_sample ON public.billing_tests USING btree (sample_type_id);


--
-- Name: idx_billing_tests_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_billing_tests_status ON public.billing_tests USING btree (status);


--
-- Name: idx_billing_tests_test; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_billing_tests_test ON public.billing_tests USING btree (test_id);


--
-- Name: idx_branches_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_branches_org ON public.branches USING btree (organization_id);


--
-- Name: idx_clinical_master_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_clinical_master_org ON public.clinical_master USING btree (organization_id);


--
-- Name: idx_clinical_master_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_clinical_master_org_branch ON public.clinical_master USING btree (organization_id, branch_id);


--
-- Name: idx_container_type_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_container_type_name ON public.container_type_master USING btree (container_name);


--
-- Name: idx_container_type_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_container_type_org ON public.container_type_master USING btree (organization_id);


--
-- Name: idx_container_type_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_container_type_org_branch ON public.container_type_master USING btree (organization_id, branch_id);


--
-- Name: idx_dashboard_cache_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dashboard_cache_active ON public.dashboard_cache USING btree (is_active);


--
-- Name: idx_dashboard_cache_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dashboard_cache_branch ON public.dashboard_cache USING btree (branch_id);


--
-- Name: idx_dashboard_cache_generated; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dashboard_cache_generated ON public.dashboard_cache USING btree (generated_at);


--
-- Name: idx_dashboard_cache_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dashboard_cache_key ON public.dashboard_cache USING btree (dashboard_key);


--
-- Name: idx_dashboard_cache_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dashboard_cache_org ON public.dashboard_cache USING btree (organization_id);


--
-- Name: idx_dashboard_cache_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dashboard_cache_org_branch ON public.dashboard_cache USING btree (organization_id, branch_id);


--
-- Name: idx_department_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_department_name ON public.department_master USING btree (department_name);


--
-- Name: idx_department_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_department_org ON public.department_master USING btree (organization_id);


--
-- Name: idx_department_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_department_org_branch ON public.department_master USING btree (organization_id, branch_id);


--
-- Name: idx_instrument_configuration_instrument; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_instrument_configuration_instrument ON public.instrument_configuration USING btree (instrument_id);


--
-- Name: idx_instrument_configuration_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_instrument_configuration_org ON public.instrument_configuration USING btree (organization_id);


--
-- Name: idx_instrument_configuration_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_instrument_configuration_org_branch ON public.instrument_configuration USING btree (organization_id, branch_id);


--
-- Name: idx_instrument_configuration_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_instrument_configuration_status ON public.instrument_configuration USING btree (status);


--
-- Name: idx_instrument_master_department; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_instrument_master_department ON public.instrument_master USING btree (department_id);


--
-- Name: idx_instrument_master_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_instrument_master_name ON public.instrument_master USING btree (instrument_name);


--
-- Name: idx_instrument_master_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_instrument_master_org ON public.instrument_master USING btree (organization_id);


--
-- Name: idx_instrument_master_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_instrument_master_org_branch ON public.instrument_master USING btree (organization_id, branch_id);


--
-- Name: idx_instrument_master_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_instrument_master_status ON public.instrument_master USING btree (status);


--
-- Name: idx_instrument_transaction_barcode; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_instrument_transaction_barcode ON public.instrument_transaction_log USING btree (sample_barcode);


--
-- Name: idx_instrument_transaction_instrument; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_instrument_transaction_instrument ON public.instrument_transaction_log USING btree (instrument_id);


--
-- Name: idx_instrument_transaction_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_instrument_transaction_org ON public.instrument_transaction_log USING btree (organization_id);


--
-- Name: idx_instrument_transaction_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_instrument_transaction_org_branch ON public.instrument_transaction_log USING btree (organization_id, branch_id);


--
-- Name: idx_instrument_transaction_received; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_instrument_transaction_received ON public.instrument_transaction_log USING btree (received_at);


--
-- Name: idx_instrument_transaction_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_instrument_transaction_status ON public.instrument_transaction_log USING btree (processing_status);


--
-- Name: idx_itm_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_itm_active ON public.instrument_test_mapping USING btree (is_active);


--
-- Name: idx_itm_instrument; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_itm_instrument ON public.instrument_test_mapping USING btree (instrument_id);


--
-- Name: idx_itm_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_itm_org ON public.instrument_test_mapping USING btree (organization_id);


--
-- Name: idx_itm_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_itm_org_branch ON public.instrument_test_mapping USING btree (organization_id, branch_id);


--
-- Name: idx_itm_parameter; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_itm_parameter ON public.instrument_test_mapping USING btree (parameter_id);


--
-- Name: idx_itm_test; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_itm_test ON public.instrument_test_mapping USING btree (test_id);


--
-- Name: idx_lab_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_lab_active ON public.performing_lab_master USING btree (is_active);


--
-- Name: idx_lab_city; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_lab_city ON public.performing_lab_master USING btree (city);


--
-- Name: idx_lab_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_lab_code ON public.performing_lab_master USING btree (lab_code);


--
-- Name: idx_lab_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_lab_name ON public.performing_lab_master USING btree (lab_name);


--
-- Name: idx_menu_permission_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_menu_permission_org ON public.menu_permission USING btree (organization_id);


--
-- Name: idx_menu_permission_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_menu_permission_org_branch ON public.menu_permission USING btree (organization_id, branch_id);


--
-- Name: idx_menu_permission_role; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_menu_permission_role ON public.menu_permission USING btree (role_id);


--
-- Name: idx_notification_log_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notification_log_org ON public.notification_log USING btree (organization_id);


--
-- Name: idx_notification_log_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notification_log_org_branch ON public.notification_log USING btree (organization_id, branch_id);


--
-- Name: idx_notification_log_patient; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notification_log_patient ON public.notification_log USING btree (patient_registration_id);


--
-- Name: idx_notification_log_sent; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notification_log_sent ON public.notification_log USING btree (sent_at);


--
-- Name: idx_notification_log_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notification_log_status ON public.notification_log USING btree (status);


--
-- Name: idx_notification_log_template; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notification_log_template ON public.notification_log USING btree (template_id);


--
-- Name: idx_notification_template_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notification_template_active ON public.notification_template USING btree (is_active);


--
-- Name: idx_notification_template_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notification_template_org ON public.notification_template USING btree (organization_id);


--
-- Name: idx_notification_template_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notification_template_org_branch ON public.notification_template USING btree (organization_id, branch_id);


--
-- Name: idx_notification_template_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notification_template_type ON public.notification_template USING btree (notification_type);


--
-- Name: idx_outsource_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_outsource_active ON public.outsource_center_master USING btree (is_active);


--
-- Name: idx_outsource_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_outsource_name ON public.outsource_center_master USING btree (center_name);


--
-- Name: idx_outsource_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_outsource_org ON public.outsource_center_master USING btree (organization_id);


--
-- Name: idx_outsource_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_outsource_org_branch ON public.outsource_center_master USING btree (organization_id, branch_id);


--
-- Name: idx_parameter_master_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_parameter_master_active ON public.parameter_master USING btree (is_active);


--
-- Name: idx_parameter_master_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_parameter_master_code ON public.parameter_master USING btree (parameter_code);


--
-- Name: idx_parameter_master_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_parameter_master_name ON public.parameter_master USING btree (parameter_name);


--
-- Name: idx_parameter_master_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_parameter_master_org ON public.parameter_master USING btree (organization_id);


--
-- Name: idx_parameter_master_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_parameter_master_org_branch ON public.parameter_master USING btree (organization_id, branch_id);


--
-- Name: idx_patient_address_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_patient_address_org ON public.patient_addresses USING btree (organization_id);


--
-- Name: idx_patient_address_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_patient_address_org_branch ON public.patient_addresses USING btree (organization_id, branch_id);


--
-- Name: idx_patient_clinical_clinical; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_patient_clinical_clinical ON public.patient_clinical_history USING btree (clinical_id);


--
-- Name: idx_patient_clinical_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_patient_clinical_org_branch ON public.patient_clinical_history USING btree (organization_id, branch_id);


--
-- Name: idx_patient_clinical_patient; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_patient_clinical_patient ON public.patient_clinical_history USING btree (patient_id);


--
-- Name: idx_patient_clinical_registration; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_patient_clinical_registration ON public.patient_clinical_history USING btree (registration_id);


--
-- Name: idx_patient_contact_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_patient_contact_org ON public.patient_contacts USING btree (organization_id);


--
-- Name: idx_patient_contact_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_patient_contact_org_branch ON public.patient_contacts USING btree (organization_id, branch_id);


--
-- Name: idx_patient_contact_value; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_patient_contact_value ON public.patient_contacts USING btree (contact_value);


--
-- Name: idx_patient_identifier_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_patient_identifier_org ON public.patient_identifiers USING btree (organization_id);


--
-- Name: idx_patient_identifier_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_patient_identifier_org_branch ON public.patient_identifiers USING btree (organization_id, branch_id);


--
-- Name: idx_patient_identifier_value; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_patient_identifier_value ON public.patient_identifiers USING btree (identifier_value);


--
-- Name: idx_patient_photos_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_patient_photos_org ON public.patient_photos USING btree (organization_id);


--
-- Name: idx_patient_photos_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_patient_photos_org_branch ON public.patient_photos USING btree (organization_id, branch_id);


--
-- Name: idx_patient_photos_patient; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_patient_photos_patient ON public.patient_photos USING btree (patient_id);


--
-- Name: idx_patient_registration_created_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_patient_registration_created_by ON public.patient_registrations USING btree (created_by);


--
-- Name: idx_patient_registration_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_patient_registration_org ON public.patient_registrations USING btree (organization_id);


--
-- Name: idx_patient_registration_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_patient_registration_org_branch ON public.patient_registrations USING btree (organization_id, branch_id);


--
-- Name: idx_patient_registration_patient; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_patient_registration_patient ON public.patient_registrations USING btree (patient_id);


--
-- Name: idx_patient_trf_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_patient_trf_org ON public.patient_trf USING btree (organization_id);


--
-- Name: idx_patient_trf_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_patient_trf_org_branch ON public.patient_trf USING btree (organization_id, branch_id);


--
-- Name: idx_patient_trf_patient; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_patient_trf_patient ON public.patient_trf USING btree (patient_id);


--
-- Name: idx_patient_trf_registration; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_patient_trf_registration ON public.patient_trf USING btree (registration_id);


--
-- Name: idx_patients_dob; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_patients_dob ON public.patients USING btree (date_of_birth);


--
-- Name: idx_patients_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_patients_name ON public.patients USING btree (first_name, last_name);


--
-- Name: idx_patients_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_patients_org ON public.patients USING btree (organization_id);


--
-- Name: idx_patients_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_patients_org_branch ON public.patients USING btree (organization_id, branch_id);


--
-- Name: idx_payment_accession; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payment_accession ON public.payment USING btree (accession_id);


--
-- Name: idx_payment_bill; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payment_bill ON public.payment USING btree (billing_master_id);


--
-- Name: idx_payment_mode_master_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payment_mode_master_active ON public.payment_mode_master USING btree (is_active);


--
-- Name: idx_payment_mode_master_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payment_mode_master_code ON public.payment_mode_master USING btree (payment_mode_code);


--
-- Name: idx_payment_mode_master_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payment_mode_master_org ON public.payment_mode_master USING btree (organization_id);


--
-- Name: idx_payment_mode_master_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payment_mode_master_org_branch ON public.payment_mode_master USING btree (organization_id, branch_id);


--
-- Name: idx_payment_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payment_org ON public.payment USING btree (organization_id);


--
-- Name: idx_payment_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payment_org_branch ON public.payment USING btree (organization_id, branch_id);


--
-- Name: idx_payment_org_branch_payment_mode; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payment_org_branch_payment_mode ON public.payment USING btree (organization_id, branch_id, payment_mode);


--
-- Name: idx_payment_patient; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payment_patient ON public.payment USING btree (patient_registration_id);


--
-- Name: idx_payment_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payment_status ON public.payment USING btree (payment_status);


--
-- Name: idx_performing_lab_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_performing_lab_org ON public.performing_lab_master USING btree (organization_id);


--
-- Name: idx_performing_lab_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_performing_lab_org_branch ON public.performing_lab_master USING btree (organization_id, branch_id);


--
-- Name: idx_qc_master_instrument; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_qc_master_instrument ON public.qc_master USING btree (instrument_id);


--
-- Name: idx_qc_master_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_qc_master_org ON public.qc_master USING btree (organization_id);


--
-- Name: idx_qc_master_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_qc_master_org_branch ON public.qc_master USING btree (organization_id, branch_id);


--
-- Name: idx_qc_master_parameter; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_qc_master_parameter ON public.qc_master USING btree (parameter_id);


--
-- Name: idx_qc_master_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_qc_master_status ON public.qc_master USING btree (status);


--
-- Name: idx_qc_master_test; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_qc_master_test ON public.qc_master USING btree (test_id);


--
-- Name: idx_qc_run_datetime; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_qc_run_datetime ON public.qc_run_log USING btree (run_datetime);


--
-- Name: idx_qc_run_instrument; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_qc_run_instrument ON public.qc_run_log USING btree (instrument_id);


--
-- Name: idx_qc_run_master; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_qc_run_master ON public.qc_run_log USING btree (qc_master_id);


--
-- Name: idx_qc_run_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_qc_run_org ON public.qc_run_log USING btree (organization_id);


--
-- Name: idx_qc_run_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_qc_run_org_branch ON public.qc_run_log USING btree (organization_id, branch_id);


--
-- Name: idx_qc_run_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_qc_run_status ON public.qc_run_log USING btree (result_status);


--
-- Name: idx_ra_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ra_active ON public.result_authorization USING btree (is_active);


--
-- Name: idx_ra_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ra_org ON public.result_authorization USING btree (organization_id);


--
-- Name: idx_ra_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ra_org_branch ON public.result_authorization USING btree (organization_id, branch_id);


--
-- Name: idx_ra_result; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ra_result ON public.result_authorization USING btree (result_entry_id);


--
-- Name: idx_ra_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ra_status ON public.result_authorization USING btree (authorization_status);


--
-- Name: idx_rdl_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rdl_active ON public.report_delivery_log USING btree (is_active);


--
-- Name: idx_rdl_delivery_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rdl_delivery_type ON public.report_delivery_log USING btree (delivery_type);


--
-- Name: idx_rdl_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rdl_org ON public.report_delivery_log USING btree (organization_id);


--
-- Name: idx_rdl_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rdl_org_branch ON public.report_delivery_log USING btree (organization_id, branch_id);


--
-- Name: idx_rdl_recipient_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rdl_recipient_type ON public.report_delivery_log USING btree (recipient_type);


--
-- Name: idx_rdl_report; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rdl_report ON public.report_delivery_log USING btree (report_id);


--
-- Name: idx_rdl_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_rdl_status ON public.report_delivery_log USING btree (delivery_status);


--
-- Name: idx_red_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_red_active ON public.result_entry_details USING btree (is_active);


--
-- Name: idx_red_flag; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_red_flag ON public.result_entry_details USING btree (result_flag);


--
-- Name: idx_red_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_red_org ON public.result_entry_details USING btree (organization_id);


--
-- Name: idx_red_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_red_org_branch ON public.result_entry_details USING btree (organization_id, branch_id);


--
-- Name: idx_red_parameter; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_red_parameter ON public.result_entry_details USING btree (parameter_id);


--
-- Name: idx_red_result; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_red_result ON public.result_entry_details USING btree (result_entry_id);


--
-- Name: idx_reference_range_master_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reference_range_master_active ON public.reference_range_master USING btree (is_active);


--
-- Name: idx_reference_range_master_effective; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reference_range_master_effective ON public.reference_range_master USING btree (effective_from, effective_to);


--
-- Name: idx_reference_range_master_lookup; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reference_range_master_lookup ON public.reference_range_master USING btree (parameter_id, gender, pregnancy_flag, is_active);


--
-- Name: idx_reference_range_master_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reference_range_master_org ON public.reference_range_master USING btree (organization_id);


--
-- Name: idx_reference_range_master_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reference_range_master_org_branch ON public.reference_range_master USING btree (organization_id, branch_id);


--
-- Name: idx_reference_range_master_parameter; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reference_range_master_parameter ON public.reference_range_master USING btree (parameter_id);


--
-- Name: idx_refund_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_refund_org ON public.refund USING btree (organization_id);


--
-- Name: idx_refund_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_refund_org_branch ON public.refund USING btree (organization_id, branch_id);


--
-- Name: idx_refund_payment; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_refund_payment ON public.refund USING btree (payment_id);


--
-- Name: idx_refund_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_refund_status ON public.refund USING btree (refund_status);


--
-- Name: idx_report_accession; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_report_accession ON public.report_master USING btree (accession_id);


--
-- Name: idx_report_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_report_active ON public.report_master USING btree (is_active);


--
-- Name: idx_report_generated; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_report_generated ON public.report_master USING btree (generated_at);


--
-- Name: idx_report_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_report_org ON public.report_master USING btree (organization_id);


--
-- Name: idx_report_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_report_org_branch ON public.report_master USING btree (organization_id, branch_id);


--
-- Name: idx_report_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_report_status ON public.report_master USING btree (report_status);


--
-- Name: idx_result_entry_accession; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_result_entry_accession ON public.result_entry USING btree (accession_test_id);


--
-- Name: idx_result_entry_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_result_entry_active ON public.result_entry USING btree (is_active);


--
-- Name: idx_result_entry_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_result_entry_org ON public.result_entry USING btree (organization_id);


--
-- Name: idx_result_entry_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_result_entry_org_branch ON public.result_entry USING btree (organization_id, branch_id);


--
-- Name: idx_result_entry_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_result_entry_status ON public.result_entry USING btree (result_status);


--
-- Name: idx_role_permission_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_role_permission_org ON public.role_permission USING btree (organization_id);


--
-- Name: idx_role_permission_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_role_permission_org_branch ON public.role_permission USING btree (organization_id, branch_id);


--
-- Name: idx_role_permission_role; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_role_permission_role ON public.role_permission USING btree (role_id);


--
-- Name: idx_roles_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_roles_org_branch ON public.roles USING btree (organization_id, branch_id);


--
-- Name: idx_sample_collection_accession_test; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sample_collection_accession_test ON public.sample_collection USING btree (accession_test_id);


--
-- Name: idx_sample_collection_collector; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sample_collection_collector ON public.sample_collection USING btree (collector_id);


--
-- Name: idx_sample_collection_condition; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sample_collection_condition ON public.sample_collection USING btree (sample_condition);


--
-- Name: idx_sample_collection_datetime; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sample_collection_datetime ON public.sample_collection USING btree (collection_datetime);


--
-- Name: idx_sample_collection_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sample_collection_org_branch ON public.sample_collection USING btree (organization_id, branch_id);


--
-- Name: idx_sample_collection_org_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sample_collection_org_status ON public.sample_collection USING btree (organization_id, collection_status);


--
-- Name: idx_sample_collection_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sample_collection_status ON public.sample_collection USING btree (collection_status);


--
-- Name: idx_sample_status_master_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sample_status_master_active ON public.sample_status_master USING btree (is_active);


--
-- Name: idx_sample_status_master_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sample_status_master_code ON public.sample_status_master USING btree (sample_status_code);


--
-- Name: idx_sample_status_master_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sample_status_master_org ON public.sample_status_master USING btree (organization_id);


--
-- Name: idx_sample_status_master_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sample_status_master_org_branch ON public.sample_status_master USING btree (organization_id, branch_id);


--
-- Name: idx_sample_tracking_collection; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sample_tracking_collection ON public.sample_tracking USING btree (sample_collection_id);


--
-- Name: idx_sample_tracking_datetime; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sample_tracking_datetime ON public.sample_tracking USING btree (tracked_at);


--
-- Name: idx_sample_tracking_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sample_tracking_org_branch ON public.sample_tracking USING btree (organization_id, branch_id);


--
-- Name: idx_sample_tracking_org_collection; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sample_tracking_org_collection ON public.sample_tracking USING btree (organization_id, sample_collection_id);


--
-- Name: idx_sample_tracking_org_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sample_tracking_org_status ON public.sample_tracking USING btree (organization_id, tracking_status);


--
-- Name: idx_sample_tracking_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sample_tracking_status ON public.sample_tracking USING btree (tracking_status);


--
-- Name: idx_sample_type_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sample_type_active ON public.sample_type_master USING btree (is_active);


--
-- Name: idx_sample_type_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sample_type_code ON public.sample_type_master USING btree (sample_code);


--
-- Name: idx_sample_type_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sample_type_name ON public.sample_type_master USING btree (sample_name);


--
-- Name: idx_sample_type_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sample_type_org ON public.sample_type_master USING btree (organization_id);


--
-- Name: idx_sample_type_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sample_type_org_branch ON public.sample_type_master USING btree (organization_id, branch_id);


--
-- Name: idx_system_configuration_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_system_configuration_active ON public.system_configuration USING btree (is_active);


--
-- Name: idx_system_configuration_key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_system_configuration_key ON public.system_configuration USING btree (config_key);


--
-- Name: idx_system_configuration_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_system_configuration_org ON public.system_configuration USING btree (organization_id);


--
-- Name: idx_system_configuration_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_system_configuration_org_branch ON public.system_configuration USING btree (organization_id, branch_id);


--
-- Name: idx_test_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_test_active ON public.test_master USING btree (is_active);


--
-- Name: idx_test_billing_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_test_billing_category ON public.test_master USING btree (billing_category_id);


--
-- Name: idx_test_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_test_category ON public.test_master USING btree (test_category_id);


--
-- Name: idx_test_category_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_test_category_active ON public.test_category_master USING btree (is_active);


--
-- Name: idx_test_category_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_test_category_code ON public.test_category_master USING btree (category_code);


--
-- Name: idx_test_category_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_test_category_name ON public.test_category_master USING btree (category_name);


--
-- Name: idx_test_category_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_test_category_org ON public.test_category_master USING btree (organization_id);


--
-- Name: idx_test_category_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_test_category_org_branch ON public.test_category_master USING btree (organization_id, branch_id);


--
-- Name: idx_test_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_test_code ON public.test_master USING btree (test_code);


--
-- Name: idx_test_department; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_test_department ON public.test_master USING btree (department_id);


--
-- Name: idx_test_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_test_name ON public.test_master USING btree (test_name);


--
-- Name: idx_test_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_test_org ON public.test_master USING btree (organization_id);


--
-- Name: idx_test_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_test_org_branch ON public.test_master USING btree (organization_id, branch_id);


--
-- Name: idx_test_outsource; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_test_outsource ON public.test_master USING btree (outsource_center_id);


--
-- Name: idx_test_performing_lab; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_test_performing_lab ON public.test_master USING btree (performing_lab_id);


--
-- Name: idx_test_sample; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_test_sample ON public.test_master USING btree (sample_type_id);


--
-- Name: idx_test_worklist; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_test_worklist ON public.test_master USING btree (worklist_id);


--
-- Name: idx_test_worksheet; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_test_worksheet ON public.test_master USING btree (worksheet_id);


--
-- Name: idx_tpm_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tpm_active ON public.test_parameter_mapping USING btree (is_active);


--
-- Name: idx_tpm_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tpm_org ON public.test_parameter_mapping USING btree (organization_id);


--
-- Name: idx_tpm_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tpm_org_branch ON public.test_parameter_mapping USING btree (organization_id, branch_id);


--
-- Name: idx_tpm_parameter; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tpm_parameter ON public.test_parameter_mapping USING btree (parameter_id);


--
-- Name: idx_tpm_test; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tpm_test ON public.test_parameter_mapping USING btree (test_id);


--
-- Name: idx_user_roles_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_roles_org_branch ON public.user_roles USING btree (organization_id, branch_id);


--
-- Name: idx_users_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_org_branch ON public.users USING btree (organization_id, branch_id);


--
-- Name: idx_worklist_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_worklist_active ON public.worklist_master USING btree (is_active);


--
-- Name: idx_worklist_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_worklist_code ON public.worklist_master USING btree (worklist_code);


--
-- Name: idx_worklist_department; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_worklist_department ON public.worklist_master USING btree (department_id);


--
-- Name: idx_worklist_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_worklist_name ON public.worklist_master USING btree (worklist_name);


--
-- Name: idx_worklist_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_worklist_org ON public.worklist_master USING btree (organization_id);


--
-- Name: idx_worklist_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_worklist_org_branch ON public.worklist_master USING btree (organization_id, branch_id);


--
-- Name: idx_worksheet_code; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_worksheet_code ON public.worksheet_master USING btree (worksheet_code);


--
-- Name: idx_worksheet_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_worksheet_name ON public.worksheet_master USING btree (worksheet_name);


--
-- Name: idx_worksheet_org; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_worksheet_org ON public.worksheet_master USING btree (organization_id);


--
-- Name: idx_worksheet_org_branch; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_worksheet_org_branch ON public.worksheet_master USING btree (organization_id, branch_id);


--
-- Name: reference_range_master trg_prevent_reference_range_overlap; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_prevent_reference_range_overlap BEFORE INSERT OR UPDATE ON public.reference_range_master FOR EACH ROW EXECUTE FUNCTION public.prevent_reference_range_overlap();


--
-- Name: accession_master accession_master_billing_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accession_master
    ADD CONSTRAINT accession_master_billing_id_fkey FOREIGN KEY (billing_id) REFERENCES public.billing_master(id);


--
-- Name: accession_master accession_master_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accession_master
    ADD CONSTRAINT accession_master_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: accession_master accession_master_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accession_master
    ADD CONSTRAINT accession_master_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: accession_master accession_master_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accession_master
    ADD CONSTRAINT accession_master_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: accession_master accession_master_patient_registration_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accession_master
    ADD CONSTRAINT accession_master_patient_registration_id_fkey FOREIGN KEY (patient_registration_id) REFERENCES public.patient_registrations(id);


--
-- Name: accession_master accession_master_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accession_master
    ADD CONSTRAINT accession_master_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: accession_tests accession_tests_accession_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accession_tests
    ADD CONSTRAINT accession_tests_accession_id_fkey FOREIGN KEY (accession_id) REFERENCES public.accession_master(id) ON DELETE CASCADE;


--
-- Name: accession_tests accession_tests_billing_test_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accession_tests
    ADD CONSTRAINT accession_tests_billing_test_id_fkey FOREIGN KEY (billing_test_id) REFERENCES public.billing_tests(id);


--
-- Name: accession_tests accession_tests_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accession_tests
    ADD CONSTRAINT accession_tests_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: accession_tests accession_tests_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accession_tests
    ADD CONSTRAINT accession_tests_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: accession_tests accession_tests_last_printed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accession_tests
    ADD CONSTRAINT accession_tests_last_printed_by_fkey FOREIGN KEY (last_printed_by) REFERENCES public.users(id);


--
-- Name: accession_tests accession_tests_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accession_tests
    ADD CONSTRAINT accession_tests_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: accession_tests accession_tests_performing_lab_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accession_tests
    ADD CONSTRAINT accession_tests_performing_lab_id_fkey FOREIGN KEY (performing_lab_id) REFERENCES public.performing_lab_master(id);


--
-- Name: accession_tests accession_tests_sample_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accession_tests
    ADD CONSTRAINT accession_tests_sample_type_id_fkey FOREIGN KEY (sample_type_id) REFERENCES public.sample_type_master(id);


--
-- Name: accession_tests accession_tests_test_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accession_tests
    ADD CONSTRAINT accession_tests_test_id_fkey FOREIGN KEY (test_id) REFERENCES public.test_master(id);


--
-- Name: accession_tests accession_tests_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accession_tests
    ADD CONSTRAINT accession_tests_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: accession_tests accession_tests_worklist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accession_tests
    ADD CONSTRAINT accession_tests_worklist_id_fkey FOREIGN KEY (worklist_id) REFERENCES public.worklist_master(id);


--
-- Name: accession_tests accession_tests_worksheet_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accession_tests
    ADD CONSTRAINT accession_tests_worksheet_id_fkey FOREIGN KEY (worksheet_id) REFERENCES public.worksheet_master(id);


--
-- Name: application_settings application_settings_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_settings
    ADD CONSTRAINT application_settings_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: application_settings application_settings_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_settings
    ADD CONSTRAINT application_settings_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: application_settings application_settings_deleted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_settings
    ADD CONSTRAINT application_settings_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: application_settings application_settings_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_settings
    ADD CONSTRAINT application_settings_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: application_settings application_settings_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.application_settings
    ADD CONSTRAINT application_settings_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: appointment_assignments appointment_assignments_appointment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointment_assignments
    ADD CONSTRAINT appointment_assignments_appointment_id_fkey FOREIGN KEY (appointment_id) REFERENCES public.appointments(id);


--
-- Name: appointment_assignments appointment_assignments_assigned_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointment_assignments
    ADD CONSTRAINT appointment_assignments_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.users(id);


--
-- Name: appointment_assignments appointment_assignments_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointment_assignments
    ADD CONSTRAINT appointment_assignments_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: appointment_assignments appointment_assignments_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointment_assignments
    ADD CONSTRAINT appointment_assignments_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: appointment_assignments appointment_assignments_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointment_assignments
    ADD CONSTRAINT appointment_assignments_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: appointment_assignments appointment_assignments_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointment_assignments
    ADD CONSTRAINT appointment_assignments_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: appointment_status_history appointment_status_history_appointment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointment_status_history
    ADD CONSTRAINT appointment_status_history_appointment_id_fkey FOREIGN KEY (appointment_id) REFERENCES public.appointments(id);


--
-- Name: appointment_status_history appointment_status_history_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointment_status_history
    ADD CONSTRAINT appointment_status_history_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: appointment_status_history appointment_status_history_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointment_status_history
    ADD CONSTRAINT appointment_status_history_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: appointment_status_history appointment_status_history_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointment_status_history
    ADD CONSTRAINT appointment_status_history_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: appointment_tests appointment_tests_appointment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointment_tests
    ADD CONSTRAINT appointment_tests_appointment_id_fkey FOREIGN KEY (appointment_id) REFERENCES public.appointments(id);


--
-- Name: appointment_tests appointment_tests_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointment_tests
    ADD CONSTRAINT appointment_tests_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: appointment_tests appointment_tests_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointment_tests
    ADD CONSTRAINT appointment_tests_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: appointment_tests appointment_tests_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointment_tests
    ADD CONSTRAINT appointment_tests_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: appointment_tests appointment_tests_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointment_tests
    ADD CONSTRAINT appointment_tests_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: appointment_type_master appointment_type_master_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointment_type_master
    ADD CONSTRAINT appointment_type_master_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: appointment_type_master appointment_type_master_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointment_type_master
    ADD CONSTRAINT appointment_type_master_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: appointment_type_master appointment_type_master_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointment_type_master
    ADD CONSTRAINT appointment_type_master_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: appointment_type_master appointment_type_master_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointment_type_master
    ADD CONSTRAINT appointment_type_master_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: appointments appointments_appointment_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_appointment_type_id_fkey FOREIGN KEY (appointment_type_id) REFERENCES public.appointment_type_master(id);


--
-- Name: appointments appointments_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: appointments appointments_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: appointments appointments_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: appointments appointments_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- Name: appointments appointments_registration_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_registration_id_fkey FOREIGN KEY (registration_id) REFERENCES public.patient_registrations(id);


--
-- Name: appointments appointments_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.appointments
    ADD CONSTRAINT appointments_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: audit_logs audit_logs_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: audit_logs audit_logs_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: audit_logs audit_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: billing_category_master billing_category_master_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_category_master
    ADD CONSTRAINT billing_category_master_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: billing_category_master billing_category_master_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_category_master
    ADD CONSTRAINT billing_category_master_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: billing_category_master billing_category_master_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_category_master
    ADD CONSTRAINT billing_category_master_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: billing_category_master billing_category_master_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_category_master
    ADD CONSTRAINT billing_category_master_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: billing_master billing_master_billing_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_master
    ADD CONSTRAINT billing_master_billing_category_id_fkey FOREIGN KEY (billing_category_id) REFERENCES public.billing_category_master(id);


--
-- Name: billing_master billing_master_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_master
    ADD CONSTRAINT billing_master_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: billing_master billing_master_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_master
    ADD CONSTRAINT billing_master_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: billing_master billing_master_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_master
    ADD CONSTRAINT billing_master_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: billing_master billing_master_patient_registration_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_master
    ADD CONSTRAINT billing_master_patient_registration_id_fkey FOREIGN KEY (patient_registration_id) REFERENCES public.patient_registrations(id);


--
-- Name: billing_master billing_master_referring_doctor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_master
    ADD CONSTRAINT billing_master_referring_doctor_id_fkey FOREIGN KEY (referring_doctor_id) REFERENCES public.users(id);


--
-- Name: billing_master billing_master_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_master
    ADD CONSTRAINT billing_master_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: billing_tests billing_tests_billing_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_tests
    ADD CONSTRAINT billing_tests_billing_id_fkey FOREIGN KEY (billing_id) REFERENCES public.billing_master(id);


--
-- Name: billing_tests billing_tests_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_tests
    ADD CONSTRAINT billing_tests_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: billing_tests billing_tests_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_tests
    ADD CONSTRAINT billing_tests_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: billing_tests billing_tests_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_tests
    ADD CONSTRAINT billing_tests_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: billing_tests billing_tests_performing_lab_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_tests
    ADD CONSTRAINT billing_tests_performing_lab_id_fkey FOREIGN KEY (performing_lab_id) REFERENCES public.performing_lab_master(id);


--
-- Name: billing_tests billing_tests_sample_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_tests
    ADD CONSTRAINT billing_tests_sample_type_id_fkey FOREIGN KEY (sample_type_id) REFERENCES public.sample_type_master(id);


--
-- Name: billing_tests billing_tests_test_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_tests
    ADD CONSTRAINT billing_tests_test_id_fkey FOREIGN KEY (test_id) REFERENCES public.test_master(id);


--
-- Name: billing_tests billing_tests_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.billing_tests
    ADD CONSTRAINT billing_tests_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: branches branches_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.branches
    ADD CONSTRAINT branches_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: clinical_master clinical_master_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clinical_master
    ADD CONSTRAINT clinical_master_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: clinical_master clinical_master_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clinical_master
    ADD CONSTRAINT clinical_master_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: clinical_master clinical_master_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clinical_master
    ADD CONSTRAINT clinical_master_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: clinical_master clinical_master_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clinical_master
    ADD CONSTRAINT clinical_master_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: container_type_master container_type_master_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.container_type_master
    ADD CONSTRAINT container_type_master_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: container_type_master container_type_master_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.container_type_master
    ADD CONSTRAINT container_type_master_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: container_type_master container_type_master_deleted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.container_type_master
    ADD CONSTRAINT container_type_master_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: container_type_master container_type_master_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.container_type_master
    ADD CONSTRAINT container_type_master_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: container_type_master container_type_master_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.container_type_master
    ADD CONSTRAINT container_type_master_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: dashboard_cache dashboard_cache_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_cache
    ADD CONSTRAINT dashboard_cache_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: dashboard_cache dashboard_cache_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_cache
    ADD CONSTRAINT dashboard_cache_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: dashboard_cache dashboard_cache_deleted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_cache
    ADD CONSTRAINT dashboard_cache_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: dashboard_cache dashboard_cache_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_cache
    ADD CONSTRAINT dashboard_cache_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: dashboard_cache dashboard_cache_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dashboard_cache
    ADD CONSTRAINT dashboard_cache_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: department_master department_master_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.department_master
    ADD CONSTRAINT department_master_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: department_master department_master_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.department_master
    ADD CONSTRAINT department_master_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: department_master department_master_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.department_master
    ADD CONSTRAINT department_master_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: department_master department_master_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.department_master
    ADD CONSTRAINT department_master_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: accession_tests fk_accession_tests_sample_status; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accession_tests
    ADD CONSTRAINT fk_accession_tests_sample_status FOREIGN KEY (organization_id, branch_id, sample_status) REFERENCES public.sample_status_master(organization_id, branch_id, sample_status_code);


--
-- Name: payment fk_payment_payment_mode; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT fk_payment_payment_mode FOREIGN KEY (organization_id, branch_id, payment_mode) REFERENCES public.payment_mode_master(organization_id, branch_id, payment_mode_code);


--
-- Name: instrument_configuration instrument_configuration_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instrument_configuration
    ADD CONSTRAINT instrument_configuration_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: instrument_configuration instrument_configuration_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instrument_configuration
    ADD CONSTRAINT instrument_configuration_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: instrument_configuration instrument_configuration_deleted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instrument_configuration
    ADD CONSTRAINT instrument_configuration_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: instrument_configuration instrument_configuration_instrument_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instrument_configuration
    ADD CONSTRAINT instrument_configuration_instrument_id_fkey FOREIGN KEY (instrument_id) REFERENCES public.instrument_master(id);


--
-- Name: instrument_configuration instrument_configuration_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instrument_configuration
    ADD CONSTRAINT instrument_configuration_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: instrument_configuration instrument_configuration_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instrument_configuration
    ADD CONSTRAINT instrument_configuration_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: instrument_master instrument_master_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instrument_master
    ADD CONSTRAINT instrument_master_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: instrument_master instrument_master_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instrument_master
    ADD CONSTRAINT instrument_master_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: instrument_master instrument_master_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instrument_master
    ADD CONSTRAINT instrument_master_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.department_master(id);


--
-- Name: instrument_master instrument_master_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instrument_master
    ADD CONSTRAINT instrument_master_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: instrument_master instrument_master_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instrument_master
    ADD CONSTRAINT instrument_master_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: instrument_test_mapping instrument_test_mapping_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instrument_test_mapping
    ADD CONSTRAINT instrument_test_mapping_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: instrument_test_mapping instrument_test_mapping_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instrument_test_mapping
    ADD CONSTRAINT instrument_test_mapping_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: instrument_test_mapping instrument_test_mapping_deleted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instrument_test_mapping
    ADD CONSTRAINT instrument_test_mapping_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: instrument_test_mapping instrument_test_mapping_instrument_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instrument_test_mapping
    ADD CONSTRAINT instrument_test_mapping_instrument_id_fkey FOREIGN KEY (instrument_id) REFERENCES public.instrument_master(id);


--
-- Name: instrument_test_mapping instrument_test_mapping_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instrument_test_mapping
    ADD CONSTRAINT instrument_test_mapping_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: instrument_test_mapping instrument_test_mapping_parameter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instrument_test_mapping
    ADD CONSTRAINT instrument_test_mapping_parameter_id_fkey FOREIGN KEY (parameter_id) REFERENCES public.parameter_master(id);


--
-- Name: instrument_test_mapping instrument_test_mapping_test_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instrument_test_mapping
    ADD CONSTRAINT instrument_test_mapping_test_id_fkey FOREIGN KEY (test_id) REFERENCES public.test_master(id);


--
-- Name: instrument_test_mapping instrument_test_mapping_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instrument_test_mapping
    ADD CONSTRAINT instrument_test_mapping_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: instrument_transaction_log instrument_transaction_log_accession_test_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instrument_transaction_log
    ADD CONSTRAINT instrument_transaction_log_accession_test_id_fkey FOREIGN KEY (accession_test_id) REFERENCES public.accession_tests(id);


--
-- Name: instrument_transaction_log instrument_transaction_log_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instrument_transaction_log
    ADD CONSTRAINT instrument_transaction_log_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: instrument_transaction_log instrument_transaction_log_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instrument_transaction_log
    ADD CONSTRAINT instrument_transaction_log_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: instrument_transaction_log instrument_transaction_log_deleted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instrument_transaction_log
    ADD CONSTRAINT instrument_transaction_log_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: instrument_transaction_log instrument_transaction_log_instrument_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instrument_transaction_log
    ADD CONSTRAINT instrument_transaction_log_instrument_id_fkey FOREIGN KEY (instrument_id) REFERENCES public.instrument_master(id);


--
-- Name: instrument_transaction_log instrument_transaction_log_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instrument_transaction_log
    ADD CONSTRAINT instrument_transaction_log_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: instrument_transaction_log instrument_transaction_log_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.instrument_transaction_log
    ADD CONSTRAINT instrument_transaction_log_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: menu_permission menu_permission_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menu_permission
    ADD CONSTRAINT menu_permission_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: menu_permission menu_permission_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menu_permission
    ADD CONSTRAINT menu_permission_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: menu_permission menu_permission_deleted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menu_permission
    ADD CONSTRAINT menu_permission_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: menu_permission menu_permission_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menu_permission
    ADD CONSTRAINT menu_permission_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: menu_permission menu_permission_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menu_permission
    ADD CONSTRAINT menu_permission_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: menu_permission menu_permission_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.menu_permission
    ADD CONSTRAINT menu_permission_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: notification_log notification_log_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_log
    ADD CONSTRAINT notification_log_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: notification_log notification_log_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_log
    ADD CONSTRAINT notification_log_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: notification_log notification_log_deleted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_log
    ADD CONSTRAINT notification_log_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: notification_log notification_log_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_log
    ADD CONSTRAINT notification_log_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: notification_log notification_log_patient_registration_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_log
    ADD CONSTRAINT notification_log_patient_registration_id_fkey FOREIGN KEY (patient_registration_id) REFERENCES public.patient_registrations(id);


--
-- Name: notification_log notification_log_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_log
    ADD CONSTRAINT notification_log_template_id_fkey FOREIGN KEY (template_id) REFERENCES public.notification_template(id);


--
-- Name: notification_log notification_log_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_log
    ADD CONSTRAINT notification_log_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: notification_template notification_template_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_template
    ADD CONSTRAINT notification_template_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: notification_template notification_template_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_template
    ADD CONSTRAINT notification_template_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: notification_template notification_template_deleted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_template
    ADD CONSTRAINT notification_template_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: notification_template notification_template_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_template
    ADD CONSTRAINT notification_template_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: notification_template notification_template_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notification_template
    ADD CONSTRAINT notification_template_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: outsource_center_master outsource_center_master_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outsource_center_master
    ADD CONSTRAINT outsource_center_master_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: outsource_center_master outsource_center_master_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outsource_center_master
    ADD CONSTRAINT outsource_center_master_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: outsource_center_master outsource_center_master_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outsource_center_master
    ADD CONSTRAINT outsource_center_master_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: outsource_center_master outsource_center_master_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.outsource_center_master
    ADD CONSTRAINT outsource_center_master_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: parameter_master parameter_master_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parameter_master
    ADD CONSTRAINT parameter_master_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: parameter_master parameter_master_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parameter_master
    ADD CONSTRAINT parameter_master_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: parameter_master parameter_master_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parameter_master
    ADD CONSTRAINT parameter_master_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: parameter_master parameter_master_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parameter_master
    ADD CONSTRAINT parameter_master_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: patient_addresses patient_addresses_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_addresses
    ADD CONSTRAINT patient_addresses_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: patient_addresses patient_addresses_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_addresses
    ADD CONSTRAINT patient_addresses_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: patient_addresses patient_addresses_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_addresses
    ADD CONSTRAINT patient_addresses_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: patient_addresses patient_addresses_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_addresses
    ADD CONSTRAINT patient_addresses_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- Name: patient_addresses patient_addresses_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_addresses
    ADD CONSTRAINT patient_addresses_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: patient_clinical_history patient_clinical_history_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_clinical_history
    ADD CONSTRAINT patient_clinical_history_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: patient_clinical_history patient_clinical_history_clinical_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_clinical_history
    ADD CONSTRAINT patient_clinical_history_clinical_id_fkey FOREIGN KEY (clinical_id) REFERENCES public.clinical_master(id);


--
-- Name: patient_clinical_history patient_clinical_history_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_clinical_history
    ADD CONSTRAINT patient_clinical_history_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: patient_clinical_history patient_clinical_history_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_clinical_history
    ADD CONSTRAINT patient_clinical_history_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: patient_clinical_history patient_clinical_history_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_clinical_history
    ADD CONSTRAINT patient_clinical_history_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- Name: patient_clinical_history patient_clinical_history_registration_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_clinical_history
    ADD CONSTRAINT patient_clinical_history_registration_id_fkey FOREIGN KEY (registration_id) REFERENCES public.patient_registrations(id);


--
-- Name: patient_clinical_history patient_clinical_history_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_clinical_history
    ADD CONSTRAINT patient_clinical_history_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: patient_contacts patient_contacts_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_contacts
    ADD CONSTRAINT patient_contacts_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: patient_contacts patient_contacts_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_contacts
    ADD CONSTRAINT patient_contacts_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: patient_contacts patient_contacts_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_contacts
    ADD CONSTRAINT patient_contacts_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: patient_contacts patient_contacts_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_contacts
    ADD CONSTRAINT patient_contacts_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- Name: patient_contacts patient_contacts_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_contacts
    ADD CONSTRAINT patient_contacts_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: patient_identifiers patient_identifiers_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_identifiers
    ADD CONSTRAINT patient_identifiers_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: patient_identifiers patient_identifiers_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_identifiers
    ADD CONSTRAINT patient_identifiers_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: patient_identifiers patient_identifiers_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_identifiers
    ADD CONSTRAINT patient_identifiers_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- Name: patient_photos patient_photos_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_photos
    ADD CONSTRAINT patient_photos_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: patient_photos patient_photos_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_photos
    ADD CONSTRAINT patient_photos_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: patient_photos patient_photos_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_photos
    ADD CONSTRAINT patient_photos_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: patient_photos patient_photos_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_photos
    ADD CONSTRAINT patient_photos_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- Name: patient_registrations patient_registrations_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_registrations
    ADD CONSTRAINT patient_registrations_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: patient_registrations patient_registrations_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_registrations
    ADD CONSTRAINT patient_registrations_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: patient_registrations patient_registrations_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_registrations
    ADD CONSTRAINT patient_registrations_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: patient_registrations patient_registrations_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_registrations
    ADD CONSTRAINT patient_registrations_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- Name: patient_trf patient_trf_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_trf
    ADD CONSTRAINT patient_trf_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: patient_trf patient_trf_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_trf
    ADD CONSTRAINT patient_trf_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: patient_trf patient_trf_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_trf
    ADD CONSTRAINT patient_trf_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.patients(id);


--
-- Name: patient_trf patient_trf_registration_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_trf
    ADD CONSTRAINT patient_trf_registration_id_fkey FOREIGN KEY (registration_id) REFERENCES public.patient_registrations(id);


--
-- Name: patient_trf patient_trf_uploaded_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patient_trf
    ADD CONSTRAINT patient_trf_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES public.users(id);


--
-- Name: patients patients_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: patients patients_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: patients patients_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: patients patients_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.patients
    ADD CONSTRAINT patients_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: payment payment_accession_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_accession_id_fkey FOREIGN KEY (accession_id) REFERENCES public.accession_master(id);


--
-- Name: payment payment_billing_master_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_billing_master_id_fkey FOREIGN KEY (billing_master_id) REFERENCES public.billing_master(id);


--
-- Name: payment payment_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: payment payment_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: payment payment_deleted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: payment_mode_master payment_mode_master_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_mode_master
    ADD CONSTRAINT payment_mode_master_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: payment_mode_master payment_mode_master_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_mode_master
    ADD CONSTRAINT payment_mode_master_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: payment_mode_master payment_mode_master_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_mode_master
    ADD CONSTRAINT payment_mode_master_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: payment_mode_master payment_mode_master_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_mode_master
    ADD CONSTRAINT payment_mode_master_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: payment payment_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: payment payment_patient_registration_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_patient_registration_id_fkey FOREIGN KEY (patient_registration_id) REFERENCES public.patient_registrations(id);


--
-- Name: payment payment_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: performing_lab_master performing_lab_master_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.performing_lab_master
    ADD CONSTRAINT performing_lab_master_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: performing_lab_master performing_lab_master_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.performing_lab_master
    ADD CONSTRAINT performing_lab_master_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: performing_lab_master performing_lab_master_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.performing_lab_master
    ADD CONSTRAINT performing_lab_master_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: performing_lab_master performing_lab_master_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.performing_lab_master
    ADD CONSTRAINT performing_lab_master_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: qc_master qc_master_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.qc_master
    ADD CONSTRAINT qc_master_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: qc_master qc_master_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.qc_master
    ADD CONSTRAINT qc_master_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: qc_master qc_master_deleted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.qc_master
    ADD CONSTRAINT qc_master_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: qc_master qc_master_instrument_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.qc_master
    ADD CONSTRAINT qc_master_instrument_id_fkey FOREIGN KEY (instrument_id) REFERENCES public.instrument_master(id);


--
-- Name: qc_master qc_master_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.qc_master
    ADD CONSTRAINT qc_master_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: qc_master qc_master_parameter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.qc_master
    ADD CONSTRAINT qc_master_parameter_id_fkey FOREIGN KEY (parameter_id) REFERENCES public.parameter_master(id);


--
-- Name: qc_master qc_master_test_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.qc_master
    ADD CONSTRAINT qc_master_test_id_fkey FOREIGN KEY (test_id) REFERENCES public.test_master(id);


--
-- Name: qc_master qc_master_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.qc_master
    ADD CONSTRAINT qc_master_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: qc_run_log qc_run_log_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.qc_run_log
    ADD CONSTRAINT qc_run_log_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: qc_run_log qc_run_log_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.qc_run_log
    ADD CONSTRAINT qc_run_log_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: qc_run_log qc_run_log_deleted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.qc_run_log
    ADD CONSTRAINT qc_run_log_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: qc_run_log qc_run_log_instrument_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.qc_run_log
    ADD CONSTRAINT qc_run_log_instrument_id_fkey FOREIGN KEY (instrument_id) REFERENCES public.instrument_master(id);


--
-- Name: qc_run_log qc_run_log_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.qc_run_log
    ADD CONSTRAINT qc_run_log_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: qc_run_log qc_run_log_qc_master_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.qc_run_log
    ADD CONSTRAINT qc_run_log_qc_master_id_fkey FOREIGN KEY (qc_master_id) REFERENCES public.qc_master(id);


--
-- Name: qc_run_log qc_run_log_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.qc_run_log
    ADD CONSTRAINT qc_run_log_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: reference_range_master reference_range_master_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reference_range_master
    ADD CONSTRAINT reference_range_master_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: reference_range_master reference_range_master_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reference_range_master
    ADD CONSTRAINT reference_range_master_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: reference_range_master reference_range_master_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reference_range_master
    ADD CONSTRAINT reference_range_master_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: reference_range_master reference_range_master_parameter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reference_range_master
    ADD CONSTRAINT reference_range_master_parameter_id_fkey FOREIGN KEY (parameter_id) REFERENCES public.parameter_master(id) ON DELETE CASCADE;


--
-- Name: reference_range_master reference_range_master_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reference_range_master
    ADD CONSTRAINT reference_range_master_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: refund refund_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refund
    ADD CONSTRAINT refund_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: refund refund_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refund
    ADD CONSTRAINT refund_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: refund refund_deleted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refund
    ADD CONSTRAINT refund_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: refund refund_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refund
    ADD CONSTRAINT refund_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: refund refund_payment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refund
    ADD CONSTRAINT refund_payment_id_fkey FOREIGN KEY (payment_id) REFERENCES public.payment(id);


--
-- Name: refund refund_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.refund
    ADD CONSTRAINT refund_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: report_delivery_log report_delivery_log_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_delivery_log
    ADD CONSTRAINT report_delivery_log_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: report_delivery_log report_delivery_log_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_delivery_log
    ADD CONSTRAINT report_delivery_log_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: report_delivery_log report_delivery_log_delivered_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_delivery_log
    ADD CONSTRAINT report_delivery_log_delivered_by_fkey FOREIGN KEY (delivered_by) REFERENCES public.users(id);


--
-- Name: report_delivery_log report_delivery_log_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_delivery_log
    ADD CONSTRAINT report_delivery_log_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: report_delivery_log report_delivery_log_report_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_delivery_log
    ADD CONSTRAINT report_delivery_log_report_id_fkey FOREIGN KEY (report_id) REFERENCES public.report_master(id) ON DELETE CASCADE;


--
-- Name: report_delivery_log report_delivery_log_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_delivery_log
    ADD CONSTRAINT report_delivery_log_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: report_master report_master_accession_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_master
    ADD CONSTRAINT report_master_accession_id_fkey FOREIGN KEY (accession_id) REFERENCES public.accession_master(id) ON DELETE CASCADE;


--
-- Name: report_master report_master_authorized_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_master
    ADD CONSTRAINT report_master_authorized_by_fkey FOREIGN KEY (authorized_by) REFERENCES public.users(id);


--
-- Name: report_master report_master_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_master
    ADD CONSTRAINT report_master_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: report_master report_master_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_master
    ADD CONSTRAINT report_master_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: report_master report_master_generated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_master
    ADD CONSTRAINT report_master_generated_by_fkey FOREIGN KEY (generated_by) REFERENCES public.users(id);


--
-- Name: report_master report_master_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_master
    ADD CONSTRAINT report_master_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: report_master report_master_printed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_master
    ADD CONSTRAINT report_master_printed_by_fkey FOREIGN KEY (printed_by) REFERENCES public.users(id);


--
-- Name: report_master report_master_released_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_master
    ADD CONSTRAINT report_master_released_by_fkey FOREIGN KEY (released_by) REFERENCES public.users(id);


--
-- Name: report_master report_master_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_master
    ADD CONSTRAINT report_master_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: result_authorization result_authorization_authorized_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.result_authorization
    ADD CONSTRAINT result_authorization_authorized_by_fkey FOREIGN KEY (authorized_by) REFERENCES public.users(id);


--
-- Name: result_authorization result_authorization_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.result_authorization
    ADD CONSTRAINT result_authorization_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: result_authorization result_authorization_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.result_authorization
    ADD CONSTRAINT result_authorization_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: result_authorization result_authorization_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.result_authorization
    ADD CONSTRAINT result_authorization_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: result_authorization result_authorization_result_entry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.result_authorization
    ADD CONSTRAINT result_authorization_result_entry_id_fkey FOREIGN KEY (result_entry_id) REFERENCES public.result_entry(id) ON DELETE CASCADE;


--
-- Name: result_authorization result_authorization_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.result_authorization
    ADD CONSTRAINT result_authorization_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: result_entry result_entry_accession_test_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.result_entry
    ADD CONSTRAINT result_entry_accession_test_id_fkey FOREIGN KEY (accession_test_id) REFERENCES public.accession_tests(id) ON DELETE CASCADE;


--
-- Name: result_entry result_entry_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.result_entry
    ADD CONSTRAINT result_entry_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: result_entry result_entry_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.result_entry
    ADD CONSTRAINT result_entry_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: result_entry_details result_entry_details_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.result_entry_details
    ADD CONSTRAINT result_entry_details_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: result_entry_details result_entry_details_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.result_entry_details
    ADD CONSTRAINT result_entry_details_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: result_entry_details result_entry_details_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.result_entry_details
    ADD CONSTRAINT result_entry_details_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: result_entry_details result_entry_details_parameter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.result_entry_details
    ADD CONSTRAINT result_entry_details_parameter_id_fkey FOREIGN KEY (parameter_id) REFERENCES public.parameter_master(id);


--
-- Name: result_entry_details result_entry_details_result_entry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.result_entry_details
    ADD CONSTRAINT result_entry_details_result_entry_id_fkey FOREIGN KEY (result_entry_id) REFERENCES public.result_entry(id);


--
-- Name: result_entry_details result_entry_details_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.result_entry_details
    ADD CONSTRAINT result_entry_details_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: result_entry result_entry_entered_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.result_entry
    ADD CONSTRAINT result_entry_entered_by_fkey FOREIGN KEY (entered_by) REFERENCES public.users(id);


--
-- Name: result_entry result_entry_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.result_entry
    ADD CONSTRAINT result_entry_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: result_entry result_entry_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.result_entry
    ADD CONSTRAINT result_entry_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: result_entry result_entry_verified_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.result_entry
    ADD CONSTRAINT result_entry_verified_by_fkey FOREIGN KEY (verified_by) REFERENCES public.users(id);


--
-- Name: role_permission role_permission_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permission
    ADD CONSTRAINT role_permission_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: role_permission role_permission_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permission
    ADD CONSTRAINT role_permission_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: role_permission role_permission_deleted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permission
    ADD CONSTRAINT role_permission_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: role_permission role_permission_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permission
    ADD CONSTRAINT role_permission_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: role_permission role_permission_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permission
    ADD CONSTRAINT role_permission_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: role_permission role_permission_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role_permission
    ADD CONSTRAINT role_permission_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: roles roles_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: roles roles_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: sample_collection sample_collection_accession_test_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sample_collection
    ADD CONSTRAINT sample_collection_accession_test_id_fkey FOREIGN KEY (accession_test_id) REFERENCES public.accession_tests(id) ON DELETE CASCADE;


--
-- Name: sample_collection sample_collection_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sample_collection
    ADD CONSTRAINT sample_collection_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: sample_collection sample_collection_collector_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sample_collection
    ADD CONSTRAINT sample_collection_collector_id_fkey FOREIGN KEY (collector_id) REFERENCES public.users(id);


--
-- Name: sample_collection sample_collection_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sample_collection
    ADD CONSTRAINT sample_collection_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: sample_collection sample_collection_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sample_collection
    ADD CONSTRAINT sample_collection_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: sample_collection sample_collection_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sample_collection
    ADD CONSTRAINT sample_collection_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: sample_status_master sample_status_master_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sample_status_master
    ADD CONSTRAINT sample_status_master_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: sample_status_master sample_status_master_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sample_status_master
    ADD CONSTRAINT sample_status_master_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: sample_status_master sample_status_master_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sample_status_master
    ADD CONSTRAINT sample_status_master_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: sample_status_master sample_status_master_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sample_status_master
    ADD CONSTRAINT sample_status_master_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: sample_tracking sample_tracking_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sample_tracking
    ADD CONSTRAINT sample_tracking_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: sample_tracking sample_tracking_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sample_tracking
    ADD CONSTRAINT sample_tracking_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: sample_tracking sample_tracking_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sample_tracking
    ADD CONSTRAINT sample_tracking_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: sample_tracking sample_tracking_sample_collection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sample_tracking
    ADD CONSTRAINT sample_tracking_sample_collection_id_fkey FOREIGN KEY (sample_collection_id) REFERENCES public.sample_collection(id) ON DELETE CASCADE;


--
-- Name: sample_tracking sample_tracking_tracked_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sample_tracking
    ADD CONSTRAINT sample_tracking_tracked_by_fkey FOREIGN KEY (tracked_by) REFERENCES public.users(id);


--
-- Name: sample_tracking sample_tracking_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sample_tracking
    ADD CONSTRAINT sample_tracking_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: sample_type_master sample_type_master_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sample_type_master
    ADD CONSTRAINT sample_type_master_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: sample_type_master sample_type_master_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sample_type_master
    ADD CONSTRAINT sample_type_master_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: sample_type_master sample_type_master_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sample_type_master
    ADD CONSTRAINT sample_type_master_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: sample_type_master sample_type_master_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sample_type_master
    ADD CONSTRAINT sample_type_master_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: system_configuration system_configuration_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_configuration
    ADD CONSTRAINT system_configuration_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: system_configuration system_configuration_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_configuration
    ADD CONSTRAINT system_configuration_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: system_configuration system_configuration_deleted_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_configuration
    ADD CONSTRAINT system_configuration_deleted_by_fkey FOREIGN KEY (deleted_by) REFERENCES public.users(id);


--
-- Name: system_configuration system_configuration_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_configuration
    ADD CONSTRAINT system_configuration_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: system_configuration system_configuration_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.system_configuration
    ADD CONSTRAINT system_configuration_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: test_category_master test_category_master_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_category_master
    ADD CONSTRAINT test_category_master_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: test_category_master test_category_master_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_category_master
    ADD CONSTRAINT test_category_master_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: test_category_master test_category_master_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_category_master
    ADD CONSTRAINT test_category_master_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: test_category_master test_category_master_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_category_master
    ADD CONSTRAINT test_category_master_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: test_master test_master_billing_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_master
    ADD CONSTRAINT test_master_billing_category_id_fkey FOREIGN KEY (billing_category_id) REFERENCES public.billing_category_master(id);


--
-- Name: test_master test_master_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_master
    ADD CONSTRAINT test_master_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: test_master test_master_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_master
    ADD CONSTRAINT test_master_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: test_master test_master_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_master
    ADD CONSTRAINT test_master_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.department_master(id);


--
-- Name: test_master test_master_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_master
    ADD CONSTRAINT test_master_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: test_master test_master_outsource_center_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_master
    ADD CONSTRAINT test_master_outsource_center_id_fkey FOREIGN KEY (outsource_center_id) REFERENCES public.outsource_center_master(id);


--
-- Name: test_master test_master_performing_lab_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_master
    ADD CONSTRAINT test_master_performing_lab_id_fkey FOREIGN KEY (performing_lab_id) REFERENCES public.performing_lab_master(id);


--
-- Name: test_master test_master_sample_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_master
    ADD CONSTRAINT test_master_sample_type_id_fkey FOREIGN KEY (sample_type_id) REFERENCES public.sample_type_master(id);


--
-- Name: test_master test_master_test_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_master
    ADD CONSTRAINT test_master_test_category_id_fkey FOREIGN KEY (test_category_id) REFERENCES public.test_category_master(id);


--
-- Name: test_master test_master_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_master
    ADD CONSTRAINT test_master_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: test_master test_master_worklist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_master
    ADD CONSTRAINT test_master_worklist_id_fkey FOREIGN KEY (worklist_id) REFERENCES public.worklist_master(id);


--
-- Name: test_master test_master_worksheet_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_master
    ADD CONSTRAINT test_master_worksheet_id_fkey FOREIGN KEY (worksheet_id) REFERENCES public.worksheet_master(id);


--
-- Name: test_parameter_mapping test_parameter_mapping_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_parameter_mapping
    ADD CONSTRAINT test_parameter_mapping_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: test_parameter_mapping test_parameter_mapping_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_parameter_mapping
    ADD CONSTRAINT test_parameter_mapping_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: test_parameter_mapping test_parameter_mapping_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_parameter_mapping
    ADD CONSTRAINT test_parameter_mapping_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: test_parameter_mapping test_parameter_mapping_parameter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_parameter_mapping
    ADD CONSTRAINT test_parameter_mapping_parameter_id_fkey FOREIGN KEY (parameter_id) REFERENCES public.parameter_master(id) ON DELETE CASCADE;


--
-- Name: test_parameter_mapping test_parameter_mapping_test_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_parameter_mapping
    ADD CONSTRAINT test_parameter_mapping_test_id_fkey FOREIGN KEY (test_id) REFERENCES public.test_master(id);


--
-- Name: test_parameter_mapping test_parameter_mapping_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_parameter_mapping
    ADD CONSTRAINT test_parameter_mapping_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: user_roles user_roles_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: user_roles user_roles_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: user_roles user_roles_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: user_roles user_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: users users_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: users users_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: worklist_master worklist_master_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worklist_master
    ADD CONSTRAINT worklist_master_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: worklist_master worklist_master_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worklist_master
    ADD CONSTRAINT worklist_master_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: worklist_master worklist_master_department_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worklist_master
    ADD CONSTRAINT worklist_master_department_id_fkey FOREIGN KEY (department_id) REFERENCES public.department_master(id);


--
-- Name: worklist_master worklist_master_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worklist_master
    ADD CONSTRAINT worklist_master_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: worklist_master worklist_master_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worklist_master
    ADD CONSTRAINT worklist_master_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: worksheet_master worksheet_master_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worksheet_master
    ADD CONSTRAINT worksheet_master_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branches(id);


--
-- Name: worksheet_master worksheet_master_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worksheet_master
    ADD CONSTRAINT worksheet_master_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: worksheet_master worksheet_master_organization_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worksheet_master
    ADD CONSTRAINT worksheet_master_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES public.organizations(id);


--
-- Name: worksheet_master worksheet_master_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.worksheet_master
    ADD CONSTRAINT worksheet_master_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

\unrestrict CQfiUJBZddKBjt1i0GIQS0sfctwxwLf9EnZux8bBkTHd7ncfoFWEZtNlu28w3Rk

