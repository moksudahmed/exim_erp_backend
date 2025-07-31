--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.22
-- Dumped by pg_dump version 9.5.22

-- Started on 2024-09-24 15:28:00

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
-- TOC entry 2216 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- TOC entry 580 (class 1247 OID 33774)
-- Name: action_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.action_enum AS ENUM (
    'ADD',
    'DEDUCT',
    'DAMAGED'
);


ALTER TYPE public.action_enum OWNER TO postgres;

--
-- TOC entry 587 (class 1247 OID 33796)
-- Name: actiontype; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.actiontype AS ENUM (
    'ADD',
    'REMOVE',
    'UPDATE'
);


ALTER TYPE public.actiontype OWNER TO postgres;

--
-- TOC entry 590 (class 1247 OID 41688)
-- Name: transaction_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.transaction_type AS ENUM (
    'cash_in',
    'cash_out'
);


ALTER TYPE public.transaction_type OWNER TO postgres;

--
-- TOC entry 195 (class 1255 OID 33700)
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   NEW.updated_at = CURRENT_TIMESTAMP;
   RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 192 (class 1259 OID 41695)
-- Name: cash_registers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cash_registers (
    id integer NOT NULL,
    user_id integer NOT NULL,
    opening_balance numeric(10,2) NOT NULL,
    closing_balance numeric(10,2),
    opened_at timestamp without time zone DEFAULT now() NOT NULL,
    closed_at timestamp without time zone
);


ALTER TABLE public.cash_registers OWNER TO postgres;

--
-- TOC entry 191 (class 1259 OID 41693)
-- Name: cash_registers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cash_registers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cash_registers_id_seq OWNER TO postgres;

--
-- TOC entry 2217 (class 0 OID 0)
-- Dependencies: 191
-- Name: cash_registers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cash_registers_id_seq OWNED BY public.cash_registers.id;


--
-- TOC entry 194 (class 1259 OID 41709)
-- Name: cash_transactions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cash_transactions (
    id integer NOT NULL,
    register_id integer NOT NULL,
    transaction_type public.transaction_type NOT NULL,
    amount numeric(10,2) NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.cash_transactions OWNER TO postgres;

--
-- TOC entry 193 (class 1259 OID 41707)
-- Name: cash_transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cash_transactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cash_transactions_id_seq OWNER TO postgres;

--
-- TOC entry 2218 (class 0 OID 0)
-- Dependencies: 193
-- Name: cash_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cash_transactions_id_seq OWNED BY public.cash_transactions.id;


--
-- TOC entry 190 (class 1259 OID 33783)
-- Name: inventory_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inventory_logs (
    id integer NOT NULL,
    product_id integer,
    action_type public.action_enum,
    quantity integer,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.inventory_logs OWNER TO postgres;

--
-- TOC entry 189 (class 1259 OID 33781)
-- Name: inventory_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.inventory_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.inventory_logs_id_seq OWNER TO postgres;

--
-- TOC entry 2219 (class 0 OID 0)
-- Dependencies: 189
-- Name: inventory_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.inventory_logs_id_seq OWNED BY public.inventory_logs.id;


--
-- TOC entry 185 (class 1259 OID 33735)
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.products_id_seq
    START WITH 9
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.products_id_seq OWNER TO postgres;

--
-- TOC entry 187 (class 1259 OID 33739)
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    id integer DEFAULT nextval('public.products_id_seq'::regclass) NOT NULL,
    title character varying(255) NOT NULL,
    price_per_unit double precision NOT NULL,
    stock integer NOT NULL,
    category character varying(100) NOT NULL,
    sub_category character varying(255)
);


ALTER TABLE public.products OWNER TO postgres;

--
-- TOC entry 186 (class 1259 OID 33737)
-- Name: sale_products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sale_products_id_seq
    START WITH 118
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sale_products_id_seq OWNER TO postgres;

--
-- TOC entry 188 (class 1259 OID 33749)
-- Name: sale_products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sale_products (
    id integer DEFAULT nextval('public.sale_products_id_seq'::regclass) NOT NULL,
    sale_id integer NOT NULL,
    product_id integer NOT NULL,
    quantity integer NOT NULL,
    total_price double precision NOT NULL
);


ALTER TABLE public.sale_products OWNER TO postgres;

--
-- TOC entry 183 (class 1259 OID 33720)
-- Name: sales_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sales_id_seq
    START WITH 66
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sales_id_seq OWNER TO postgres;

--
-- TOC entry 184 (class 1259 OID 33722)
-- Name: sales; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sales (
    id integer DEFAULT nextval('public.sales_id_seq'::regclass) NOT NULL,
    user_id integer NOT NULL,
    total double precision NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    discount integer DEFAULT 0
);


ALTER TABLE public.sales OWNER TO postgres;

--
-- TOC entry 181 (class 1259 OID 33701)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    START WITH 22
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO postgres;

--
-- TOC entry 182 (class 1259 OID 33703)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer DEFAULT nextval('public.users_id_seq'::regclass) NOT NULL,
    username character varying(50) NOT NULL,
    email character varying(255) NOT NULL,
    hashed_password character varying(255) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    is_superuser boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 2041 (class 2604 OID 41698)
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cash_registers ALTER COLUMN id SET DEFAULT nextval('public.cash_registers_id_seq'::regclass);


--
-- TOC entry 2043 (class 2604 OID 41712)
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cash_transactions ALTER COLUMN id SET DEFAULT nextval('public.cash_transactions_id_seq'::regclass);


--
-- TOC entry 2039 (class 2604 OID 33786)
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_logs ALTER COLUMN id SET DEFAULT nextval('public.inventory_logs_id_seq'::regclass);


--
-- TOC entry 2205 (class 0 OID 41695)
-- Dependencies: 192
-- Data for Name: cash_registers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cash_registers (id, user_id, opening_balance, closing_balance, opened_at, closed_at) FROM stdin;
\.


--
-- TOC entry 2220 (class 0 OID 0)
-- Dependencies: 191
-- Name: cash_registers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cash_registers_id_seq', 1, false);


--
-- TOC entry 2207 (class 0 OID 41709)
-- Dependencies: 194
-- Data for Name: cash_transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cash_transactions (id, register_id, transaction_type, amount, created_at) FROM stdin;
\.


--
-- TOC entry 2221 (class 0 OID 0)
-- Dependencies: 193
-- Name: cash_transactions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cash_transactions_id_seq', 1, false);


--
-- TOC entry 2203 (class 0 OID 33783)
-- Dependencies: 190
-- Data for Name: inventory_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.inventory_logs (id, product_id, action_type, quantity, created_at) FROM stdin;
1	1	ADD	10	2024-09-18 12:25:34.352922
2	2	ADD	10	2024-09-18 15:51:29.791515
3	3	ADD	30	2024-09-18 15:52:19.528523
4	1	ADD	30	2024-09-18 15:52:33.8365
5	35	ADD	200	2024-09-22 11:54:23.720861
6	12	ADD	40	2024-09-22 11:55:59.744819
7	1	ADD	40	2024-09-22 11:56:18.533241
8	3	ADD	20	2024-09-22 12:01:59.369068
9	12	ADD	10	2024-09-22 12:03:21.236676
10	1	ADD	10	2024-09-22 12:04:03.436723
11	1	ADD	10	2024-09-22 12:04:49.999056
12	3	ADD	10	2024-09-22 12:05:02.516464
13	9	ADD	50	2024-09-22 12:05:14.18413
14	8	ADD	30	2024-09-22 12:27:19.338783
15	4	ADD	20	2024-09-22 12:28:16.472367
16	1	ADD	20	2024-09-22 12:31:08.424648
17	3	DAMAGED	1	2024-09-22 12:36:57.768806
18	1	ADD	2	2024-09-22 12:43:28.336313
19	5	ADD	2	2024-09-22 12:56:20.373018
20	8	ADD	2	2024-09-22 12:56:31.07148
21	1	DAMAGED	1	2024-09-22 14:49:53.662615
22	1	DAMAGED	1	2024-09-22 14:50:47.092716
23	3	DAMAGED	1	2024-09-22 14:51:51.913526
24	3	DAMAGED	1	2024-09-22 14:56:49.388305
25	3	DAMAGED	1	2024-09-22 14:57:08.269627
26	3	DAMAGED	1	2024-09-22 14:57:55.436868
27	3	DAMAGED	1	2024-09-22 14:58:30.078725
28	12	DAMAGED	1	2024-09-22 14:59:43.289421
29	12	ADD	10	2024-09-22 14:59:53.868537
30	12	ADD	10	2024-09-22 15:00:17.929944
31	12	ADD	10	2024-09-22 15:00:17.992396
32	12	ADD	23	2024-09-22 15:01:47.250975
33	12	ADD	23	2024-09-22 15:04:04.03269
34	12	ADD	23	2024-09-22 15:04:15.875088
35	3	ADD	4	2024-09-22 15:10:18.089735
36	5	ADD	2	2024-09-22 15:11:14.186242
37	5	ADD	2	2024-09-22 15:11:53.157502
38	5	ADD	2	2024-09-22 15:11:53.197452
39	5	ADD	2	2024-09-22 15:12:29.115504
40	5	ADD	2	2024-09-22 15:12:29.129262
41	5	ADD	2	2024-09-22 15:13:09.974063
42	5	ADD	2	2024-09-22 15:13:18.962547
43	8	DAMAGED	2	2024-09-22 15:14:24.888323
44	8	DAMAGED	2	2024-09-22 15:14:38.584736
45	2	DAMAGED	2	2024-09-22 15:24:51.25716
46	2	DAMAGED	1	2024-09-22 15:25:36.020387
47	2	DEDUCT	5	2024-09-22 15:26:06.070142
48	9	ADD	2	2024-09-22 15:28:02.278984
49	10	ADD	2	2024-09-22 15:28:38.348598
50	9	DAMAGED	3	2024-09-22 15:30:42.692438
51	10	DEDUCT	3	2024-09-22 15:31:20.285903
52	10	DEDUCT	3	2024-09-22 15:54:49.607449
53	6	DAMAGED	2	2024-09-22 15:56:18.940932
54	6	DAMAGED	2	2024-09-22 15:56:50.037937
55	6	DAMAGED	2	2024-09-22 15:57:21.062178
56	10	DAMAGED	2	2024-09-22 16:10:30.871976
\.


--
-- TOC entry 2222 (class 0 OID 0)
-- Dependencies: 189
-- Name: inventory_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.inventory_logs_id_seq', 56, true);


--
-- TOC entry 2200 (class 0 OID 33739)
-- Dependencies: 187
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (id, title, price_per_unit, stock, category, sub_category) FROM stdin;
11	Pen	100	98	Stationary	General
35	Book	400	491	General	
13	Chair	1000	98	General	General
38	Paper	10	4999	General	
5	Calculator	300	94	Electronic	General
8	Watch	60000	95	General	General
4	Telephone	2000	500	Electronic	Electronic
7	Monitor	8000	100	Electronic	Electronic
1	Mobile	20000	50	General	General
2	Laptop	50000	50	General	General
3	Desktop	40000	50	Electronic	Electronic
9	iPhone	100000	47	General	General
6	Printer	5000	94	Electronic	Electronic
10	Samsung	80000	42	General	General
37	Paper	10	4996	General	
12	Fan	6000	121	General	General
36	Book	400	498	General	
\.


--
-- TOC entry 2223 (class 0 OID 0)
-- Dependencies: 185
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.products_id_seq', 38, true);


--
-- TOC entry 2201 (class 0 OID 33749)
-- Dependencies: 188
-- Data for Name: sale_products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sale_products (id, sale_id, product_id, quantity, total_price) FROM stdin;
120	71	11	1	100
121	71	12	1	6000
122	72	35	9	400
123	72	5	10	300
124	72	3	3	40000
125	72	1	1	20000
126	72	36	1	400
127	72	37	2	10
128	72	11	1	100
129	73	9	2	100000
130	73	13	2	1000
131	73	10	2	80000
132	73	38	1	10
133	73	8	1	60000
134	75	37	2	10
135	76	12	1	6000
136	76	36	1	400
\.


--
-- TOC entry 2224 (class 0 OID 0)
-- Dependencies: 186
-- Name: sale_products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sale_products_id_seq', 136, true);


--
-- TOC entry 2197 (class 0 OID 33722)
-- Dependencies: 184
-- Data for Name: sales; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sales (id, user_id, total, created_at, discount) FROM stdin;
71	1	6100	2024-09-15 13:16:10.424057	0
72	1	55169	2024-09-15 14:12:38.865247	10
73	1	241010	2024-09-15 15:29:58.078364	10
74	1	0	2024-09-24 10:39:09.509612	0
75	1	10	2024-09-24 10:47:46.986683	0
76	1	6400	2024-09-24 11:03:37.228537	0
\.


--
-- TOC entry 2225 (class 0 OID 0)
-- Dependencies: 183
-- Name: sales_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sales_id_seq', 76, true);


--
-- TOC entry 2195 (class 0 OID 33703)
-- Dependencies: 182
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, email, hashed_password, is_active, is_superuser, created_at, updated_at) FROM stdin;
1	moksud	moksud@gmail.com	$2b$12$lwPrj5FMLqA5hmUDiK1DXewwYskXj4hNkjzou2aIg7DZYfO3ZnOS6	t	f	2024-09-12 10:50:56.509993	2024-09-15 13:13:01.736706
\.


--
-- TOC entry 2226 (class 0 OID 0)
-- Dependencies: 181
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 22, true);


--
-- TOC entry 2068 (class 2606 OID 41701)
-- Name: cash_registers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cash_registers
    ADD CONSTRAINT cash_registers_pkey PRIMARY KEY (id);


--
-- TOC entry 2071 (class 2606 OID 41715)
-- Name: cash_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cash_transactions
    ADD CONSTRAINT cash_transactions_pkey PRIMARY KEY (id);


--
-- TOC entry 2066 (class 2606 OID 33789)
-- Name: inventory_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_logs
    ADD CONSTRAINT inventory_logs_pkey PRIMARY KEY (id);


--
-- TOC entry 2058 (class 2606 OID 33747)
-- Name: products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- TOC entry 2062 (class 2606 OID 33754)
-- Name: sale_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sale_products
    ADD CONSTRAINT sale_products_pkey PRIMARY KEY (id);


--
-- TOC entry 2064 (class 2606 OID 33756)
-- Name: sale_products_sale_id_product_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sale_products
    ADD CONSTRAINT sale_products_sale_id_product_id_key UNIQUE (sale_id, product_id);


--
-- TOC entry 2055 (class 2606 OID 33729)
-- Name: sales_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_pkey PRIMARY KEY (id);


--
-- TOC entry 2048 (class 2606 OID 33717)
-- Name: users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 2050 (class 2606 OID 33715)
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 2052 (class 2606 OID 33719)
-- Name: users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- TOC entry 2056 (class 1259 OID 33748)
-- Name: idx_products_title; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_products_title ON public.products USING btree (title);


--
-- TOC entry 2072 (class 1259 OID 41721)
-- Name: idx_register_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_register_id ON public.cash_transactions USING btree (register_id);


--
-- TOC entry 2059 (class 1259 OID 33767)
-- Name: idx_sale_products_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sale_products_product_id ON public.sale_products USING btree (product_id);


--
-- TOC entry 2060 (class 1259 OID 33768)
-- Name: idx_sale_products_sale_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sale_products_sale_id ON public.sale_products USING btree (sale_id);


--
-- TOC entry 2053 (class 1259 OID 33769)
-- Name: idx_sales_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sales_user_id ON public.sales USING btree (user_id);


--
-- TOC entry 2069 (class 1259 OID 41722)
-- Name: idx_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_id ON public.cash_registers USING btree (user_id);


--
-- TOC entry 2045 (class 1259 OID 33770)
-- Name: idx_users_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_email ON public.users USING btree (email);


--
-- TOC entry 2046 (class 1259 OID 33771)
-- Name: idx_users_username; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_users_username ON public.users USING btree (username);


--
-- TOC entry 2079 (class 2620 OID 33772)
-- Name: update_users_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();


--
-- TOC entry 2078 (class 2606 OID 41716)
-- Name: fk_register; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cash_transactions
    ADD CONSTRAINT fk_register FOREIGN KEY (register_id) REFERENCES public.cash_registers(id) ON DELETE CASCADE;


--
-- TOC entry 2077 (class 2606 OID 41702)
-- Name: fk_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cash_registers
    ADD CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 2076 (class 2606 OID 33790)
-- Name: inventory_logs_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_logs
    ADD CONSTRAINT inventory_logs_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- TOC entry 2074 (class 2606 OID 33757)
-- Name: sale_products_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sale_products
    ADD CONSTRAINT sale_products_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- TOC entry 2075 (class 2606 OID 33762)
-- Name: sale_products_sale_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sale_products
    ADD CONSTRAINT sale_products_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES public.sales(id) ON DELETE CASCADE;


--
-- TOC entry 2073 (class 2606 OID 33730)
-- Name: sales_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 2215 (class 0 OID 0)
-- Dependencies: 6
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2024-09-24 15:28:00

--
-- PostgreSQL database dump complete
--

