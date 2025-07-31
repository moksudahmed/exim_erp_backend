BEGIN;

CREATE TABLE alembic_version (
    version_num VARCHAR(32) NOT NULL,
    CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num)
);

--INFO  [alembic.runtime.migration] Running upgrade  -> 605f2c8a2f6c, Initial migration
-- Running upgrade  -> 605f2c8a2f6c

CREATE TABLE "user" (
    id SERIAL NOT NULL,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL,
    hashed_password VARCHAR(255) NOT NULL,
    is_active BOOLEAN NOT NULL,
    is_superuser BOOLEAN NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    PRIMARY KEY (id)
);

CREATE UNIQUE INDEX ix_user_username ON "user" (username);

CREATE UNIQUE INDEX ix_user_email ON "user" (email);

CREATE INDEX ix_user_id ON "user" (id);

CREATE TABLE product (
    id SERIAL NOT NULL,
    title VARCHAR NOT NULL,
    price_per_unit FLOAT NOT NULL,
    stock INTEGER NOT NULL,
    PRIMARY KEY (id)
);

CREATE INDEX ix_product_title ON product (title);

CREATE INDEX ix_product_id ON product (id);

CREATE TABLE sale (
    id SERIAL NOT NULL,
    user_id INTEGER NOT NULL,
    total FLOAT NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT now() NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY(user_id) REFERENCES "user" (id)
);

CREATE INDEX ix_sale_id ON sale (id);

CREATE TABLE sale_product (
    sale_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    total_price FLOAT NOT NULL,
    PRIMARY KEY (sale_id, product_id),
    FOREIGN KEY(sale_id) REFERENCES sale (id) ON DELETE CASCADE,
    FOREIGN KEY(product_id) REFERENCES product (id) ON DELETE CASCADE
);

INSERT INTO alembic_version (version_num) VALUES ('605f2c8a2f6c') RETURNING alembic_version.version_num;

COMMIT;


-- Create an enum type for transaction types
CREATE TYPE transaction_type AS ENUM ('cash_in', 'cash_out');

-- Create a table for cash registers
CREATE TABLE cash_registers (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,  -- Assuming you have a users table
    opening_balance DECIMAL(10, 2) NOT NULL,
    closing_balance DECIMAL(10, 2),
    opened_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    closed_at TIMESTAMP,
    CONSTRAINT fk_user
        FOREIGN KEY(user_id) 
        REFERENCES users(id)  -- Change to your actual users table
);

-- Create a table for cash transactions
CREATE TABLE cash_transactions (
    id SERIAL PRIMARY KEY,
    register_id INT NOT NULL,
    transaction_type transaction_type NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_register
        FOREIGN KEY(register_id) 
        REFERENCES cash_registers(id)
        ON DELETE CASCADE  -- Optionally delete transactions when the register is deleted
);

-- Create indexes for performance optimization (optional)
CREATE INDEX idx_register_id ON cash_transactions(register_id);
CREATE INDEX idx_user_id ON cash_registers(user_id);
