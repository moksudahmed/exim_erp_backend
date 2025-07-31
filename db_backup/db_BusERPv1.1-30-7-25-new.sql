--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.22
-- Dumped by pg_dump version 9.5.22

-- Started on 2025-07-30 10:51:57

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 1 (class 3079 OID 12355)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2748 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- TOC entry 652 (class 1247 OID 132278)
-- Name: accountaction; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.accountaction AS ENUM (
    'DEBIT',
    'CREDIT'
);


ALTER TYPE public.accountaction OWNER TO postgres;

--
-- TOC entry 655 (class 1247 OID 132284)
-- Name: accountnature; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.accountnature AS ENUM (
    'DEBIT',
    'CREDIT'
);


ALTER TYPE public.accountnature OWNER TO postgres;

--
-- TOC entry 658 (class 1247 OID 132290)
-- Name: accounttypeenum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.accounttypeenum AS ENUM (
    'ASSET',
    'LIABILITY',
    'EQUITY',
    'REVENUE',
    'EXPENSE'
);


ALTER TYPE public.accounttypeenum OWNER TO postgres;

--
-- TOC entry 661 (class 1247 OID 132302)
-- Name: actiontype; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.actiontype AS ENUM (
    'ADD',
    'DAMAGED',
    'DEDUCT'
);


ALTER TYPE public.actiontype OWNER TO postgres;

--
-- TOC entry 664 (class 1247 OID 132310)
-- Name: client_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.client_type AS ENUM (
    'CUSTOMER',
    'SUPPLIER',
    'EMPLOYEE'
);


ALTER TYPE public.client_type OWNER TO postgres;

--
-- TOC entry 667 (class 1247 OID 132318)
-- Name: invoice_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.invoice_status AS ENUM (
    'draft',
    'sent',
    'paid',
    'overdue',
    'cancelled'
);


ALTER TYPE public.invoice_status OWNER TO postgres;

--
-- TOC entry 670 (class 1247 OID 132330)
-- Name: lc_status_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.lc_status_enum AS ENUM (
    'OPEN',
    'REALIZED',
    'CLOSED',
    'SUBMITTED',
    'UNDER_REVIEW',
    'APPROVED',
    'ISSUED',
    'GOODS_RECEIVED'
);


ALTER TYPE public.lc_status_enum OWNER TO postgres;

--
-- TOC entry 673 (class 1247 OID 132346)
-- Name: order_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.order_status AS ENUM (
    'PENDING',
    'RECEIVED',
    'COMPLETED',
    'CANCELLED'
);


ALTER TYPE public.order_status OWNER TO postgres;

--
-- TOC entry 676 (class 1247 OID 132356)
-- Name: payment_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.payment_status AS ENUM (
    'PENDING',
    'PARTIAL',
    'PAID',
    'DUE',
    'OVERDUE',
    'REFUNDED'
);


ALTER TYPE public.payment_status OWNER TO postgres;

--
-- TOC entry 679 (class 1247 OID 132370)
-- Name: paymentmethodenum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.paymentmethodenum AS ENUM (
    'cash',
    'check',
    'credit',
    'credit_card',
    'bank_transfer',
    'bkash',
    'nagad',
    'online',
    'other'
);


ALTER TYPE public.paymentmethodenum OWNER TO postgres;

--
-- TOC entry 682 (class 1247 OID 132390)
-- Name: paymentstatusenum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.paymentstatusenum AS ENUM (
    'PENDING',
    'PARTIAL',
    'PAID',
    'DUE',
    'OVERDUE',
    'REFUNDED'
);


ALTER TYPE public.paymentstatusenum OWNER TO postgres;

--
-- TOC entry 685 (class 1247 OID 132404)
-- Name: product_subcategory_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.product_subcategory_enum AS ENUM (
    'SUPER',
    'MEDIUM',
    'MIXTURE'
);


ALTER TYPE public.product_subcategory_enum OWNER TO postgres;

--
-- TOC entry 688 (class 1247 OID 132412)
-- Name: product_type_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.product_type_enum AS ENUM (
    'tangible',
    'intangible',
    'digital',
    'service',
    'liquid'
);


ALTER TYPE public.product_type_enum OWNER TO postgres;

--
-- TOC entry 691 (class 1247 OID 132424)
-- Name: transaction_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.transaction_type AS ENUM (
    'CREDIT',
    'DEBIT',
    'TRANSFER',
    'ADJUSTMENT'
);


ALTER TYPE public.transaction_type OWNER TO postgres;

--
-- TOC entry 694 (class 1247 OID 132434)
-- Name: unit_of_measurement_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.unit_of_measurement_enum AS ENUM (
    'piece',
    'kg',
    'g',
    'lb',
    'litre',
    'ml',
    'meter',
    'cm',
    'pack',
    'box',
    'dozen',
    'carton',
    'set',
    'hour',
    'service',
    'mt'
);


ALTER TYPE public.unit_of_measurement_enum OWNER TO postgres;

--
-- TOC entry 278 (class 1255 OID 132467)
-- Name: approve_lc_status(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.approve_lc_status() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE public.letter_of_credit
  SET status = 'APPROVED'
  WHERE id = NEW.lc_id;

  RETURN NEW;
END;
$$;


ALTER FUNCTION public.approve_lc_status() OWNER TO postgres;

--
-- TOC entry 279 (class 1255 OID 132468)
-- Name: check_journal_balance(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_journal_balance() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    entry_id INT;
    total_debit NUMERIC := 0;
    total_credit NUMERIC := 0;
BEGIN
    -- Only proceed for INSERT or UPDATE
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        -- Loop through affected journal_entry_ids
        FOR entry_id IN
            SELECT DISTINCT journal_entry_id FROM journal_items
            WHERE journal_entry_id IN (
                SELECT DISTINCT journal_entry_id FROM NEW_TABLE
            )
        LOOP
            -- Sum up debits and credits
            SELECT
                COALESCE(SUM(CASE WHEN debitcredit = 'DEBIT' THEN amount ELSE 0 END), 0),
                COALESCE(SUM(CASE WHEN debitcredit = 'CREDIT' THEN amount ELSE 0 END), 0)
            INTO total_debit, total_credit
            FROM journal_items
            WHERE journal_entry_id = entry_id;

            -- Check balance
            IF total_debit != total_credit THEN
                RAISE EXCEPTION 'Journal entry % must be balanced: debit (%.2f) ≠ credit (%.2f)', entry_id, total_debit, total_credit;
            END IF;
        END LOOP;
    END IF;

    RETURN NULL;
END;
$$;


ALTER FUNCTION public.check_journal_balance() OWNER TO postgres;

--
-- TOC entry 292 (class 1255 OID 132469)
-- Name: check_journal_entry_balance(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_journal_entry_balance() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    total_debit NUMERIC := 0;
    total_credit NUMERIC := 0;
BEGIN
    SELECT
        COALESCE(SUM(CASE WHEN debitcredit = 'DEBIT' THEN amount ELSE 0 END), 0),
        COALESCE(SUM(CASE WHEN debitcredit = 'CREDIT' THEN amount ELSE 0 END), 0)
    INTO total_debit, total_credit
    FROM journal_items
    WHERE journal_entry_id = NEW.id;

    IF total_debit != total_credit THEN
        RAISE EXCEPTION 'Journal entry % must be balanced: debit %.2f ≠ credit %.2f',
            NEW.id, total_debit, total_credit;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.check_journal_entry_balance() OWNER TO postgres;

--
-- TOC entry 293 (class 1255 OID 132470)
-- Name: create_lc_journal_entry(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.create_lc_journal_entry() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE    
    ref_type TEXT;
    margin_acct_id INT;
    lc_payable_acct_id INT;
    bank_acct_id INT;
    entry_id INT;
BEGIN
    -- Fetch account IDs
    SELECT account_id INTO margin_acct_id FROM account WHERE account_name = 'L/C Margin Account';  
    SELECT account_id INTO lc_payable_acct_id FROM account WHERE account_name = 'L/C Payable';  
    SELECT account_id INTO bank_acct_id FROM account WHERE account_name = 'Bank A/C';
    
    -- Determine reference type
    IF TG_TABLE_NAME = 'lc_margin_payment' THEN
        ref_type := 'LC_MARGIN_PAYMENT';
    ELSIF TG_TABLE_NAME = 'lc_final_payment' THEN
        ref_type := 'LC_FINAL_PAYMENT';
    ELSE
        RAISE EXCEPTION 'Unknown trigger table: %', TG_TABLE_NAME;
    END IF;

    -- Insert into journal_entries
    INSERT INTO journal_entries (
        transaction_date, description, company, account_type, ref_no, created_at, user_id
    ) VALUES (
        NEW.payment_date,
        ref_type || ' for LC ID ' || NEW.lc_id,
        ref_type || ' for LC ID',
        'EXPENSE',
        NEW.id,
        now(),
        1
    )
    RETURNING id INTO entry_id;

    -- Insert journal_items using NEW.amount
    IF ref_type = 'LC_MARGIN_PAYMENT' THEN
        INSERT INTO journal_items (journal_entry_id, account_id, subsidiary_account_id, amount, debitcredit, narration)
        VALUES
            (entry_id, margin_acct_id, NEW.account_id, NEW.amount, 'DEBIT', 'LC Margin Payment'),
            (entry_id, bank_acct_id, NEW.account_id, NEW.amount, 'CREDIT', 'LC Margin Payment');

    ELSIF ref_type = 'LC_FINAL_PAYMENT' THEN
        INSERT INTO journal_items (journal_entry_id, account_id, subsidiary_account_id, amount, debitcredit, narration)
        VALUES
            (entry_id, lc_payable_acct_id, NEW.account_id, NEW.amount, 'DEBIT', 'LC Final Payment'),
            (entry_id, bank_acct_id, NEW.account_id, NEW.amount, 'CREDIT', 'LC Final Payment');
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.create_lc_journal_entry() OWNER TO postgres;

--
-- TOC entry 294 (class 1255 OID 132471)
-- Name: final_payment_lc_status(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.final_payment_lc_status() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE public.letter_of_credit
  SET status = 'CLOSED'
  WHERE id = NEW.lc_id;

  RETURN NEW;
END;
$$;


ALTER FUNCTION public.final_payment_lc_status() OWNER TO postgres;

--
-- TOC entry 295 (class 1255 OID 132472)
-- Name: goods_received_lc_status(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.goods_received_lc_status() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE public.letter_of_credit
  SET status = 'GOODS_RECEIVED'
  WHERE id = NEW.lc_id;

  RETURN NEW;
END;
$$;


ALTER FUNCTION public.goods_received_lc_status() OWNER TO postgres;

--
-- TOC entry 296 (class 1255 OID 132473)
-- Name: issuance_lc_status(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.issuance_lc_status() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE public.letter_of_credit
  SET status = 'ISSUED'
  WHERE id = NEW.lc_id;

  RETURN NEW;
END;
$$;


ALTER FUNCTION public.issuance_lc_status() OWNER TO postgres;

--
-- TOC entry 297 (class 1255 OID 132474)
-- Name: submitted_lc_status(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.submitted_lc_status() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE public.letter_of_credit
  SET status = 'SUBMITTED'
  WHERE id = NEW.lc_id;

  RETURN NEW;
END;
$$;


ALTER FUNCTION public.submitted_lc_status() OWNER TO postgres;

--
-- TOC entry 181 (class 1259 OID 132475)
-- Name: account_account_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.account_account_id_seq
    START WITH 11
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_account_id_seq OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 182 (class 1259 OID 132477)
-- Name: account; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account (
    account_id integer DEFAULT nextval('public.account_account_id_seq'::regclass) NOT NULL,
    account_name character varying NOT NULL,
    account_type public.accounttypeenum NOT NULL,
    balance numeric NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    business_id integer NOT NULL,
    parent_id integer,
    code character varying,
    is_active boolean DEFAULT true
);


ALTER TABLE public.account OWNER TO postgres;

--
-- TOC entry 183 (class 1259 OID 132486)
-- Name: journal_entries_id_seq1; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.journal_entries_id_seq1
    START WITH 85
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.journal_entries_id_seq1 OWNER TO postgres;

--
-- TOC entry 184 (class 1259 OID 132488)
-- Name: journal_entries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.journal_entries (
    id integer DEFAULT nextval('public.journal_entries_id_seq1'::regclass) NOT NULL,
    ref_no character varying NOT NULL,
    account_type public.accounttypeenum NOT NULL,
    company character varying NOT NULL,
    transaction_date timestamp without time zone,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    user_id integer NOT NULL,
    description text
);


ALTER TABLE public.journal_entries OWNER TO postgres;

--
-- TOC entry 185 (class 1259 OID 132496)
-- Name: journal_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.journal_items_id_seq
    START WITH 150
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.journal_items_id_seq OWNER TO postgres;

--
-- TOC entry 186 (class 1259 OID 132498)
-- Name: journal_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.journal_items (
    id integer DEFAULT nextval('public.journal_items_id_seq'::regclass) NOT NULL,
    journal_entry_id integer NOT NULL,
    narration character varying NOT NULL,
    debitcredit public.accountaction NOT NULL,
    amount numeric NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    account_id integer NOT NULL,
    subsidiary_account_id integer
);


ALTER TABLE public.journal_items OWNER TO postgres;

--
-- TOC entry 187 (class 1259 OID 132506)
-- Name: account_ledger; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.account_ledger AS
 SELECT a.account_name,
    j.created_at,
    j.description,
        CASE
            WHEN (i.debitcredit = 'DEBIT'::public.accountaction) THEN i.amount
            ELSE (0)::numeric
        END AS debit,
        CASE
            WHEN (i.debitcredit = 'CREDIT'::public.accountaction) THEN i.amount
            ELSE (0)::numeric
        END AS credit,
    (
        CASE
            WHEN (i.debitcredit = 'DEBIT'::public.accountaction) THEN i.amount
            ELSE (0)::numeric
        END -
        CASE
            WHEN (i.debitcredit = 'CREDIT'::public.accountaction) THEN i.amount
            ELSE (0)::numeric
        END) AS amount,
    sum((
        CASE
            WHEN (i.debitcredit = 'DEBIT'::public.accountaction) THEN i.amount
            ELSE (0)::numeric
        END -
        CASE
            WHEN (i.debitcredit = 'CREDIT'::public.accountaction) THEN i.amount
            ELSE (0)::numeric
        END)) OVER (PARTITION BY i.account_id ORDER BY j.created_at, j.id) AS running_balance
   FROM ((public.journal_items i
     JOIN public.journal_entries j ON ((j.id = i.journal_entry_id)))
     JOIN public.account a ON ((a.account_id = i.account_id)))
  ORDER BY a.account_name, j.created_at;


ALTER TABLE public.account_ledger OWNER TO postgres;

--
-- TOC entry 188 (class 1259 OID 132511)
-- Name: accounts_payable_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.accounts_payable_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.accounts_payable_id_seq OWNER TO postgres;

--
-- TOC entry 189 (class 1259 OID 132513)
-- Name: accounts_payable; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.accounts_payable (
    id integer DEFAULT nextval('public.accounts_payable_id_seq'::regclass) NOT NULL,
    purchase_order_id integer,
    amount_due double precision NOT NULL,
    amount_paid double precision DEFAULT 0.0,
    user_id integer,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.accounts_payable OWNER TO postgres;

--
-- TOC entry 190 (class 1259 OID 132519)
-- Name: accounts_receivable_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.accounts_receivable_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.accounts_receivable_id_seq OWNER TO postgres;

--
-- TOC entry 191 (class 1259 OID 132521)
-- Name: accounts_receivable; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.accounts_receivable (
    id integer DEFAULT nextval('public.accounts_receivable_id_seq'::regclass) NOT NULL,
    customer_id integer,
    amount numeric NOT NULL,
    due_date timestamp without time zone NOT NULL,
    status boolean DEFAULT false,
    user_id integer
);


ALTER TABLE public.accounts_receivable OWNER TO postgres;

--
-- TOC entry 192 (class 1259 OID 132529)
-- Name: branch_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.branch_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.branch_id_seq OWNER TO postgres;

--
-- TOC entry 193 (class 1259 OID 132531)
-- Name: branch; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.branch (
    id integer DEFAULT nextval('public.branch_id_seq'::regclass) NOT NULL,
    branchaddress character varying,
    branchname character varying,
    contactno character varying,
    emailaddress character varying,
    business_id integer NOT NULL,
    employee_id integer,
    city character varying,
    country character varying,
    created_at time with time zone,
    updated_at time with time zone
);


ALTER TABLE public.branch OWNER TO postgres;

--
-- TOC entry 194 (class 1259 OID 132538)
-- Name: budget_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.budget_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.budget_id_seq OWNER TO postgres;

--
-- TOC entry 195 (class 1259 OID 132540)
-- Name: budget; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.budget (
    id integer DEFAULT nextval('public.budget_id_seq'::regclass) NOT NULL,
    account_id integer,
    budgeted_amount numeric NOT NULL,
    actual_amount numeric NOT NULL,
    variance numeric NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    user_id integer
);


ALTER TABLE public.budget OWNER TO postgres;

--
-- TOC entry 196 (class 1259 OID 132548)
-- Name: business_members; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.business_members (
    user_id integer NOT NULL,
    business_id integer NOT NULL,
    role character varying NOT NULL,
    joined_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.business_members OWNER TO postgres;

--
-- TOC entry 197 (class 1259 OID 132555)
-- Name: businesses_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.businesses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.businesses_id_seq OWNER TO postgres;

--
-- TOC entry 198 (class 1259 OID 132557)
-- Name: businesses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.businesses (
    id integer DEFAULT nextval('public.businesses_id_seq'::regclass) NOT NULL,
    name character varying NOT NULL,
    tax_id character varying,
    address character varying,
    phone character varying,
    email character varying,
    default_currency character varying DEFAULT 'USD'::character varying,
    fiscal_year_start date,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.businesses OWNER TO postgres;

--
-- TOC entry 199 (class 1259 OID 132566)
-- Name: client_client_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.client_client_id_seq
    START WITH 17
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.client_client_id_seq OWNER TO postgres;

--
-- TOC entry 200 (class 1259 OID 132568)
-- Name: client; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.client (
    client_id integer DEFAULT nextval('public.client_client_id_seq'::regclass) NOT NULL,
    client_type public.client_type NOT NULL,
    registration_date date,
    businesses_id integer NOT NULL,
    person_id integer
);


ALTER TABLE public.client OWNER TO postgres;

--
-- TOC entry 201 (class 1259 OID 132572)
-- Name: customers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.customers_id_seq
    START WITH 6
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.customers_id_seq OWNER TO postgres;

--
-- TOC entry 202 (class 1259 OID 132574)
-- Name: customers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customers (
    id integer DEFAULT nextval('public.customers_id_seq'::regclass) NOT NULL,
    name character varying NOT NULL,
    contact_info character varying,
    user_id integer
);


ALTER TABLE public.customers OWNER TO postgres;

--
-- TOC entry 203 (class 1259 OID 132581)
-- Name: deliveries_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.deliveries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.deliveries_id_seq OWNER TO postgres;

--
-- TOC entry 204 (class 1259 OID 132583)
-- Name: deliveries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.deliveries (
    id integer DEFAULT nextval('public.deliveries_id_seq'::regclass) NOT NULL,
    sale_id integer NOT NULL,
    driver_id integer NOT NULL,
    fare numeric NOT NULL,
    other_cost numeric DEFAULT 0,
    delivery_date timestamp with time zone DEFAULT now(),
    note text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    total_cost numeric DEFAULT 0 NOT NULL
);


ALTER TABLE public.deliveries OWNER TO postgres;

--
-- TOC entry 205 (class 1259 OID 132595)
-- Name: drivers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.drivers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.drivers_id_seq OWNER TO postgres;

--
-- TOC entry 206 (class 1259 OID 132597)
-- Name: drivers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.drivers (
    id integer DEFAULT nextval('public.drivers_id_seq'::regclass) NOT NULL,
    name character varying NOT NULL,
    phone_no character varying,
    truck_no character varying,
    measurment numeric NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.drivers OWNER TO postgres;

--
-- TOC entry 207 (class 1259 OID 132606)
-- Name: employees_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.employees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.employees_id_seq OWNER TO postgres;

--
-- TOC entry 208 (class 1259 OID 132608)
-- Name: employees; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employees (
    id integer DEFAULT nextval('public.employees_id_seq'::regclass) NOT NULL,
    name character varying NOT NULL,
    role character varying NOT NULL,
    contact_info character varying,
    user_id integer
);


ALTER TABLE public.employees OWNER TO postgres;

--
-- TOC entry 209 (class 1259 OID 132615)
-- Name: financial_periods_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.financial_periods_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.financial_periods_id_seq OWNER TO postgres;

--
-- TOC entry 210 (class 1259 OID 132617)
-- Name: financial_periods; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.financial_periods (
    id integer DEFAULT nextval('public.financial_periods_id_seq'::regclass) NOT NULL,
    name character varying NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    is_closed boolean DEFAULT false,
    closed_at timestamp without time zone,
    closed_by integer
);


ALTER TABLE public.financial_periods OWNER TO postgres;

--
-- TOC entry 211 (class 1259 OID 132625)
-- Name: financial_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.financial_reports_id_seq
    START WITH 10
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.financial_reports_id_seq OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 132627)
-- Name: financial_reports; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.financial_reports (
    id integer DEFAULT nextval('public.financial_reports_id_seq'::regclass) NOT NULL,
    name character varying NOT NULL,
    type character varying NOT NULL,
    period_id integer,
    start_date date,
    end_date date,
    data jsonb NOT NULL,
    generated_at timestamp without time zone DEFAULT now(),
    generated_by integer NOT NULL,
    CONSTRAINT financial_reports_type_check CHECK (((type)::text = ANY (ARRAY[('BALANCE_SHEET'::character varying)::text, ('INCOME_STATEMENT'::character varying)::text, ('CASH_FLOW'::character varying)::text, ('TRIAL_BALANCE'::character varying)::text, ('GENERAL_LEDGER'::character varying)::text])))
);


ALTER TABLE public.financial_reports OWNER TO postgres;

--
-- TOC entry 213 (class 1259 OID 132636)
-- Name: fixed_assets_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.fixed_assets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.fixed_assets_id_seq OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 132638)
-- Name: fixed_assets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fixed_assets (
    id integer DEFAULT nextval('public.fixed_assets_id_seq'::regclass) NOT NULL,
    asset_name character varying NOT NULL,
    purchase_date timestamp without time zone NOT NULL,
    purchase_price numeric NOT NULL,
    depreciation_rate numeric NOT NULL,
    user_id integer
);


ALTER TABLE public.fixed_assets OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 132645)
-- Name: general_ledger_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.general_ledger_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.general_ledger_id_seq OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 132647)
-- Name: inventory_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.inventory_log_id_seq
    START WITH 48
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.inventory_log_id_seq OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 132649)
-- Name: inventory_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inventory_log (
    id integer DEFAULT nextval('public.inventory_log_id_seq'::regclass) NOT NULL,
    product_id integer,
    action_type public.actiontype NOT NULL,
    quantity integer NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    user_id integer
);


ALTER TABLE public.inventory_log OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 132654)
-- Name: invoices_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.invoices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.invoices_id_seq OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 132656)
-- Name: invoices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.invoices (
    id integer DEFAULT nextval('public.invoices_id_seq'::regclass) NOT NULL,
    business_id integer,
    customer_id integer,
    sale_id integer,
    invoice_number character varying NOT NULL,
    issue_date date NOT NULL,
    due_date date NOT NULL,
    status public.invoice_status NOT NULL,
    total_amount numeric NOT NULL,
    amount_paid numeric DEFAULT 0,
    balance_due numeric NOT NULL
);


ALTER TABLE public.invoices OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 132664)
-- Name: journal_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.journal_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.journal_entries_id_seq OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 132666)
-- Name: journal_lines; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.journal_lines (
    line_id integer NOT NULL,
    journal_id integer,
    account_id integer,
    debit numeric(14,2) DEFAULT 0.00,
    credit numeric(14,2) DEFAULT 0.00
);


ALTER TABLE public.journal_lines OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 132671)
-- Name: journal_lines_line_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.journal_lines_line_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.journal_lines_line_id_seq OWNER TO postgres;

--
-- TOC entry 2749 (class 0 OID 0)
-- Dependencies: 222
-- Name: journal_lines_line_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.journal_lines_line_id_seq OWNED BY public.journal_lines.line_id;


--
-- TOC entry 223 (class 1259 OID 132673)
-- Name: journal_summary; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.journal_summary AS
 SELECT j.id,
    j.created_at,
    j.description,
    a.account_name,
    a.account_type,
    (
        CASE
            WHEN (i.debitcredit = 'DEBIT'::public.accountaction) THEN i.amount
            ELSE (0)::numeric
        END)::numeric(14,2) AS debit,
    (
        CASE
            WHEN (i.debitcredit = 'CREDIT'::public.accountaction) THEN i.amount
            ELSE (0)::numeric
        END)::numeric(14,2) AS credit
   FROM ((public.journal_entries j
     JOIN public.journal_items i ON ((j.id = i.journal_entry_id)))
     JOIN public.account a ON ((i.account_id = a.account_id)))
  ORDER BY j.id, i.id;


ALTER TABLE public.journal_summary OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 132678)
-- Name: lc_charges; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lc_charges (
    id integer NOT NULL,
    lc_id integer,
    charge_type character varying(100),
    amount numeric(12,2),
    charge_date date,
    description text
);


ALTER TABLE public.lc_charges OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 132684)
-- Name: lc_charges_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.lc_charges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.lc_charges_id_seq OWNER TO postgres;

--
-- TOC entry 2750 (class 0 OID 0)
-- Dependencies: 225
-- Name: lc_charges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.lc_charges_id_seq OWNED BY public.lc_charges.id;


--
-- TOC entry 226 (class 1259 OID 132686)
-- Name: lc_final_payment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lc_final_payment (
    id integer NOT NULL,
    lc_id integer NOT NULL,
    payment_date date NOT NULL,
    amount numeric(12,2) NOT NULL,
    payment_method character varying(50),
    account_id integer,
    reference_no character varying(100),
    remarks text
);


ALTER TABLE public.lc_final_payment OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 132692)
-- Name: lc_final_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.lc_final_payment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.lc_final_payment_id_seq OWNER TO postgres;

--
-- TOC entry 2751 (class 0 OID 0)
-- Dependencies: 227
-- Name: lc_final_payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.lc_final_payment_id_seq OWNED BY public.lc_final_payment.id;


--
-- TOC entry 228 (class 1259 OID 132694)
-- Name: lc_goods; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lc_goods (
    id integer NOT NULL,
    lc_id integer,
    product_id integer,
    quantity integer NOT NULL,
    unit_cost numeric(12,2),
    received boolean DEFAULT false
);


ALTER TABLE public.lc_goods OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 132698)
-- Name: lc_goods_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.lc_goods_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.lc_goods_id_seq OWNER TO postgres;

--
-- TOC entry 2752 (class 0 OID 0)
-- Dependencies: 229
-- Name: lc_goods_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.lc_goods_id_seq OWNED BY public.lc_goods.id;


--
-- TOC entry 275 (class 1259 OID 133381)
-- Name: lc_goods_receipt_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.lc_goods_receipt_id_seq
    START WITH 21
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.lc_goods_receipt_id_seq OWNER TO postgres;

--
-- TOC entry 276 (class 1259 OID 133383)
-- Name: lc_goods_receipt; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lc_goods_receipt (
    id integer DEFAULT nextval('public.lc_goods_receipt_id_seq'::regclass) NOT NULL,
    lc_id integer NOT NULL,
    receipt_date date NOT NULL,
    warehouse_id integer,
    receiver_name character varying(100),
    remarks text
);


ALTER TABLE public.lc_goods_receipt OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 132708)
-- Name: lc_goods_shipment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lc_goods_shipment (
    shipment_id integer NOT NULL,
    lc_id integer NOT NULL,
    shipment_date date NOT NULL,
    bl_number character varying(100),
    shipping_company character varying(100),
    port_of_loading character varying(100),
    port_of_discharge character varying(100),
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.lc_goods_shipment OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 132712)
-- Name: lc_goods_shipment_shipment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.lc_goods_shipment_shipment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.lc_goods_shipment_shipment_id_seq OWNER TO postgres;

--
-- TOC entry 2753 (class 0 OID 0)
-- Dependencies: 231
-- Name: lc_goods_shipment_shipment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.lc_goods_shipment_shipment_id_seq OWNED BY public.lc_goods_shipment.shipment_id;


--
-- TOC entry 232 (class 1259 OID 132714)
-- Name: lc_issuance_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.lc_issuance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.lc_issuance_id_seq OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 132716)
-- Name: lc_issuance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lc_issuance (
    id integer DEFAULT nextval('public.lc_issuance_id_seq'::regclass) NOT NULL,
    lc_id integer NOT NULL,
    issue_date date NOT NULL,
    issuing_bank character varying(100),
    remarks text
);


ALTER TABLE public.lc_issuance OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 132723)
-- Name: lc_margin_payment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lc_margin_payment (
    id integer NOT NULL,
    lc_id integer NOT NULL,
    payment_date date NOT NULL,
    amount numeric NOT NULL,
    account_id integer,
    note text
);


ALTER TABLE public.lc_margin_payment OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 132729)
-- Name: lc_margin_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.lc_margin_payment_id_seq
    START WITH 21
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.lc_margin_payment_id_seq OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 132731)
-- Name: lc_margin_payment_id_seq1; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.lc_margin_payment_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.lc_margin_payment_id_seq1 OWNER TO postgres;

--
-- TOC entry 2754 (class 0 OID 0)
-- Dependencies: 236
-- Name: lc_margin_payment_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.lc_margin_payment_id_seq1 OWNED BY public.lc_margin_payment.id;


--
-- TOC entry 237 (class 1259 OID 132733)
-- Name: lc_realization; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lc_realization (
    id integer NOT NULL,
    lc_id integer NOT NULL,
    realization_date date NOT NULL,
    amount_realized numeric(12,2) NOT NULL,
    document_reference character varying(100),
    remarks text
);


ALTER TABLE public.lc_realization OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 132739)
-- Name: lc_realization_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.lc_realization_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.lc_realization_id_seq OWNER TO postgres;

--
-- TOC entry 2755 (class 0 OID 0)
-- Dependencies: 238
-- Name: lc_realization_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.lc_realization_id_seq OWNED BY public.lc_realization.id;


--
-- TOC entry 239 (class 1259 OID 132741)
-- Name: lc_shipment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lc_shipment (
    id integer NOT NULL,
    lc_id integer NOT NULL,
    shipping_date date NOT NULL,
    transport_mode character varying(50),
    bill_of_lading_no character varying(100),
    shipped_from character varying(100),
    shipped_to character varying(100),
    notes text
);


ALTER TABLE public.lc_shipment OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 132747)
-- Name: lc_shipment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.lc_shipment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.lc_shipment_id_seq OWNER TO postgres;

--
-- TOC entry 2756 (class 0 OID 0)
-- Dependencies: 240
-- Name: lc_shipment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.lc_shipment_id_seq OWNED BY public.lc_shipment.id;


--
-- TOC entry 241 (class 1259 OID 132749)
-- Name: ledger_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ledger_id_seq
    START WITH 76
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ledger_id_seq OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 132751)
-- Name: ledger; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ledger (
    id integer DEFAULT nextval('public.ledger_id_seq'::regclass) NOT NULL,
    account_id integer NOT NULL,
    journal_item_id integer NOT NULL,
    entry_date date NOT NULL,
    amount numeric NOT NULL,
    balance numeric NOT NULL,
    type public.accountaction NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.ledger OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 132759)
-- Name: letter_of_credit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.letter_of_credit (
    id integer NOT NULL,
    issue_date date NOT NULL,
    status public.lc_status_enum DEFAULT 'OPEN'::public.lc_status_enum,
    created_at timestamp with time zone DEFAULT now(),
    businesses_id integer,
    lc_number character varying(50) NOT NULL,
    applicant character varying(100),
    beneficiary character varying(100),
    expiry_date date,
    amount double precision,
    currency character varying(10)
);


ALTER TABLE public.letter_of_credit OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 132764)
-- Name: letter_of_credit_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.letter_of_credit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.letter_of_credit_id_seq OWNER TO postgres;

--
-- TOC entry 2757 (class 0 OID 0)
-- Dependencies: 244
-- Name: letter_of_credit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.letter_of_credit_id_seq OWNED BY public.letter_of_credit.id;


--
-- TOC entry 245 (class 1259 OID 132766)
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.payments_id_seq
    START WITH 44
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.payments_id_seq OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 132768)
-- Name: payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payments (
    id integer DEFAULT nextval('public.payments_id_seq'::regclass) NOT NULL,
    business_id integer,
    payment_date timestamp with time zone DEFAULT now(),
    amount numeric NOT NULL,
    payment_method public.paymentmethodenum NOT NULL,
    reference_number character varying,
    notes character varying,
    sale_id integer,
    purchase_id integer
);


ALTER TABLE public.payments OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 132776)
-- Name: payroll_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.payroll_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.payroll_id_seq OWNER TO postgres;

--
-- TOC entry 248 (class 1259 OID 132778)
-- Name: payroll; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payroll (
    id integer DEFAULT nextval('public.payroll_id_seq'::regclass) NOT NULL,
    employee_id integer,
    salary numeric NOT NULL,
    tax numeric NOT NULL,
    net_pay numeric NOT NULL,
    payment_date timestamp without time zone DEFAULT now(),
    user_id integer
);


ALTER TABLE public.payroll OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 132786)
-- Name: person_person_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.person_person_id_seq
    START WITH 17
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.person_person_id_seq OWNER TO postgres;

--
-- TOC entry 250 (class 1259 OID 132788)
-- Name: person; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.person (
    person_id integer DEFAULT nextval('public.person_person_id_seq'::regclass) NOT NULL,
    title character varying(20),
    first_name character varying(50),
    last_name character varying(50),
    gender character varying(8),
    contact_no character varying(13)
);


ALTER TABLE public.person OWNER TO postgres;

--
-- TOC entry 251 (class 1259 OID 132792)
-- Name: person_personid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.person_personid_seq
    START WITH 17
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.person_personid_seq OWNER TO postgres;

--
-- TOC entry 252 (class 1259 OID 132794)
-- Name: product_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.product_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.product_categories_id_seq OWNER TO postgres;

--
-- TOC entry 253 (class 1259 OID 132796)
-- Name: product_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_categories (
    id integer DEFAULT nextval('public.product_categories_id_seq'::regclass) NOT NULL,
    business_id integer,
    name character varying NOT NULL,
    description character varying
);


ALTER TABLE public.product_categories OWNER TO postgres;

--
-- TOC entry 254 (class 1259 OID 132803)
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.products_id_seq
    START WITH 2
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.products_id_seq OWNER TO postgres;

--
-- TOC entry 255 (class 1259 OID 132805)
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    id integer DEFAULT nextval('public.products_id_seq'::regclass) NOT NULL,
    title character varying NOT NULL,
    price_per_unit numeric DEFAULT 0.0 NOT NULL,
    stock integer NOT NULL,
    category character varying,
    sub_category public.product_subcategory_enum,
    user_id integer,
    product_type public.product_type_enum DEFAULT 'tangible'::public.product_type_enum NOT NULL,
    unit_of_measurement public.unit_of_measurement_enum,
    quantity_per_unit numeric,
    is_stock_tracked boolean DEFAULT true,
    tax_rate numeric,
    description text,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    business_id integer NOT NULL
);


ALTER TABLE public.products OWNER TO postgres;

--
-- TOC entry 256 (class 1259 OID 132817)
-- Name: purchase_order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.purchase_order_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.purchase_order_items_id_seq OWNER TO postgres;

--
-- TOC entry 257 (class 1259 OID 132819)
-- Name: purchase_order_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.purchase_order_items (
    id integer DEFAULT nextval('public.purchase_order_items_id_seq'::regclass) NOT NULL,
    purchase_order_id integer,
    product_id integer,
    quantity integer NOT NULL,
    cost_per_unit double precision NOT NULL
);


ALTER TABLE public.purchase_order_items OWNER TO postgres;

--
-- TOC entry 258 (class 1259 OID 132823)
-- Name: purchase_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.purchase_orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.purchase_orders_id_seq OWNER TO postgres;

--
-- TOC entry 259 (class 1259 OID 132825)
-- Name: purchase_orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.purchase_orders (
    id integer DEFAULT nextval('public.purchase_orders_id_seq'::regclass) NOT NULL,
    date date NOT NULL,
    total_amount double precision NOT NULL,
    status public.order_status DEFAULT 'PENDING'::public.order_status,
    user_id integer,
    client_id integer
);


ALTER TABLE public.purchase_orders OWNER TO postgres;

--
-- TOC entry 260 (class 1259 OID 132830)
-- Name: sale_products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sale_products_id_seq
    START WITH 48
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sale_products_id_seq OWNER TO postgres;

--
-- TOC entry 261 (class 1259 OID 132832)
-- Name: sale_products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sale_products (
    id integer DEFAULT nextval('public.sale_products_id_seq'::regclass) NOT NULL,
    sale_id integer,
    product_id integer,
    quantity integer NOT NULL,
    price_per_unit numeric NOT NULL,
    total_price numeric NOT NULL
);


ALTER TABLE public.sale_products OWNER TO postgres;

--
-- TOC entry 262 (class 1259 OID 132839)
-- Name: sales_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sales_id_seq
    START WITH 32
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sales_id_seq OWNER TO postgres;

--
-- TOC entry 263 (class 1259 OID 132841)
-- Name: sales; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sales (
    id integer DEFAULT nextval('public.sales_id_seq'::regclass) NOT NULL,
    total numeric NOT NULL,
    discount integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT now(),
    user_id integer,
    business_id integer NOT NULL,
    client_id integer,
    payment_status public.payment_status
);


ALTER TABLE public.sales OWNER TO postgres;

--
-- TOC entry 264 (class 1259 OID 132850)
-- Name: subsidiary_account_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.subsidiary_account_id_seq
    START WITH 17
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.subsidiary_account_id_seq OWNER TO postgres;

--
-- TOC entry 265 (class 1259 OID 132852)
-- Name: subsidiary_account; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.subsidiary_account (
    subsidiary_account_id integer DEFAULT nextval('public.subsidiary_account_id_seq'::regclass) NOT NULL,
    account_id integer NOT NULL,
    client_id integer,
    account_name character varying(100),
    account_no character varying(20),
    address character varying(100),
    branch character varying(50),
    account_holder character varying(120),
    type character varying(50),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.subsidiary_account OWNER TO postgres;

--
-- TOC entry 266 (class 1259 OID 132858)
-- Name: transaction_transaction_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.transaction_transaction_id_seq
    START WITH 32
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.transaction_transaction_id_seq OWNER TO postgres;

--
-- TOC entry 267 (class 1259 OID 132860)
-- Name: transaction; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transaction (
    transaction_id integer DEFAULT nextval('public.transaction_transaction_id_seq'::regclass) NOT NULL,
    description text NOT NULL,
    transaction_date date,
    amount numeric NOT NULL,
    account_id integer,
    created_at timestamp without time zone DEFAULT now(),
    user_id integer,
    business_id integer NOT NULL,
    reference_type character varying,
    type public.transaction_type NOT NULL,
    reference_id integer
);


ALTER TABLE public.transaction OWNER TO postgres;

--
-- TOC entry 268 (class 1259 OID 132868)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO postgres;

--
-- TOC entry 269 (class 1259 OID 132870)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer DEFAULT nextval('public.users_id_seq'::regclass) NOT NULL,
    username character varying NOT NULL,
    email character varying NOT NULL,
    hashed_password character varying NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    role character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    is_superuser boolean DEFAULT false,
    CONSTRAINT users_role_check CHECK (((role)::text = ANY (ARRAY['admin'::text, 'super-admin'::text, 'sale-representative'::text, 'basic-user'::text])))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 270 (class 1259 OID 132883)
-- Name: vendors_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.vendors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vendors_id_seq OWNER TO postgres;

--
-- TOC entry 271 (class 1259 OID 132885)
-- Name: vendors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vendors (
    id integer DEFAULT nextval('public.vendors_id_seq'::regclass) NOT NULL,
    name character varying NOT NULL,
    contact_info character varying,
    user_id integer
);


ALTER TABLE public.vendors OWNER TO postgres;

--
-- TOC entry 277 (class 1259 OID 133405)
-- Name: view_client_details; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_client_details AS
 SELECT p.person_id,
    p.title,
    concat(p.first_name, ' ', p.last_name) AS per_name,
    p.contact_no,
    p.gender,
    c.client_id,
    c.client_type,
    c.registration_date,
    c.businesses_id
   FROM (public.client c
     JOIN public.person p ON ((p.person_id = c.person_id)));


ALTER TABLE public.view_client_details OWNER TO postgres;

--
-- TOC entry 272 (class 1259 OID 132896)
-- Name: view_journal_entry_details; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_journal_entry_details AS
 SELECT je.id AS journal_entry_id,
    je.ref_no,
    je.account_type,
    je.company,
    je.transaction_date,
    je.created_at AS journal_created_at,
    je.user_id,
    je.description AS journal_description,
    ji.id AS journal_item_id,
    ji.narration,
    ji.debitcredit,
    ji.amount,
    ji.created_at AS journal_item_created_at,
    ji.account_id,
    ji.subsidiary_account_id,
    acc.account_name AS main_account_name,
    acc.code AS main_account_code,
    sa.account_name AS subsidiary_account_name,
    sa.account_no AS subsidiary_account_no,
    sa.branch AS subsidiary_branch,
    sa.account_holder AS subsidiary_holder,
    sa.type AS subsidiary_type,
    c.client_id,
    c.client_type,
    c.registration_date
   FROM ((((public.journal_entries je
     JOIN public.journal_items ji ON ((je.id = ji.journal_entry_id)))
     JOIN public.account acc ON ((ji.account_id = acc.account_id)))
     LEFT JOIN public.subsidiary_account sa ON ((ji.subsidiary_account_id = sa.subsidiary_account_id)))
     LEFT JOIN public.client c ON ((sa.client_id = c.client_id)));


ALTER TABLE public.view_journal_entry_details OWNER TO postgres;

--
-- TOC entry 273 (class 1259 OID 132901)
-- Name: warehouse; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.warehouse (
    id integer NOT NULL,
    warehouse_name character varying(100),
    location character varying(100),
    branch_id integer
);


ALTER TABLE public.warehouse OWNER TO postgres;

--
-- TOC entry 274 (class 1259 OID 132904)
-- Name: warehouse_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.warehouse_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.warehouse_id_seq OWNER TO postgres;

--
-- TOC entry 2758 (class 0 OID 0)
-- Dependencies: 274
-- Name: warehouse_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.warehouse_id_seq OWNED BY public.warehouse.id;


--
-- TOC entry 2396 (class 2604 OID 132906)
-- Name: line_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_lines ALTER COLUMN line_id SET DEFAULT nextval('public.journal_lines_line_id_seq'::regclass);


--
-- TOC entry 2397 (class 2604 OID 132907)
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lc_charges ALTER COLUMN id SET DEFAULT nextval('public.lc_charges_id_seq'::regclass);


--
-- TOC entry 2398 (class 2604 OID 132908)
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lc_final_payment ALTER COLUMN id SET DEFAULT nextval('public.lc_final_payment_id_seq'::regclass);


--
-- TOC entry 2400 (class 2604 OID 132909)
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lc_goods ALTER COLUMN id SET DEFAULT nextval('public.lc_goods_id_seq'::regclass);


--
-- TOC entry 2402 (class 2604 OID 132911)
-- Name: shipment_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lc_goods_shipment ALTER COLUMN shipment_id SET DEFAULT nextval('public.lc_goods_shipment_shipment_id_seq'::regclass);


--
-- TOC entry 2404 (class 2604 OID 132912)
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lc_margin_payment ALTER COLUMN id SET DEFAULT nextval('public.lc_margin_payment_id_seq1'::regclass);


--
-- TOC entry 2405 (class 2604 OID 132913)
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lc_realization ALTER COLUMN id SET DEFAULT nextval('public.lc_realization_id_seq'::regclass);


--
-- TOC entry 2406 (class 2604 OID 132914)
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lc_shipment ALTER COLUMN id SET DEFAULT nextval('public.lc_shipment_id_seq'::regclass);


--
-- TOC entry 2411 (class 2604 OID 132915)
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.letter_of_credit ALTER COLUMN id SET DEFAULT nextval('public.letter_of_credit_id_seq'::regclass);


--
-- TOC entry 2444 (class 2604 OID 132916)
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouse ALTER COLUMN id SET DEFAULT nextval('public.warehouse_id_seq'::regclass);


--
-- TOC entry 2447 (class 2606 OID 132918)
-- Name: account_account_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_account_name_key UNIQUE (account_name);


--
-- TOC entry 2449 (class 2606 OID 132920)
-- Name: account_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_pkey PRIMARY KEY (account_id);


--
-- TOC entry 2455 (class 2606 OID 132922)
-- Name: accounts_payable_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts_payable
    ADD CONSTRAINT accounts_payable_pkey PRIMARY KEY (id);


--
-- TOC entry 2457 (class 2606 OID 132924)
-- Name: accounts_receivable_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts_receivable
    ADD CONSTRAINT accounts_receivable_pkey PRIMARY KEY (id);


--
-- TOC entry 2459 (class 2606 OID 132926)
-- Name: branch_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.branch
    ADD CONSTRAINT branch_pkey PRIMARY KEY (id);


--
-- TOC entry 2461 (class 2606 OID 132928)
-- Name: budget_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.budget
    ADD CONSTRAINT budget_pkey PRIMARY KEY (id);


--
-- TOC entry 2463 (class 2606 OID 132930)
-- Name: business_members_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.business_members
    ADD CONSTRAINT business_members_pkey PRIMARY KEY (user_id, business_id);


--
-- TOC entry 2465 (class 2606 OID 132932)
-- Name: businesses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.businesses
    ADD CONSTRAINT businesses_pkey PRIMARY KEY (id);


--
-- TOC entry 2467 (class 2606 OID 132934)
-- Name: client_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client
    ADD CONSTRAINT client_pkey PRIMARY KEY (client_id);


--
-- TOC entry 2469 (class 2606 OID 132936)
-- Name: customers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- TOC entry 2471 (class 2606 OID 132938)
-- Name: deliveries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deliveries
    ADD CONSTRAINT deliveries_pkey PRIMARY KEY (id);


--
-- TOC entry 2473 (class 2606 OID 132940)
-- Name: drivers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drivers
    ADD CONSTRAINT drivers_pkey PRIMARY KEY (id);


--
-- TOC entry 2475 (class 2606 OID 132942)
-- Name: employees_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (id);


--
-- TOC entry 2477 (class 2606 OID 132944)
-- Name: financial_periods_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_periods
    ADD CONSTRAINT financial_periods_pkey PRIMARY KEY (id);


--
-- TOC entry 2479 (class 2606 OID 132946)
-- Name: financial_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_reports
    ADD CONSTRAINT financial_reports_pkey PRIMARY KEY (id);


--
-- TOC entry 2481 (class 2606 OID 132948)
-- Name: fixed_assets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fixed_assets
    ADD CONSTRAINT fixed_assets_pkey PRIMARY KEY (id);


--
-- TOC entry 2483 (class 2606 OID 132950)
-- Name: inventory_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_log
    ADD CONSTRAINT inventory_log_pkey PRIMARY KEY (id);


--
-- TOC entry 2485 (class 2606 OID 132952)
-- Name: invoices_invoice_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key UNIQUE (invoice_number);


--
-- TOC entry 2487 (class 2606 OID 132954)
-- Name: invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- TOC entry 2451 (class 2606 OID 132956)
-- Name: journal_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_entries
    ADD CONSTRAINT journal_entries_pkey PRIMARY KEY (id);


--
-- TOC entry 2453 (class 2606 OID 132958)
-- Name: journal_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_items
    ADD CONSTRAINT journal_items_pkey PRIMARY KEY (id);


--
-- TOC entry 2489 (class 2606 OID 132960)
-- Name: journal_lines_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_lines
    ADD CONSTRAINT journal_lines_pkey PRIMARY KEY (line_id);


--
-- TOC entry 2491 (class 2606 OID 132962)
-- Name: lc_charges_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lc_charges
    ADD CONSTRAINT lc_charges_pkey PRIMARY KEY (id);


--
-- TOC entry 2493 (class 2606 OID 132964)
-- Name: lc_final_payment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lc_final_payment
    ADD CONSTRAINT lc_final_payment_pkey PRIMARY KEY (id);


--
-- TOC entry 2495 (class 2606 OID 132966)
-- Name: lc_goods_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lc_goods
    ADD CONSTRAINT lc_goods_pkey PRIMARY KEY (id);


--
-- TOC entry 2541 (class 2606 OID 133391)
-- Name: lc_goods_receipt_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lc_goods_receipt
    ADD CONSTRAINT lc_goods_receipt_pkey PRIMARY KEY (id);


--
-- TOC entry 2497 (class 2606 OID 132970)
-- Name: lc_goods_shipment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lc_goods_shipment
    ADD CONSTRAINT lc_goods_shipment_pkey PRIMARY KEY (shipment_id);


--
-- TOC entry 2499 (class 2606 OID 132972)
-- Name: lc_issuance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lc_issuance
    ADD CONSTRAINT lc_issuance_pkey PRIMARY KEY (id);


--
-- TOC entry 2501 (class 2606 OID 132974)
-- Name: lc_margin_payment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lc_margin_payment
    ADD CONSTRAINT lc_margin_payment_pkey PRIMARY KEY (id);


--
-- TOC entry 2503 (class 2606 OID 132976)
-- Name: lc_realization_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lc_realization
    ADD CONSTRAINT lc_realization_pkey PRIMARY KEY (id);


--
-- TOC entry 2505 (class 2606 OID 132978)
-- Name: lc_shipment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lc_shipment
    ADD CONSTRAINT lc_shipment_pkey PRIMARY KEY (id);


--
-- TOC entry 2507 (class 2606 OID 132980)
-- Name: ledger_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ledger
    ADD CONSTRAINT ledger_pkey PRIMARY KEY (id);


--
-- TOC entry 2509 (class 2606 OID 132982)
-- Name: letter_of_credit_lc_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.letter_of_credit
    ADD CONSTRAINT letter_of_credit_lc_number_key UNIQUE (lc_number);


--
-- TOC entry 2511 (class 2606 OID 132984)
-- Name: letter_of_credit_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.letter_of_credit
    ADD CONSTRAINT letter_of_credit_pkey PRIMARY KEY (id);


--
-- TOC entry 2513 (class 2606 OID 132986)
-- Name: payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- TOC entry 2515 (class 2606 OID 132988)
-- Name: payroll_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payroll
    ADD CONSTRAINT payroll_pkey PRIMARY KEY (id);


--
-- TOC entry 2517 (class 2606 OID 132990)
-- Name: person_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_pkey PRIMARY KEY (person_id);


--
-- TOC entry 2519 (class 2606 OID 132992)
-- Name: product_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_categories
    ADD CONSTRAINT product_categories_pkey PRIMARY KEY (id);


--
-- TOC entry 2521 (class 2606 OID 132994)
-- Name: products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- TOC entry 2523 (class 2606 OID 132996)
-- Name: purchase_order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_order_items
    ADD CONSTRAINT purchase_order_items_pkey PRIMARY KEY (id);


--
-- TOC entry 2525 (class 2606 OID 132998)
-- Name: purchase_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_pkey PRIMARY KEY (id);


--
-- TOC entry 2527 (class 2606 OID 133000)
-- Name: sale_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sale_products
    ADD CONSTRAINT sale_products_pkey PRIMARY KEY (id);


--
-- TOC entry 2529 (class 2606 OID 133002)
-- Name: sales_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_pkey PRIMARY KEY (id);


--
-- TOC entry 2531 (class 2606 OID 133004)
-- Name: subsidiary_account_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subsidiary_account
    ADD CONSTRAINT subsidiary_account_pkey PRIMARY KEY (subsidiary_account_id);


--
-- TOC entry 2533 (class 2606 OID 133006)
-- Name: transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_pkey PRIMARY KEY (transaction_id);


--
-- TOC entry 2535 (class 2606 OID 133008)
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 2537 (class 2606 OID 133010)
-- Name: vendors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vendors
    ADD CONSTRAINT vendors_pkey PRIMARY KEY (id);


--
-- TOC entry 2539 (class 2606 OID 133012)
-- Name: warehouse_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouse
    ADD CONSTRAINT warehouse_pkey PRIMARY KEY (id);


--
-- TOC entry 2618 (class 2620 OID 133013)
-- Name: trg_approve_lc_status; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_approve_lc_status AFTER INSERT ON public.lc_issuance FOR EACH ROW EXECUTE PROCEDURE public.approve_lc_status();


--
-- TOC entry 2614 (class 2620 OID 133014)
-- Name: trg_check_journal_balance; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_check_journal_balance BEFORE INSERT ON public.journal_lines FOR EACH ROW EXECUTE PROCEDURE public.check_journal_balance();


--
-- TOC entry 2613 (class 2620 OID 133015)
-- Name: trg_check_journal_entry_balance; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_check_journal_entry_balance AFTER INSERT OR UPDATE ON public.journal_entries FOR EACH ROW EXECUTE PROCEDURE public.check_journal_entry_balance();


--
-- TOC entry 2615 (class 2620 OID 133016)
-- Name: trg_final_payment_lc_status; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_final_payment_lc_status AFTER INSERT ON public.lc_final_payment FOR EACH ROW EXECUTE PROCEDURE public.final_payment_lc_status();


--
-- TOC entry 2621 (class 2620 OID 133402)
-- Name: trg_goods_received_lc_status; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_goods_received_lc_status AFTER INSERT ON public.lc_goods_receipt FOR EACH ROW EXECUTE PROCEDURE public.goods_received_lc_status();


--
-- TOC entry 2617 (class 2620 OID 133018)
-- Name: trg_issuance_lc_status; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_issuance_lc_status AFTER INSERT ON public.lc_goods_shipment FOR EACH ROW EXECUTE PROCEDURE public.issuance_lc_status();


--
-- TOC entry 2616 (class 2620 OID 133019)
-- Name: trg_journal_entry_final; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_journal_entry_final AFTER INSERT ON public.lc_final_payment FOR EACH ROW EXECUTE PROCEDURE public.create_lc_journal_entry();


--
-- TOC entry 2619 (class 2620 OID 133020)
-- Name: trg_journal_entry_margin; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_journal_entry_margin AFTER INSERT ON public.lc_margin_payment FOR EACH ROW EXECUTE PROCEDURE public.create_lc_journal_entry();


--
-- TOC entry 2620 (class 2620 OID 133021)
-- Name: trg_submitted_lc_status; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_submitted_lc_status AFTER INSERT ON public.lc_margin_payment FOR EACH ROW EXECUTE PROCEDURE public.submitted_lc_status();


--
-- TOC entry 2542 (class 2606 OID 133022)
-- Name: account_business_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_business_id_fkey FOREIGN KEY (business_id) REFERENCES public.businesses(id);


--
-- TOC entry 2543 (class 2606 OID 133027)
-- Name: account_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.account(account_id);


--
-- TOC entry 2548 (class 2606 OID 133032)
-- Name: accounts_payable_purchase_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts_payable
    ADD CONSTRAINT accounts_payable_purchase_order_id_fkey FOREIGN KEY (purchase_order_id) REFERENCES public.purchase_orders(id);


--
-- TOC entry 2549 (class 2606 OID 133037)
-- Name: accounts_payable_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts_payable
    ADD CONSTRAINT accounts_payable_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2550 (class 2606 OID 133042)
-- Name: accounts_receivable_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts_receivable
    ADD CONSTRAINT accounts_receivable_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- TOC entry 2551 (class 2606 OID 133047)
-- Name: accounts_receivable_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts_receivable
    ADD CONSTRAINT accounts_receivable_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2552 (class 2606 OID 133052)
-- Name: branch_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.branch
    ADD CONSTRAINT branch_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.users(id);


--
-- TOC entry 2553 (class 2606 OID 133057)
-- Name: brnach_business_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.branch
    ADD CONSTRAINT brnach_business_id_fkey FOREIGN KEY (business_id) REFERENCES public.businesses(id);


--
-- TOC entry 2554 (class 2606 OID 133062)
-- Name: budget_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.budget
    ADD CONSTRAINT budget_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.journal_entries(id);


--
-- TOC entry 2555 (class 2606 OID 133067)
-- Name: budget_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.budget
    ADD CONSTRAINT budget_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2556 (class 2606 OID 133072)
-- Name: business_members_business_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.business_members
    ADD CONSTRAINT business_members_business_id_fkey FOREIGN KEY (business_id) REFERENCES public.businesses(id);


--
-- TOC entry 2557 (class 2606 OID 133077)
-- Name: business_members_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.business_members
    ADD CONSTRAINT business_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2558 (class 2606 OID 133082)
-- Name: client_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client
    ADD CONSTRAINT client_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(person_id) ON DELETE SET NULL;


--
-- TOC entry 2560 (class 2606 OID 133087)
-- Name: customers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2561 (class 2606 OID 133092)
-- Name: deliveries_driver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deliveries
    ADD CONSTRAINT deliveries_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(id);


--
-- TOC entry 2562 (class 2606 OID 133097)
-- Name: deliveries_sale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deliveries
    ADD CONSTRAINT deliveries_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES public.sales(id);


--
-- TOC entry 2563 (class 2606 OID 133102)
-- Name: drivers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drivers
    ADD CONSTRAINT drivers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2564 (class 2606 OID 133107)
-- Name: employees_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2565 (class 2606 OID 133112)
-- Name: financial_reports_period_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_reports
    ADD CONSTRAINT financial_reports_period_id_fkey FOREIGN KEY (period_id) REFERENCES public.financial_periods(id);


--
-- TOC entry 2566 (class 2606 OID 133117)
-- Name: financial_reports_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_reports
    ADD CONSTRAINT financial_reports_user_id_fkey FOREIGN KEY (generated_by) REFERENCES public.users(id);


--
-- TOC entry 2567 (class 2606 OID 133122)
-- Name: fixed_assets_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fixed_assets
    ADD CONSTRAINT fixed_assets_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2559 (class 2606 OID 133127)
-- Name: fk_client_business; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client
    ADD CONSTRAINT fk_client_business FOREIGN KEY (businesses_id) REFERENCES public.businesses(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2588 (class 2606 OID 133132)
-- Name: fk_letter_of_credit_business; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.letter_of_credit
    ADD CONSTRAINT fk_letter_of_credit_business FOREIGN KEY (businesses_id) REFERENCES public.businesses(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2605 (class 2606 OID 133137)
-- Name: fk_subsidiary_account_account; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subsidiary_account
    ADD CONSTRAINT fk_subsidiary_account_account FOREIGN KEY (account_id) REFERENCES public.account(account_id);


--
-- TOC entry 2568 (class 2606 OID 133142)
-- Name: inventory_log_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_log
    ADD CONSTRAINT inventory_log_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- TOC entry 2569 (class 2606 OID 133147)
-- Name: inventory_log_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_log
    ADD CONSTRAINT inventory_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2570 (class 2606 OID 133152)
-- Name: invoices_business_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_business_id_fkey FOREIGN KEY (business_id) REFERENCES public.businesses(id);


--
-- TOC entry 2571 (class 2606 OID 133157)
-- Name: invoices_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- TOC entry 2572 (class 2606 OID 133162)
-- Name: invoices_sale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES public.sales(id);


--
-- TOC entry 2544 (class 2606 OID 133167)
-- Name: journal_entries_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_entries
    ADD CONSTRAINT journal_entries_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2545 (class 2606 OID 133172)
-- Name: journal_items_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_items
    ADD CONSTRAINT journal_items_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.account(account_id);


--
-- TOC entry 2546 (class 2606 OID 133177)
-- Name: journal_items_journal_entry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_items
    ADD CONSTRAINT journal_items_journal_entry_id_fkey FOREIGN KEY (journal_entry_id) REFERENCES public.journal_entries(id);


--
-- TOC entry 2547 (class 2606 OID 133182)
-- Name: journal_items_subsidiary_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_items
    ADD CONSTRAINT journal_items_subsidiary_account_id_fkey FOREIGN KEY (subsidiary_account_id) REFERENCES public.subsidiary_account(subsidiary_account_id);


--
-- TOC entry 2573 (class 2606 OID 133187)
-- Name: journal_lines_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_lines
    ADD CONSTRAINT journal_lines_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.account(account_id);


--
-- TOC entry 2574 (class 2606 OID 133192)
-- Name: journal_lines_journal_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_lines
    ADD CONSTRAINT journal_lines_journal_id_fkey FOREIGN KEY (journal_id) REFERENCES public.journal_entries(id) ON DELETE CASCADE;


--
-- TOC entry 2575 (class 2606 OID 133197)
-- Name: lc_charges_lc_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lc_charges
    ADD CONSTRAINT lc_charges_lc_id_fkey FOREIGN KEY (lc_id) REFERENCES public.letter_of_credit(id);


--
-- TOC entry 2576 (class 2606 OID 133202)
-- Name: lc_final_payment_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lc_final_payment
    ADD CONSTRAINT lc_final_payment_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.subsidiary_account(subsidiary_account_id);


--
-- TOC entry 2577 (class 2606 OID 133207)
-- Name: lc_final_payment_lc_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lc_final_payment
    ADD CONSTRAINT lc_final_payment_lc_id_fkey FOREIGN KEY (lc_id) REFERENCES public.letter_of_credit(id) ON DELETE CASCADE;


--
-- TOC entry 2578 (class 2606 OID 133212)
-- Name: lc_goods_lc_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lc_goods
    ADD CONSTRAINT lc_goods_lc_id_fkey FOREIGN KEY (lc_id) REFERENCES public.letter_of_credit(id);


--
-- TOC entry 2579 (class 2606 OID 133217)
-- Name: lc_goods_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lc_goods
    ADD CONSTRAINT lc_goods_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- TOC entry 2611 (class 2606 OID 133392)
-- Name: lc_goods_receipt_lc_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lc_goods_receipt
    ADD CONSTRAINT lc_goods_receipt_lc_id_fkey FOREIGN KEY (lc_id) REFERENCES public.letter_of_credit(id) ON DELETE CASCADE;


--
-- TOC entry 2612 (class 2606 OID 133397)
-- Name: lc_goods_receipt_warehouse_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lc_goods_receipt
    ADD CONSTRAINT lc_goods_receipt_warehouse_id_fkey FOREIGN KEY (warehouse_id) REFERENCES public.warehouse(id);


--
-- TOC entry 2580 (class 2606 OID 133232)
-- Name: lc_goods_shipment_lc_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lc_goods_shipment
    ADD CONSTRAINT lc_goods_shipment_lc_id_fkey FOREIGN KEY (lc_id) REFERENCES public.letter_of_credit(id);


--
-- TOC entry 2581 (class 2606 OID 133237)
-- Name: lc_issuance_lc_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lc_issuance
    ADD CONSTRAINT lc_issuance_lc_id_fkey FOREIGN KEY (lc_id) REFERENCES public.letter_of_credit(id) ON DELETE CASCADE;


--
-- TOC entry 2582 (class 2606 OID 133242)
-- Name: lc_margin_payment_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lc_margin_payment
    ADD CONSTRAINT lc_margin_payment_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.subsidiary_account(subsidiary_account_id);


--
-- TOC entry 2583 (class 2606 OID 133247)
-- Name: lc_margin_payment_lc_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lc_margin_payment
    ADD CONSTRAINT lc_margin_payment_lc_id_fkey FOREIGN KEY (lc_id) REFERENCES public.letter_of_credit(id) ON DELETE CASCADE;


--
-- TOC entry 2584 (class 2606 OID 133252)
-- Name: lc_realization_lc_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lc_realization
    ADD CONSTRAINT lc_realization_lc_id_fkey FOREIGN KEY (lc_id) REFERENCES public.letter_of_credit(id) ON DELETE CASCADE;


--
-- TOC entry 2585 (class 2606 OID 133257)
-- Name: lc_shipment_lc_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lc_shipment
    ADD CONSTRAINT lc_shipment_lc_id_fkey FOREIGN KEY (lc_id) REFERENCES public.letter_of_credit(id) ON DELETE CASCADE;


--
-- TOC entry 2586 (class 2606 OID 133262)
-- Name: ledger_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ledger
    ADD CONSTRAINT ledger_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.account(account_id);


--
-- TOC entry 2587 (class 2606 OID 133267)
-- Name: ledger_journal_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ledger
    ADD CONSTRAINT ledger_journal_item_id_fkey FOREIGN KEY (journal_item_id) REFERENCES public.journal_items(id);


--
-- TOC entry 2589 (class 2606 OID 133272)
-- Name: payments_business_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_business_id_fkey FOREIGN KEY (business_id) REFERENCES public.businesses(id);


--
-- TOC entry 2590 (class 2606 OID 133277)
-- Name: payments_purchase_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_purchase_id_fkey FOREIGN KEY (purchase_id) REFERENCES public.purchase_orders(id);


--
-- TOC entry 2591 (class 2606 OID 133282)
-- Name: payments_sale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES public.sales(id);


--
-- TOC entry 2592 (class 2606 OID 133287)
-- Name: payroll_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payroll
    ADD CONSTRAINT payroll_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id);


--
-- TOC entry 2593 (class 2606 OID 133292)
-- Name: payroll_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payroll
    ADD CONSTRAINT payroll_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2594 (class 2606 OID 133297)
-- Name: product_categories_business_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_categories
    ADD CONSTRAINT product_categories_business_id_fkey FOREIGN KEY (business_id) REFERENCES public.businesses(id);


--
-- TOC entry 2595 (class 2606 OID 133302)
-- Name: products_business_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_business_id_fkey FOREIGN KEY (business_id) REFERENCES public.businesses(id);


--
-- TOC entry 2596 (class 2606 OID 133307)
-- Name: products_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2597 (class 2606 OID 133312)
-- Name: purchase_order_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_order_items
    ADD CONSTRAINT purchase_order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- TOC entry 2598 (class 2606 OID 133317)
-- Name: purchase_order_items_purchase_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_order_items
    ADD CONSTRAINT purchase_order_items_purchase_order_id_fkey FOREIGN KEY (purchase_order_id) REFERENCES public.purchase_orders(id);


--
-- TOC entry 2599 (class 2606 OID 133322)
-- Name: purchase_orders_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.client(client_id);


--
-- TOC entry 2600 (class 2606 OID 133327)
-- Name: purchase_orders_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2601 (class 2606 OID 133332)
-- Name: sale_products_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sale_products
    ADD CONSTRAINT sale_products_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- TOC entry 2602 (class 2606 OID 133337)
-- Name: sale_products_sale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sale_products
    ADD CONSTRAINT sale_products_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES public.sales(id);


--
-- TOC entry 2603 (class 2606 OID 133342)
-- Name: sales_business_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_business_id_fkey FOREIGN KEY (business_id) REFERENCES public.businesses(id);


--
-- TOC entry 2604 (class 2606 OID 133347)
-- Name: sales_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2606 (class 2606 OID 133352)
-- Name: transaction_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.account(account_id);


--
-- TOC entry 2607 (class 2606 OID 133357)
-- Name: transaction_business_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_business_id_fkey FOREIGN KEY (business_id) REFERENCES public.businesses(id);


--
-- TOC entry 2608 (class 2606 OID 133362)
-- Name: transaction_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2609 (class 2606 OID 133367)
-- Name: vendors_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vendors
    ADD CONSTRAINT vendors_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2610 (class 2606 OID 133372)
-- Name: warehouse_branch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouse
    ADD CONSTRAINT warehouse_branch_id_fkey FOREIGN KEY (branch_id) REFERENCES public.branch(id);


--
-- TOC entry 2747 (class 0 OID 0)
-- Dependencies: 7
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2025-07-30 10:51:58

--
-- PostgreSQL database dump complete
--

