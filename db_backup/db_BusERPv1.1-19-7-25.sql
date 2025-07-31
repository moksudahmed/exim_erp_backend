--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.22
-- Dumped by pg_dump version 9.5.22

-- Started on 2025-07-19 23:44:31

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
-- TOC entry 2570 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- TOC entry 617 (class 1247 OID 74001)
-- Name: accountaction; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.accountaction AS ENUM (
    'DEBIT',
    'CREDIT'
);


ALTER TYPE public.accountaction OWNER TO postgres;

--
-- TOC entry 620 (class 1247 OID 74006)
-- Name: accountnature; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.accountnature AS ENUM (
    'DEBIT',
    'CREDIT'
);


ALTER TYPE public.accountnature OWNER TO postgres;

--
-- TOC entry 623 (class 1247 OID 74012)
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
-- TOC entry 626 (class 1247 OID 74024)
-- Name: actiontype; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.actiontype AS ENUM (
    'ADD',
    'DAMAGED',
    'DEDUCT'
);


ALTER TYPE public.actiontype OWNER TO postgres;

--
-- TOC entry 629 (class 1247 OID 74032)
-- Name: client_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.client_type AS ENUM (
    'CUSTOMER',
    'SUPPLIER',
    'EMPLOYEE'
);


ALTER TYPE public.client_type OWNER TO postgres;

--
-- TOC entry 632 (class 1247 OID 74040)
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
-- TOC entry 635 (class 1247 OID 74052)
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
-- TOC entry 813 (class 1247 OID 74824)
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
-- TOC entry 638 (class 1247 OID 74070)
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
-- TOC entry 810 (class 1247 OID 74811)
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
-- TOC entry 641 (class 1247 OID 74090)
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
-- TOC entry 644 (class 1247 OID 74102)
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
-- TOC entry 647 (class 1247 OID 74112)
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
-- TOC entry 250 (class 1255 OID 74145)
-- Name: get_client_journal_summary(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_client_journal_summary(p_client_id integer) RETURNS TABLE(client_id integer, client_type character varying, subsidiary_account_id integer, account_id integer, account_name character varying, account_type character varying, balance numeric, narration text, ref_no character varying, journal_account_type character varying, debitcredit character varying, amount numeric)
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN QUERY
  SELECT 
    c.client_id, 
    c.client_type, 
    s.subsidiary_account_id, 
    s.account_id, 
    a.account_name, 
    a.account_type, 
    a.balance, 
    i.narration, 
    j.ref_no, 
    j.account_type, 
    i.debitcredit, 
    i.amount
  FROM 
    public.account a
    JOIN public.subsidiary_account s ON s.account_id = a.account_id
    JOIN public.client c ON s.subsidiary_account_id = c.subsidiary_account_id
    JOIN public.journal_items i ON i.account_id = a.account_id
    JOIN public.journal_entries j ON i.journal_entry_id = j.id
  WHERE 
    c.client_id = p_client_id;
END;
$$;


ALTER FUNCTION public.get_client_journal_summary(p_client_id integer) OWNER TO postgres;

--
-- TOC entry 181 (class 1259 OID 74146)
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
-- TOC entry 182 (class 1259 OID 74148)
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
    is_active boolean DEFAULT true,
    nature_type public.accountnature NOT NULL,
    CONSTRAINT account_nature_type_check CHECK (((nature_type)::text = ANY (ARRAY[('DEBIT'::character varying)::text, ('CREDIT'::character varying)::text])))
);


ALTER TABLE public.account OWNER TO postgres;

--
-- TOC entry 183 (class 1259 OID 74158)
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
-- TOC entry 184 (class 1259 OID 74160)
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
-- TOC entry 185 (class 1259 OID 74166)
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
-- TOC entry 186 (class 1259 OID 74168)
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
-- TOC entry 187 (class 1259 OID 74176)
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
-- TOC entry 188 (class 1259 OID 74178)
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
-- TOC entry 189 (class 1259 OID 74185)
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
-- TOC entry 190 (class 1259 OID 74187)
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
-- TOC entry 191 (class 1259 OID 74195)
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
-- TOC entry 192 (class 1259 OID 74202)
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
-- TOC entry 193 (class 1259 OID 74204)
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
-- TOC entry 194 (class 1259 OID 74213)
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
-- TOC entry 195 (class 1259 OID 74215)
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
-- TOC entry 196 (class 1259 OID 74219)
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
-- TOC entry 197 (class 1259 OID 74221)
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
-- TOC entry 198 (class 1259 OID 74228)
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
-- TOC entry 199 (class 1259 OID 74230)
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
-- TOC entry 200 (class 1259 OID 74242)
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
-- TOC entry 201 (class 1259 OID 74244)
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
-- TOC entry 202 (class 1259 OID 74253)
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
-- TOC entry 203 (class 1259 OID 74255)
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
-- TOC entry 204 (class 1259 OID 74262)
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
-- TOC entry 205 (class 1259 OID 74264)
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
-- TOC entry 206 (class 1259 OID 74272)
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
-- TOC entry 207 (class 1259 OID 74274)
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
-- TOC entry 208 (class 1259 OID 74283)
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
-- TOC entry 209 (class 1259 OID 74285)
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
-- TOC entry 210 (class 1259 OID 74292)
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
-- TOC entry 211 (class 1259 OID 74294)
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
-- TOC entry 212 (class 1259 OID 74296)
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
-- TOC entry 213 (class 1259 OID 74301)
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
-- TOC entry 214 (class 1259 OID 74303)
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
-- TOC entry 215 (class 1259 OID 74311)
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
-- TOC entry 216 (class 1259 OID 74313)
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
-- TOC entry 217 (class 1259 OID 74321)
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
-- TOC entry 218 (class 1259 OID 74323)
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
-- TOC entry 219 (class 1259 OID 74325)
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
-- TOC entry 220 (class 1259 OID 74333)
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
-- TOC entry 221 (class 1259 OID 74335)
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
-- TOC entry 222 (class 1259 OID 74343)
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
-- TOC entry 223 (class 1259 OID 74345)
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
-- TOC entry 224 (class 1259 OID 74353)
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
-- TOC entry 225 (class 1259 OID 74355)
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
-- TOC entry 226 (class 1259 OID 74363)
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
-- TOC entry 227 (class 1259 OID 74365)
-- Name: person; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.person (
    person_id integer DEFAULT nextval('public.person_person_id_seq'::regclass) NOT NULL,
    title character varying(20),
    first_name character varying(50),
    last_name character varying(50),
    date_of_birth date,
    gender character varying(8)
);


ALTER TABLE public.person OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 74369)
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
-- TOC entry 229 (class 1259 OID 74371)
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
-- TOC entry 230 (class 1259 OID 74373)
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
-- TOC entry 231 (class 1259 OID 74380)
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
-- TOC entry 232 (class 1259 OID 74382)
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    id integer DEFAULT nextval('public.products_id_seq'::regclass) NOT NULL,
    title character varying NOT NULL,
    price_per_unit numeric DEFAULT 0.0 NOT NULL,
    stock integer NOT NULL,
    category character varying,
    sub_category character varying,
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
-- TOC entry 233 (class 1259 OID 74394)
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
-- TOC entry 234 (class 1259 OID 74396)
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
-- TOC entry 235 (class 1259 OID 74400)
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
-- TOC entry 236 (class 1259 OID 74402)
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
-- TOC entry 237 (class 1259 OID 74407)
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
-- TOC entry 238 (class 1259 OID 74409)
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
-- TOC entry 239 (class 1259 OID 74416)
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
-- TOC entry 240 (class 1259 OID 74418)
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
-- TOC entry 241 (class 1259 OID 74427)
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
-- TOC entry 242 (class 1259 OID 74429)
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
-- TOC entry 243 (class 1259 OID 74435)
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
-- TOC entry 244 (class 1259 OID 74437)
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
-- TOC entry 245 (class 1259 OID 74445)
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
-- TOC entry 246 (class 1259 OID 74447)
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
-- TOC entry 247 (class 1259 OID 74460)
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
-- TOC entry 248 (class 1259 OID 74462)
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
-- TOC entry 249 (class 1259 OID 74842)
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
-- TOC entry 2324 (class 2606 OID 74470)
-- Name: account_account_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_account_name_key UNIQUE (account_name);


--
-- TOC entry 2326 (class 2606 OID 74472)
-- Name: account_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_pkey PRIMARY KEY (account_id);


--
-- TOC entry 2328 (class 2606 OID 74474)
-- Name: accounts_payable_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts_payable
    ADD CONSTRAINT accounts_payable_pkey PRIMARY KEY (id);


--
-- TOC entry 2330 (class 2606 OID 74476)
-- Name: accounts_receivable_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts_receivable
    ADD CONSTRAINT accounts_receivable_pkey PRIMARY KEY (id);


--
-- TOC entry 2332 (class 2606 OID 74478)
-- Name: branch_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.branch
    ADD CONSTRAINT branch_pkey PRIMARY KEY (id);


--
-- TOC entry 2334 (class 2606 OID 74480)
-- Name: budget_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.budget
    ADD CONSTRAINT budget_pkey PRIMARY KEY (id);


--
-- TOC entry 2336 (class 2606 OID 74482)
-- Name: business_members_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.business_members
    ADD CONSTRAINT business_members_pkey PRIMARY KEY (user_id, business_id);


--
-- TOC entry 2338 (class 2606 OID 74484)
-- Name: businesses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.businesses
    ADD CONSTRAINT businesses_pkey PRIMARY KEY (id);


--
-- TOC entry 2340 (class 2606 OID 74486)
-- Name: client_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client
    ADD CONSTRAINT client_pkey PRIMARY KEY (client_id);


--
-- TOC entry 2342 (class 2606 OID 74488)
-- Name: customers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- TOC entry 2344 (class 2606 OID 74490)
-- Name: deliveries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deliveries
    ADD CONSTRAINT deliveries_pkey PRIMARY KEY (id);


--
-- TOC entry 2346 (class 2606 OID 74492)
-- Name: drivers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drivers
    ADD CONSTRAINT drivers_pkey PRIMARY KEY (id);


--
-- TOC entry 2348 (class 2606 OID 74494)
-- Name: employees_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (id);


--
-- TOC entry 2350 (class 2606 OID 74496)
-- Name: financial_periods_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_periods
    ADD CONSTRAINT financial_periods_pkey PRIMARY KEY (id);


--
-- TOC entry 2352 (class 2606 OID 74498)
-- Name: financial_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_reports
    ADD CONSTRAINT financial_reports_pkey PRIMARY KEY (id);


--
-- TOC entry 2354 (class 2606 OID 74500)
-- Name: fixed_assets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fixed_assets
    ADD CONSTRAINT fixed_assets_pkey PRIMARY KEY (id);


--
-- TOC entry 2356 (class 2606 OID 74502)
-- Name: inventory_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_log
    ADD CONSTRAINT inventory_log_pkey PRIMARY KEY (id);


--
-- TOC entry 2358 (class 2606 OID 74504)
-- Name: invoices_invoice_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key UNIQUE (invoice_number);


--
-- TOC entry 2360 (class 2606 OID 74506)
-- Name: invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- TOC entry 2362 (class 2606 OID 74508)
-- Name: journal_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_entries
    ADD CONSTRAINT journal_entries_pkey PRIMARY KEY (id);


--
-- TOC entry 2364 (class 2606 OID 74510)
-- Name: journal_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_items
    ADD CONSTRAINT journal_items_pkey PRIMARY KEY (id);


--
-- TOC entry 2366 (class 2606 OID 74512)
-- Name: ledger_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ledger
    ADD CONSTRAINT ledger_pkey PRIMARY KEY (id);


--
-- TOC entry 2368 (class 2606 OID 74514)
-- Name: payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- TOC entry 2370 (class 2606 OID 74516)
-- Name: payroll_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payroll
    ADD CONSTRAINT payroll_pkey PRIMARY KEY (id);


--
-- TOC entry 2372 (class 2606 OID 74518)
-- Name: person_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_pkey PRIMARY KEY (person_id);


--
-- TOC entry 2374 (class 2606 OID 74520)
-- Name: product_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_categories
    ADD CONSTRAINT product_categories_pkey PRIMARY KEY (id);


--
-- TOC entry 2376 (class 2606 OID 74522)
-- Name: products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- TOC entry 2378 (class 2606 OID 74524)
-- Name: purchase_order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_order_items
    ADD CONSTRAINT purchase_order_items_pkey PRIMARY KEY (id);


--
-- TOC entry 2380 (class 2606 OID 74526)
-- Name: purchase_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_pkey PRIMARY KEY (id);


--
-- TOC entry 2382 (class 2606 OID 74528)
-- Name: sale_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sale_products
    ADD CONSTRAINT sale_products_pkey PRIMARY KEY (id);


--
-- TOC entry 2384 (class 2606 OID 74530)
-- Name: sales_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_pkey PRIMARY KEY (id);


--
-- TOC entry 2386 (class 2606 OID 74532)
-- Name: subsidiary_account_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subsidiary_account
    ADD CONSTRAINT subsidiary_account_pkey PRIMARY KEY (subsidiary_account_id);


--
-- TOC entry 2388 (class 2606 OID 74534)
-- Name: transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_pkey PRIMARY KEY (transaction_id);


--
-- TOC entry 2390 (class 2606 OID 74536)
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 2392 (class 2606 OID 74538)
-- Name: vendors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vendors
    ADD CONSTRAINT vendors_pkey PRIMARY KEY (id);


--
-- TOC entry 2393 (class 2606 OID 74539)
-- Name: account_business_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_business_id_fkey FOREIGN KEY (business_id) REFERENCES public.businesses(id);


--
-- TOC entry 2394 (class 2606 OID 74544)
-- Name: account_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.account(account_id);


--
-- TOC entry 2395 (class 2606 OID 74549)
-- Name: accounts_payable_purchase_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts_payable
    ADD CONSTRAINT accounts_payable_purchase_order_id_fkey FOREIGN KEY (purchase_order_id) REFERENCES public.purchase_orders(id);


--
-- TOC entry 2396 (class 2606 OID 74554)
-- Name: accounts_payable_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts_payable
    ADD CONSTRAINT accounts_payable_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2397 (class 2606 OID 74559)
-- Name: accounts_receivable_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts_receivable
    ADD CONSTRAINT accounts_receivable_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- TOC entry 2398 (class 2606 OID 74564)
-- Name: accounts_receivable_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts_receivable
    ADD CONSTRAINT accounts_receivable_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2399 (class 2606 OID 74569)
-- Name: branch_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.branch
    ADD CONSTRAINT branch_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.users(id);


--
-- TOC entry 2400 (class 2606 OID 74574)
-- Name: brnach_business_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.branch
    ADD CONSTRAINT brnach_business_id_fkey FOREIGN KEY (business_id) REFERENCES public.businesses(id);


--
-- TOC entry 2401 (class 2606 OID 74579)
-- Name: budget_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.budget
    ADD CONSTRAINT budget_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.journal_entries(id);


--
-- TOC entry 2402 (class 2606 OID 74584)
-- Name: budget_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.budget
    ADD CONSTRAINT budget_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2403 (class 2606 OID 74589)
-- Name: business_members_business_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.business_members
    ADD CONSTRAINT business_members_business_id_fkey FOREIGN KEY (business_id) REFERENCES public.businesses(id);


--
-- TOC entry 2404 (class 2606 OID 74594)
-- Name: business_members_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.business_members
    ADD CONSTRAINT business_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2405 (class 2606 OID 74599)
-- Name: client_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client
    ADD CONSTRAINT client_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.person(person_id) ON DELETE SET NULL;


--
-- TOC entry 2407 (class 2606 OID 74604)
-- Name: customers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2408 (class 2606 OID 74609)
-- Name: deliveries_driver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deliveries
    ADD CONSTRAINT deliveries_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(id);


--
-- TOC entry 2409 (class 2606 OID 74614)
-- Name: deliveries_sale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deliveries
    ADD CONSTRAINT deliveries_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES public.sales(id);


--
-- TOC entry 2410 (class 2606 OID 74619)
-- Name: drivers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drivers
    ADD CONSTRAINT drivers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2411 (class 2606 OID 74624)
-- Name: employees_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2412 (class 2606 OID 74629)
-- Name: financial_reports_period_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_reports
    ADD CONSTRAINT financial_reports_period_id_fkey FOREIGN KEY (period_id) REFERENCES public.financial_periods(id);


--
-- TOC entry 2413 (class 2606 OID 74634)
-- Name: financial_reports_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_reports
    ADD CONSTRAINT financial_reports_user_id_fkey FOREIGN KEY (generated_by) REFERENCES public.users(id);


--
-- TOC entry 2414 (class 2606 OID 74639)
-- Name: fixed_assets_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fixed_assets
    ADD CONSTRAINT fixed_assets_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2406 (class 2606 OID 74644)
-- Name: fk_client_business; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client
    ADD CONSTRAINT fk_client_business FOREIGN KEY (businesses_id) REFERENCES public.businesses(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2442 (class 2606 OID 74649)
-- Name: fk_subsidiary_account_account; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subsidiary_account
    ADD CONSTRAINT fk_subsidiary_account_account FOREIGN KEY (account_id) REFERENCES public.account(account_id);


--
-- TOC entry 2415 (class 2606 OID 74654)
-- Name: inventory_log_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_log
    ADD CONSTRAINT inventory_log_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- TOC entry 2416 (class 2606 OID 74659)
-- Name: inventory_log_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_log
    ADD CONSTRAINT inventory_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2417 (class 2606 OID 74664)
-- Name: invoices_business_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_business_id_fkey FOREIGN KEY (business_id) REFERENCES public.businesses(id);


--
-- TOC entry 2418 (class 2606 OID 74669)
-- Name: invoices_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- TOC entry 2419 (class 2606 OID 74674)
-- Name: invoices_sale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES public.sales(id);


--
-- TOC entry 2420 (class 2606 OID 74679)
-- Name: journal_entries_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_entries
    ADD CONSTRAINT journal_entries_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2421 (class 2606 OID 74684)
-- Name: journal_items_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_items
    ADD CONSTRAINT journal_items_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.account(account_id);


--
-- TOC entry 2422 (class 2606 OID 74689)
-- Name: journal_items_journal_entry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_items
    ADD CONSTRAINT journal_items_journal_entry_id_fkey FOREIGN KEY (journal_entry_id) REFERENCES public.journal_entries(id);


--
-- TOC entry 2423 (class 2606 OID 74694)
-- Name: journal_items_subsidiary_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_items
    ADD CONSTRAINT journal_items_subsidiary_account_id_fkey FOREIGN KEY (subsidiary_account_id) REFERENCES public.subsidiary_account(subsidiary_account_id);


--
-- TOC entry 2424 (class 2606 OID 74699)
-- Name: ledger_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ledger
    ADD CONSTRAINT ledger_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.account(account_id);


--
-- TOC entry 2425 (class 2606 OID 74704)
-- Name: ledger_journal_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ledger
    ADD CONSTRAINT ledger_journal_item_id_fkey FOREIGN KEY (journal_item_id) REFERENCES public.journal_items(id);


--
-- TOC entry 2426 (class 2606 OID 74709)
-- Name: payments_business_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_business_id_fkey FOREIGN KEY (business_id) REFERENCES public.businesses(id);


--
-- TOC entry 2427 (class 2606 OID 74714)
-- Name: payments_purchase_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_purchase_id_fkey FOREIGN KEY (purchase_id) REFERENCES public.purchase_orders(id);


--
-- TOC entry 2428 (class 2606 OID 74719)
-- Name: payments_sale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES public.sales(id);


--
-- TOC entry 2429 (class 2606 OID 74724)
-- Name: payroll_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payroll
    ADD CONSTRAINT payroll_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id);


--
-- TOC entry 2430 (class 2606 OID 74729)
-- Name: payroll_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payroll
    ADD CONSTRAINT payroll_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2431 (class 2606 OID 74734)
-- Name: product_categories_business_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_categories
    ADD CONSTRAINT product_categories_business_id_fkey FOREIGN KEY (business_id) REFERENCES public.businesses(id);


--
-- TOC entry 2432 (class 2606 OID 74739)
-- Name: products_business_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_business_id_fkey FOREIGN KEY (business_id) REFERENCES public.businesses(id);


--
-- TOC entry 2433 (class 2606 OID 74744)
-- Name: products_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2434 (class 2606 OID 74749)
-- Name: purchase_order_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_order_items
    ADD CONSTRAINT purchase_order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- TOC entry 2435 (class 2606 OID 74754)
-- Name: purchase_order_items_purchase_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_order_items
    ADD CONSTRAINT purchase_order_items_purchase_order_id_fkey FOREIGN KEY (purchase_order_id) REFERENCES public.purchase_orders(id);


--
-- TOC entry 2437 (class 2606 OID 74837)
-- Name: purchase_orders_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_client_id_fkey FOREIGN KEY (client_id) REFERENCES public.client(client_id);


--
-- TOC entry 2436 (class 2606 OID 74759)
-- Name: purchase_orders_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2438 (class 2606 OID 74769)
-- Name: sale_products_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sale_products
    ADD CONSTRAINT sale_products_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- TOC entry 2439 (class 2606 OID 74774)
-- Name: sale_products_sale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sale_products
    ADD CONSTRAINT sale_products_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES public.sales(id);


--
-- TOC entry 2440 (class 2606 OID 74779)
-- Name: sales_business_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_business_id_fkey FOREIGN KEY (business_id) REFERENCES public.businesses(id);


--
-- TOC entry 2441 (class 2606 OID 74784)
-- Name: sales_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2443 (class 2606 OID 74789)
-- Name: transaction_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.account(account_id);


--
-- TOC entry 2444 (class 2606 OID 74794)
-- Name: transaction_business_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_business_id_fkey FOREIGN KEY (business_id) REFERENCES public.businesses(id);


--
-- TOC entry 2445 (class 2606 OID 74799)
-- Name: transaction_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2446 (class 2606 OID 74804)
-- Name: vendors_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vendors
    ADD CONSTRAINT vendors_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2569 (class 0 OID 0)
-- Dependencies: 7
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2025-07-19 23:44:32

--
-- PostgreSQL database dump complete
--

