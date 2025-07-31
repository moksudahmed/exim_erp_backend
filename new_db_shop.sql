-- DROP DATABASE new_db_shop;
CREATE TABLE public.users (
     id SERIAL PRIMARY KEY,
    username character varying(50) NOT NULL,
    email character varying(255) NOT NULL,
    hashed_password character varying(255) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    is_superuser boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


INSERT INTO public.users(
            id, username, email, hashed_password, is_active, is_superuser, 
            created_at, updated_at)
    VALUES (1,'moksud','moksud@gmail.com','$2b$12$lwPrj5FMLqA5hmUDiK1DXewwYskXj4hNkjzou2aIg7DZYfO3ZnOS6', TRUE , FALSE, '2024-10-07 14:26:09.01554','2024-10-07 14:26:09.01554');

-- Customer Model
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    contact_info VARCHAR(255),
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL
);

-- Vendor Model
CREATE TABLE vendors (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    contact_info VARCHAR(255),
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL
);

-- Accounts Payable Model
CREATE TABLE accounts_payable (
    id SERIAL PRIMARY KEY,
    vendor_id INTEGER REFERENCES vendors(id) ON DELETE CASCADE,
    amount NUMERIC(10, 2) NOT NULL,
    due_date TIMESTAMP NOT NULL,
    status BOOLEAN DEFAULT FALSE,  -- Paid or Unpaid
    created_at TIMESTAMP DEFAULT now(),
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL
);

-- Accounts Receivable Model
CREATE TABLE accounts_receivable (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(id) ON DELETE CASCADE,
    amount NUMERIC(10, 2) NOT NULL,
    due_date TIMESTAMP NOT NULL,
    status BOOLEAN DEFAULT FALSE,  -- Paid or Unpaid
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL
);

-- Transaction Model (Covers Expense, Income, and Payment Transactions)
CREATE TABLE transactions (
    id SERIAL PRIMARY KEY,
    transaction_type VARCHAR(255) NOT NULL,  -- Expense, Income, Payment
    description VARCHAR(255),
    amount NUMERIC(10, 2) NOT NULL,
    transaction_date TIMESTAMP DEFAULT now(),
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL
);

-- Enum for account types in the general ledger
--CREATE TYPE account_type_enum AS ENUM ('Asset', 'Liability', 'Equity', 'Revenue', 'Expense');
CREATE TYPE accounttypeenum AS ENUM ('ASSET', 'LIABILITY', 'EQUITY', 'REVENUE', 'EXPENSE');
 
-- Table: general_ledger
CREATE TABLE general_ledger (
    id SERIAL PRIMARY KEY,
    account_name VARCHAR(255) NOT NULL,
    account_type accounttypeenum NOT NULL,
    debit NUMERIC(10, 2),
    credit NUMERIC(10, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    user_id INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users (id)
);

-- Table: journal_entries
CREATE TABLE journal_entries (
    id SERIAL PRIMARY KEY,
    entry_type VARCHAR(255) NOT NULL,
    debit NUMERIC(10, 2) NOT NULL,
    credit NUMERIC(10, 2) NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    transaction_date TIMESTAMP,
    general_ledger_id INTEGER NOT NULL,
    FOREIGN KEY (general_ledger_id) REFERENCES general_ledger (id)
);

-- Indices for faster lookup (optional)
CREATE INDEX idx_general_ledger_user_id ON general_ledger (user_id);
CREATE INDEX idx_journal_entries_general_ledger_id ON journal_entries (general_ledger_id);


-- Budget Model
CREATE TABLE budget (
    id SERIAL PRIMARY KEY,
    account_id INTEGER REFERENCES general_ledger(id),
    budgeted_amount NUMERIC(10, 2) NOT NULL,
    actual_amount NUMERIC(10, 2) NOT NULL,
    variance NUMERIC(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT now(),
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL
);

-- Cash Flow Model
-- DROP TABLE public.cash_flows;


CREATE TABLE cash_flows (
    id SERIAL PRIMARY KEY,  -- Auto-incrementing primary key    
    action_type VARCHAR(50) NOT NULL,  -- Type of action ('CASH_INFLOW', 'CASH_OUTFLOW', 'REGISTER_OPEN', 'REGISTER_CLOSE')
    amount NUMERIC(10, 2) NOT NULL,  -- The amount of cash for the transaction
    description TEXT,  -- Optional description for the cash flow
    register_balance_before NUMERIC(10, 2) NOT NULL,  -- Balance before the transaction
    register_balance_after NUMERIC(10, 2) NOT NULL,  -- Balance after the transaction
    related_transaction_id INTEGER REFERENCES transactions(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL,  -- Foreign key referencing 'users' table
    created_at TIMESTAMP DEFAULT NOW(),  -- Timestamp of the transaction creation
    updated_at TIMESTAMP DEFAULT NOW(),  -- Timestamp of the last update (initial default value)

    CONSTRAINT fk_user
      FOREIGN KEY(user_id) 
      REFERENCES users(id)
      ON DELETE CASCADE  -- Cascade delete if the user is deleted
);

-- Indexes for optimizing query performance
CREATE INDEX idx_cash_flows_user_id ON cash_flows(user_id);
CREATE INDEX idx_cash_flows_action_type ON cash_flows(action_type);

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

-- Financial Report Model
CREATE TABLE financial_reports (
    id SERIAL PRIMARY KEY,
    report_type VARCHAR(255) NOT NULL,  -- Balance Sheet, Profit & Loss, etc.
    generated_at TIMESTAMP DEFAULT now(),
    data JSON NOT NULL,  -- Store report data as JSON for flexibility
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL
);

-- Fixed Asset Model
CREATE TABLE fixed_assets (
    id SERIAL PRIMARY KEY,
    asset_name VARCHAR(255) NOT NULL,
    purchase_date TIMESTAMP NOT NULL,
    purchase_price NUMERIC(10, 2) NOT NULL,
    depreciation_rate NUMERIC(5, 2) NOT NULL,  -- Depreciation percentage
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL
);
