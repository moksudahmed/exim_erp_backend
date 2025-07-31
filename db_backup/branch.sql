--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.22
-- Dumped by pg_dump version 9.5.22

-- Started on 2025-07-30 14:34:29

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_with_oids = false;

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
-- TOC entry 2417 (class 0 OID 132805)
-- Dependencies: 255
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.products VALUES (2, 'Indian Coal', 12000.00, 166, 'Coal', 'MEDIUM', NULL, 'tangible', 'mt', 1000.000, true, NULL, 'Coal', '2025-06-29 16:05:28.453686', '2025-07-19 22:38:46.25387', 1);
INSERT INTO public.products VALUES (5, 'Australian Coal', 12000.00, 170, 'Coal', 'MIXTURE', NULL, 'tangible', 'mt', 1000.000, true, NULL, 'Coal', '2025-06-29 16:07:32.368069', '2025-07-20 17:31:14.762707', 1);
INSERT INTO public.products VALUES (3, 'Indonesian Coal', 10000.00, 327, 'Coal', 'MEDIUM', NULL, 'tangible', 'mt', 1000.000, true, NULL, 'Coal', '2025-06-29 16:06:28.475827', '2025-07-29 16:40:48.867807', 1);
INSERT INTO public.products VALUES (4, 'South African Coal', 10000.00, 180, 'Coal', 'SUPER', NULL, 'tangible', 'mt', 1000.000, true, NULL, 'Coal', '2025-06-29 16:07:02.872417', '2025-07-29 16:40:48.867807', 1);


--
-- TOC entry 2296 (class 2606 OID 132994)
-- Name: products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- TOC entry 2297 (class 2606 OID 133302)
-- Name: products_business_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_business_id_fkey FOREIGN KEY (business_id) REFERENCES public.businesses(id);


--
-- TOC entry 2298 (class 2606 OID 133307)
-- Name: products_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


-- Completed on 2025-07-30 14:34:29

--
-- PostgreSQL database dump complete
--

