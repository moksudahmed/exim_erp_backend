--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.22
-- Dumped by pg_dump version 9.5.22

-- Started on 2025-07-13 00:21:35

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
-- TOC entry 2554 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- TOC entry 614 (class 1247 OID 69365)
-- Name: accountaction; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.accountaction AS ENUM (
    'DEBIT',
    'CREDIT'
);


ALTER TYPE public.accountaction OWNER TO postgres;

--
-- TOC entry 617 (class 1247 OID 69370)
-- Name: accountnature; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.accountnature AS ENUM (
    'DEBIT',
    'CREDIT'
);


ALTER TYPE public.accountnature OWNER TO postgres;

--
-- TOC entry 620 (class 1247 OID 69376)
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
-- TOC entry 623 (class 1247 OID 69388)
-- Name: actiontype; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.actiontype AS ENUM (
    'ADD',
    'DAMAGED',
    'DEDUCT'
);


ALTER TYPE public.actiontype OWNER TO postgres;

--
-- TOC entry 626 (class 1247 OID 69396)
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
-- TOC entry 629 (class 1247 OID 69408)
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
-- TOC entry 632 (class 1247 OID 69418)
-- Name: payment_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.payment_status AS ENUM (
    'PENDING',
    'PARTIAL',
    'PAID'
);


ALTER TYPE public.payment_status OWNER TO postgres;

--
-- TOC entry 635 (class 1247 OID 69426)
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
-- TOC entry 638 (class 1247 OID 69446)
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
-- TOC entry 641 (class 1247 OID 69458)
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
-- TOC entry 644 (class 1247 OID 69468)
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
-- TOC entry 247 (class 1255 OID 71448)
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
-- TOC entry 181 (class 1259 OID 69501)
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
-- TOC entry 182 (class 1259 OID 69503)
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
-- TOC entry 183 (class 1259 OID 69513)
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
-- TOC entry 184 (class 1259 OID 69515)
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
-- TOC entry 185 (class 1259 OID 69521)
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
-- TOC entry 186 (class 1259 OID 69523)
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
-- TOC entry 187 (class 1259 OID 69531)
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
-- TOC entry 188 (class 1259 OID 69533)
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
-- TOC entry 189 (class 1259 OID 69540)
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
-- TOC entry 190 (class 1259 OID 69542)
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
-- TOC entry 191 (class 1259 OID 69550)
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
-- TOC entry 192 (class 1259 OID 69557)
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
-- TOC entry 193 (class 1259 OID 69559)
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
-- TOC entry 240 (class 1259 OID 71475)
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
-- TOC entry 241 (class 1259 OID 71477)
-- Name: client; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.client (
    client_id integer DEFAULT nextval('public.client_client_id_seq'::regclass) NOT NULL,
    client_type character varying(30),
    registration_date date,
    businesses_id integer NOT NULL
);


ALTER TABLE public.client OWNER TO postgres;

--
-- TOC entry 194 (class 1259 OID 69573)
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
-- TOC entry 195 (class 1259 OID 69575)
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
-- TOC entry 196 (class 1259 OID 69582)
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
-- TOC entry 197 (class 1259 OID 69584)
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
-- TOC entry 198 (class 1259 OID 69596)
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
-- TOC entry 199 (class 1259 OID 69598)
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
-- TOC entry 200 (class 1259 OID 69607)
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
-- TOC entry 201 (class 1259 OID 69609)
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
-- TOC entry 202 (class 1259 OID 69616)
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
-- TOC entry 203 (class 1259 OID 69618)
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
-- TOC entry 204 (class 1259 OID 69626)
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
-- TOC entry 205 (class 1259 OID 69628)
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
-- TOC entry 206 (class 1259 OID 69637)
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
-- TOC entry 207 (class 1259 OID 69639)
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
-- TOC entry 208 (class 1259 OID 69646)
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
-- TOC entry 209 (class 1259 OID 69648)
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
-- TOC entry 210 (class 1259 OID 69650)
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
-- TOC entry 211 (class 1259 OID 69655)
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
-- TOC entry 212 (class 1259 OID 69657)
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
-- TOC entry 213 (class 1259 OID 69665)
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
-- TOC entry 214 (class 1259 OID 69667)
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
-- TOC entry 215 (class 1259 OID 69675)
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
-- TOC entry 216 (class 1259 OID 69677)
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
-- TOC entry 244 (class 1259 OID 71511)
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
-- TOC entry 217 (class 1259 OID 69687)
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
-- TOC entry 245 (class 1259 OID 71536)
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
-- TOC entry 218 (class 1259 OID 69697)
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
-- TOC entry 219 (class 1259 OID 69699)
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
-- TOC entry 220 (class 1259 OID 69707)
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
-- TOC entry 221 (class 1259 OID 69709)
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
-- TOC entry 222 (class 1259 OID 69717)
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
-- TOC entry 223 (class 1259 OID 69719)
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
-- TOC entry 224 (class 1259 OID 69726)
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
-- TOC entry 225 (class 1259 OID 69728)
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
-- TOC entry 226 (class 1259 OID 69740)
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
-- TOC entry 227 (class 1259 OID 69742)
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
-- TOC entry 228 (class 1259 OID 69746)
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
-- TOC entry 229 (class 1259 OID 69748)
-- Name: purchase_orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.purchase_orders (
    id integer DEFAULT nextval('public.purchase_orders_id_seq'::regclass) NOT NULL,
    vendor_id integer,
    date date NOT NULL,
    total_amount double precision NOT NULL,
    status public.order_status DEFAULT 'PENDING'::public.order_status,
    user_id integer
);


ALTER TABLE public.purchase_orders OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 69753)
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
-- TOC entry 231 (class 1259 OID 69755)
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
-- TOC entry 232 (class 1259 OID 69762)
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
-- TOC entry 233 (class 1259 OID 69764)
-- Name: sales; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sales (
    id integer DEFAULT nextval('public.sales_id_seq'::regclass) NOT NULL,
    total numeric NOT NULL,
    discount integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT now(),
    user_id integer,
    business_id integer NOT NULL,
    payment_status public.payment_status,
    subsidiary_account_id integer
);


ALTER TABLE public.sales OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 71491)
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
-- TOC entry 243 (class 1259 OID 71493)
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
-- TOC entry 246 (class 1259 OID 71556)
-- Name: subsidiary_account_ledger_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.subsidiary_account_ledger_view AS
 SELECT a.account_id,
    a.account_name AS main_account_name,
    a.account_type,
    a.balance,
    s.subsidiary_account_id,
    s.client_id,
    s.account_name AS subsidiary_account_name,
    s.account_no,
    s.address,
    s.branch,
    s.account_holder,
    s.type AS subsidiary_type,
    i.journal_entry_id,
    i.narration,
    i.debitcredit,
    i.amount,
    j.account_type AS journal_account_type,
    j.company,
    j.transaction_date,
    c.client_type
   FROM ((((public.subsidiary_account s
     JOIN public.account a ON ((a.account_id = s.account_id)))
     JOIN public.journal_items i ON ((s.subsidiary_account_id = i.subsidiary_account_id)))
     JOIN public.journal_entries j ON ((j.id = i.journal_entry_id)))
     JOIN public.client c ON ((c.client_id = s.client_id)));


ALTER TABLE public.subsidiary_account_ledger_view OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 69780)
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
-- TOC entry 235 (class 1259 OID 69782)
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
-- TOC entry 236 (class 1259 OID 69790)
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
-- TOC entry 237 (class 1259 OID 69792)
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
-- TOC entry 238 (class 1259 OID 69805)
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
-- TOC entry 239 (class 1259 OID 69807)
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
-- TOC entry 2309 (class 2606 OID 69817)
-- Name: account_account_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_account_name_key UNIQUE (account_name);


--
-- TOC entry 2311 (class 2606 OID 69819)
-- Name: account_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_pkey PRIMARY KEY (account_id);


--
-- TOC entry 2313 (class 2606 OID 69821)
-- Name: accounts_payable_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts_payable
    ADD CONSTRAINT accounts_payable_pkey PRIMARY KEY (id);


--
-- TOC entry 2315 (class 2606 OID 69823)
-- Name: accounts_receivable_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts_receivable
    ADD CONSTRAINT accounts_receivable_pkey PRIMARY KEY (id);


--
-- TOC entry 2317 (class 2606 OID 69825)
-- Name: branch_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.branch
    ADD CONSTRAINT branch_pkey PRIMARY KEY (id);


--
-- TOC entry 2319 (class 2606 OID 69827)
-- Name: budget_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.budget
    ADD CONSTRAINT budget_pkey PRIMARY KEY (id);


--
-- TOC entry 2321 (class 2606 OID 69829)
-- Name: business_members_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.business_members
    ADD CONSTRAINT business_members_pkey PRIMARY KEY (user_id, business_id);


--
-- TOC entry 2323 (class 2606 OID 69831)
-- Name: businesses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.businesses
    ADD CONSTRAINT businesses_pkey PRIMARY KEY (id);


--
-- TOC entry 2369 (class 2606 OID 71482)
-- Name: client_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client
    ADD CONSTRAINT client_pkey PRIMARY KEY (client_id);


--
-- TOC entry 2325 (class 2606 OID 69835)
-- Name: customers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- TOC entry 2327 (class 2606 OID 69837)
-- Name: deliveries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deliveries
    ADD CONSTRAINT deliveries_pkey PRIMARY KEY (id);


--
-- TOC entry 2329 (class 2606 OID 69839)
-- Name: drivers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drivers
    ADD CONSTRAINT drivers_pkey PRIMARY KEY (id);


--
-- TOC entry 2331 (class 2606 OID 69841)
-- Name: employees_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (id);


--
-- TOC entry 2333 (class 2606 OID 69843)
-- Name: financial_periods_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_periods
    ADD CONSTRAINT financial_periods_pkey PRIMARY KEY (id);


--
-- TOC entry 2335 (class 2606 OID 69845)
-- Name: financial_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_reports
    ADD CONSTRAINT financial_reports_pkey PRIMARY KEY (id);


--
-- TOC entry 2337 (class 2606 OID 69847)
-- Name: fixed_assets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fixed_assets
    ADD CONSTRAINT fixed_assets_pkey PRIMARY KEY (id);


--
-- TOC entry 2339 (class 2606 OID 69849)
-- Name: inventory_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_log
    ADD CONSTRAINT inventory_log_pkey PRIMARY KEY (id);


--
-- TOC entry 2341 (class 2606 OID 69851)
-- Name: invoices_invoice_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_invoice_number_key UNIQUE (invoice_number);


--
-- TOC entry 2343 (class 2606 OID 69853)
-- Name: invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- TOC entry 2345 (class 2606 OID 69855)
-- Name: journal_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_entries
    ADD CONSTRAINT journal_entries_pkey PRIMARY KEY (id);


--
-- TOC entry 2373 (class 2606 OID 71520)
-- Name: journal_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_items
    ADD CONSTRAINT journal_items_pkey PRIMARY KEY (id);


--
-- TOC entry 2375 (class 2606 OID 71545)
-- Name: ledger_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ledger
    ADD CONSTRAINT ledger_pkey PRIMARY KEY (id);


--
-- TOC entry 2347 (class 2606 OID 69861)
-- Name: payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- TOC entry 2349 (class 2606 OID 69863)
-- Name: payroll_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payroll
    ADD CONSTRAINT payroll_pkey PRIMARY KEY (id);


--
-- TOC entry 2351 (class 2606 OID 69865)
-- Name: product_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_categories
    ADD CONSTRAINT product_categories_pkey PRIMARY KEY (id);


--
-- TOC entry 2353 (class 2606 OID 69867)
-- Name: products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- TOC entry 2355 (class 2606 OID 69869)
-- Name: purchase_order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_order_items
    ADD CONSTRAINT purchase_order_items_pkey PRIMARY KEY (id);


--
-- TOC entry 2357 (class 2606 OID 69871)
-- Name: purchase_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_pkey PRIMARY KEY (id);


--
-- TOC entry 2359 (class 2606 OID 69873)
-- Name: sale_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sale_products
    ADD CONSTRAINT sale_products_pkey PRIMARY KEY (id);


--
-- TOC entry 2361 (class 2606 OID 69875)
-- Name: sales_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_pkey PRIMARY KEY (id);


--
-- TOC entry 2371 (class 2606 OID 71500)
-- Name: subsidiary_account_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subsidiary_account
    ADD CONSTRAINT subsidiary_account_pkey PRIMARY KEY (subsidiary_account_id);


--
-- TOC entry 2363 (class 2606 OID 69879)
-- Name: transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_pkey PRIMARY KEY (transaction_id);


--
-- TOC entry 2365 (class 2606 OID 69881)
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 2367 (class 2606 OID 69883)
-- Name: vendors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vendors
    ADD CONSTRAINT vendors_pkey PRIMARY KEY (id);


--
-- TOC entry 2376 (class 2606 OID 69884)
-- Name: account_business_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_business_id_fkey FOREIGN KEY (business_id) REFERENCES public.businesses(id);


--
-- TOC entry 2377 (class 2606 OID 69889)
-- Name: account_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.account(account_id);


--
-- TOC entry 2378 (class 2606 OID 69894)
-- Name: accounts_payable_purchase_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts_payable
    ADD CONSTRAINT accounts_payable_purchase_order_id_fkey FOREIGN KEY (purchase_order_id) REFERENCES public.purchase_orders(id);


--
-- TOC entry 2379 (class 2606 OID 69899)
-- Name: accounts_payable_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts_payable
    ADD CONSTRAINT accounts_payable_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2380 (class 2606 OID 69904)
-- Name: accounts_receivable_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts_receivable
    ADD CONSTRAINT accounts_receivable_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- TOC entry 2381 (class 2606 OID 69909)
-- Name: accounts_receivable_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts_receivable
    ADD CONSTRAINT accounts_receivable_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2382 (class 2606 OID 69914)
-- Name: branch_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.branch
    ADD CONSTRAINT branch_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.users(id);


--
-- TOC entry 2383 (class 2606 OID 69919)
-- Name: brnach_business_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.branch
    ADD CONSTRAINT brnach_business_id_fkey FOREIGN KEY (business_id) REFERENCES public.businesses(id);


--
-- TOC entry 2384 (class 2606 OID 69924)
-- Name: budget_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.budget
    ADD CONSTRAINT budget_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.journal_entries(id);


--
-- TOC entry 2385 (class 2606 OID 69929)
-- Name: budget_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.budget
    ADD CONSTRAINT budget_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2386 (class 2606 OID 69934)
-- Name: business_members_business_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.business_members
    ADD CONSTRAINT business_members_business_id_fkey FOREIGN KEY (business_id) REFERENCES public.businesses(id);


--
-- TOC entry 2387 (class 2606 OID 69939)
-- Name: business_members_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.business_members
    ADD CONSTRAINT business_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2388 (class 2606 OID 69944)
-- Name: customers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2389 (class 2606 OID 69949)
-- Name: deliveries_driver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deliveries
    ADD CONSTRAINT deliveries_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(id);


--
-- TOC entry 2390 (class 2606 OID 69954)
-- Name: deliveries_sale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deliveries
    ADD CONSTRAINT deliveries_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES public.sales(id);


--
-- TOC entry 2391 (class 2606 OID 69959)
-- Name: drivers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drivers
    ADD CONSTRAINT drivers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2392 (class 2606 OID 69964)
-- Name: employees_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2393 (class 2606 OID 69969)
-- Name: financial_reports_period_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_reports
    ADD CONSTRAINT financial_reports_period_id_fkey FOREIGN KEY (period_id) REFERENCES public.financial_periods(id);


--
-- TOC entry 2394 (class 2606 OID 69974)
-- Name: financial_reports_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.financial_reports
    ADD CONSTRAINT financial_reports_user_id_fkey FOREIGN KEY (generated_by) REFERENCES public.users(id);


--
-- TOC entry 2395 (class 2606 OID 69979)
-- Name: fixed_assets_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fixed_assets
    ADD CONSTRAINT fixed_assets_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2423 (class 2606 OID 71483)
-- Name: fk_client_business; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.client
    ADD CONSTRAINT fk_client_business FOREIGN KEY (businesses_id) REFERENCES public.businesses(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2424 (class 2606 OID 71501)
-- Name: fk_subsidiary_account_account; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subsidiary_account
    ADD CONSTRAINT fk_subsidiary_account_account FOREIGN KEY (account_id) REFERENCES public.account(account_id);


--
-- TOC entry 2425 (class 2606 OID 71506)
-- Name: fk_subsidiary_account_client; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subsidiary_account
    ADD CONSTRAINT fk_subsidiary_account_client FOREIGN KEY (client_id) REFERENCES public.client(client_id) ON DELETE SET NULL;


--
-- TOC entry 2396 (class 2606 OID 69994)
-- Name: inventory_log_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_log
    ADD CONSTRAINT inventory_log_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- TOC entry 2397 (class 2606 OID 69999)
-- Name: inventory_log_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_log
    ADD CONSTRAINT inventory_log_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2398 (class 2606 OID 70004)
-- Name: invoices_business_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_business_id_fkey FOREIGN KEY (business_id) REFERENCES public.businesses(id);


--
-- TOC entry 2399 (class 2606 OID 70009)
-- Name: invoices_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- TOC entry 2400 (class 2606 OID 70014)
-- Name: invoices_sale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES public.sales(id);


--
-- TOC entry 2401 (class 2606 OID 70019)
-- Name: journal_entries_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_entries
    ADD CONSTRAINT journal_entries_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2426 (class 2606 OID 71521)
-- Name: journal_items_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_items
    ADD CONSTRAINT journal_items_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.account(account_id);


--
-- TOC entry 2427 (class 2606 OID 71526)
-- Name: journal_items_journal_entry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_items
    ADD CONSTRAINT journal_items_journal_entry_id_fkey FOREIGN KEY (journal_entry_id) REFERENCES public.journal_entries(id);


--
-- TOC entry 2428 (class 2606 OID 71531)
-- Name: journal_items_subsidiary_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journal_items
    ADD CONSTRAINT journal_items_subsidiary_account_id_fkey FOREIGN KEY (subsidiary_account_id) REFERENCES public.subsidiary_account(subsidiary_account_id);


--
-- TOC entry 2429 (class 2606 OID 71546)
-- Name: ledger_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ledger
    ADD CONSTRAINT ledger_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.account(account_id);


--
-- TOC entry 2430 (class 2606 OID 71551)
-- Name: ledger_journal_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ledger
    ADD CONSTRAINT ledger_journal_item_id_fkey FOREIGN KEY (journal_item_id) REFERENCES public.journal_items(id);


--
-- TOC entry 2402 (class 2606 OID 70044)
-- Name: payments_business_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_business_id_fkey FOREIGN KEY (business_id) REFERENCES public.businesses(id);


--
-- TOC entry 2403 (class 2606 OID 70049)
-- Name: payments_purchase_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_purchase_id_fkey FOREIGN KEY (purchase_id) REFERENCES public.purchase_orders(id);


--
-- TOC entry 2404 (class 2606 OID 70054)
-- Name: payments_sale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES public.sales(id);


--
-- TOC entry 2405 (class 2606 OID 70059)
-- Name: payroll_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payroll
    ADD CONSTRAINT payroll_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES public.employees(id);


--
-- TOC entry 2406 (class 2606 OID 70064)
-- Name: payroll_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payroll
    ADD CONSTRAINT payroll_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2407 (class 2606 OID 70069)
-- Name: product_categories_business_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_categories
    ADD CONSTRAINT product_categories_business_id_fkey FOREIGN KEY (business_id) REFERENCES public.businesses(id);


--
-- TOC entry 2408 (class 2606 OID 70074)
-- Name: products_business_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_business_id_fkey FOREIGN KEY (business_id) REFERENCES public.businesses(id);


--
-- TOC entry 2409 (class 2606 OID 70079)
-- Name: products_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2410 (class 2606 OID 70084)
-- Name: purchase_order_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_order_items
    ADD CONSTRAINT purchase_order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- TOC entry 2411 (class 2606 OID 70089)
-- Name: purchase_order_items_purchase_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_order_items
    ADD CONSTRAINT purchase_order_items_purchase_order_id_fkey FOREIGN KEY (purchase_order_id) REFERENCES public.purchase_orders(id);


--
-- TOC entry 2412 (class 2606 OID 70094)
-- Name: purchase_orders_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2413 (class 2606 OID 70099)
-- Name: purchase_orders_vendor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_vendor_id_fkey FOREIGN KEY (vendor_id) REFERENCES public.vendors(id);


--
-- TOC entry 2414 (class 2606 OID 70104)
-- Name: sale_products_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sale_products
    ADD CONSTRAINT sale_products_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- TOC entry 2415 (class 2606 OID 70109)
-- Name: sale_products_sale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sale_products
    ADD CONSTRAINT sale_products_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES public.sales(id);


--
-- TOC entry 2416 (class 2606 OID 70114)
-- Name: sales_business_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_business_id_fkey FOREIGN KEY (business_id) REFERENCES public.businesses(id);


--
-- TOC entry 2418 (class 2606 OID 71561)
-- Name: sales_subsidiary_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_subsidiary_account_id_fkey FOREIGN KEY (subsidiary_account_id) REFERENCES public.subsidiary_account(subsidiary_account_id) ON DELETE SET NULL;


--
-- TOC entry 2417 (class 2606 OID 70124)
-- Name: sales_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2419 (class 2606 OID 70129)
-- Name: transaction_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.account(account_id);


--
-- TOC entry 2420 (class 2606 OID 70134)
-- Name: transaction_business_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_business_id_fkey FOREIGN KEY (business_id) REFERENCES public.businesses(id);


--
-- TOC entry 2421 (class 2606 OID 70139)
-- Name: transaction_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2422 (class 2606 OID 70144)
-- Name: vendors_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vendors
    ADD CONSTRAINT vendors_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2553 (class 0 OID 0)
-- Dependencies: 7
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2025-07-13 00:21:36

--
-- PostgreSQL database dump complete
--

