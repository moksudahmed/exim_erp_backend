-- DROP DATABASE new_db_shop;
CREATE TABLE users (
     id SERIAL PRIMARY KEY,
    username character varying(50) NOT NULL,
    email character varying(255) NOT NULL,
    hashed_password character varying(255) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    is_superuser boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);

-- Customer Model
CREATE TABLE customers(
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    contact_info VARCHAR(255),
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL
);


INSERT INTO users(
            id, username, email, hashed_password, is_active, is_superuser, 
            created_at, updated_at)
    VALUES (1,'moksud','moksud@gmail.com','$2b$12$lwPrj5FMLqA5hmUDiK1DXewwYskXj4hNkjzou2aIg7DZYfO3ZnOS6', TRUE , FALSE, '2024-10-07 14:26:09.01554','2024-10-07 14:26:09.01554');


-- Employee Model
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    role VARCHAR(255) NOT NULL,
    contact_info VARCHAR(255),
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL
);


-- Product Model
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    price_per_unit NUMERIC(10, 2) NOT NULL,
    stock INTEGER NOT NULL,
    category VARCHAR(255),
    sub_category VARCHAR(255),
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL
);

-- Inventory Log Model
CREATE TABLE inventory_log (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    action_type VARCHAR(255) NOT NULL,  -- Added, Removed, Damaged
    quantity INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT now(),
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL
);

-- Sale Model
CREATE TABLE sales (
    id SERIAL PRIMARY KEY,
    total NUMERIC(10, 2) NOT NULL,
    discount integer DEFAULT 0,
    created_at TIMESTAMP DEFAULT now(),
    customer_id INTEGER REFERENCES customers(id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL
);
-- Sale Product Model
CREATE TABLE sale_products (
    id SERIAL PRIMARY KEY,
    sale_id INTEGER REFERENCES sales(id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL,
    price_per_unit NUMERIC(10, 2) NOT NULL,
    total_price NUMERIC(10, 2) NOT NULL
);

-- Payroll Model
CREATE TABLE payroll (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER REFERENCES employees(id) ON DELETE CASCADE,
    salary NUMERIC(10, 2) NOT NULL,
    tax NUMERIC(10, 2) NOT NULL,
    net_pay NUMERIC(10, 2) NOT NULL,
    payment_date TIMESTAMP DEFAULT now(),
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL
);


CREATE TABLE account (
    account_id SERIAL PRIMARY KEY,
    account_name VARCHAR(255) NOT NULL,
    account_type accounttypeenum NOT NULL,    
    balance NUMERIC(15, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE journal_entry (
    entry_id SERIAL PRIMARY KEY,
    description TEXT NOT NULL,
    entry_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);



 --DROP TABLE public.cash_flows;
--DROP TABLE public.transaction;
CREATE TABLE transaction (
    transaction_id SERIAL PRIMARY KEY,
    description TEXT NOT NULL,
    transaction_date DATE NOT NULL,
    amount NUMERIC(15, 2) NOT NULL,
    account_id INTEGER REFERENCES account(account_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL
);


CREATE TABLE vendor (
    vendor_id SERIAL PRIMARY KEY,
    vendor_name VARCHAR(255) NOT NULL,
    contact_info TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE accounts_payable (
    ap_id SERIAL PRIMARY KEY,
    vendor_id INTEGER REFERENCES vendor(vendor_id),
    due_amount NUMERIC(15, 2) NOT NULL,
    due_date DATE NOT NULL,
    transaction_id INTEGER REFERENCES transaction(transaction_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE accounts_receivable (
    ar_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(id),  -- corrected reference to 'id'
    due_amount NUMERIC(15, 2) NOT NULL,
    due_date DATE NOT NULL,
    transaction_id INTEGER REFERENCES transaction(transaction_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE budget (
    budget_id SERIAL PRIMARY KEY,
    account_id INTEGER REFERENCES account(account_id),
    amount NUMERIC(15, 2) NOT NULL,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE general_ledger (
    gl_id SERIAL PRIMARY KEY,
    account_id INTEGER REFERENCES account(account_id),
    journal_entry_id INTEGER REFERENCES journal_entry(entry_id),
    debit NUMERIC(15, 2) NOT NULL,
    credit NUMERIC(15, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);



CREATE TABLE financial_report (
    report_id SERIAL PRIMARY KEY,
    report_name VARCHAR(255) NOT NULL,
    report_date DATE NOT NULL,
    total_income NUMERIC(15, 2) NOT NULL,
    total_expenses NUMERIC(15, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


