-- ===============================
-- Create Silver Schema
-- -- ===============================
-- CREATE SCHEMA IF NOT EXISTS silver;

-- ===============================
-- SALES (Transaction Header)
-- ===============================
CREATE TABLE IF NOT EXISTS sales (

    sales_id                BIGSERIAL PRIMARY KEY,

    transaction_id          VARCHAR(50) UNIQUE,
    invoice_number          VARCHAR(100),

    order_status            VARCHAR(50),

    transaction_timestamp   TIMESTAMP,
    transaction_date        DATE,
    transaction_time        TIME,
    payment_timestamp       TIMESTAMP,

    day_of_week             VARCHAR(20),
    week_number             INT,
    month                   VARCHAR(20),
    quarter                 VARCHAR(10),
    fiscal_year             INT,

    store_id                INT,
    counter_id              INT,
    customer_id             INT,

    sales_channel           VARCHAR(50),

    total_line_items        INT,
    total_quantity          INT,

    subtotal                NUMERIC(12,2),
    total_txn_discount      NUMERIC(12,2),

    tax_amount              NUMERIC(12,2),
    gross_amount            NUMERIC(12,2),

    loyalty_discount        NUMERIC(12,2),
    final_amount            NUMERIC(12,2),

    amount_paid             NUMERIC(12,2),
    change_returned         NUMERIC(12,2),

    currency                VARCHAR(10),

    created_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===============================
-- SALES ITEMS (Product Line Items)
-- ===============================
CREATE TABLE IF NOT EXISTS sales_items (

    sales_item_id           BIGSERIAL PRIMARY KEY,

    transaction_id          VARCHAR(50),

    line_number             INT,

    product_id              INT,
    sku                     VARCHAR(100),
    product_name            VARCHAR(200),

    brand_id                INT,
    brand_name              VARCHAR(200),

    category_id             INT,
    category_name           VARCHAR(200),

    subcategory_id          INT,
    subcategory_name        VARCHAR(200),

    quantity                INT,

    original_price          NUMERIC(12,2),
    sale_price              NUMERIC(12,2),

    txn_discount_type       VARCHAR(50),
    txn_discount_pct        NUMERIC(6,2),

    txn_discount_per_unit   NUMERIC(12,2),
    net_unit_price          NUMERIC(12,2),

    line_subtotal           NUMERIC(12,2),
    line_txn_discount       NUMERIC(12,2),
    line_total              NUMERIC(12,2),

    mrp_saving              NUMERIC(12,2),

    created_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===============================
-- CUSTOMERS
-- ===============================
CREATE TABLE IF NOT EXISTS customers (

    customer_id             INT PRIMARY KEY,

    first_name              VARCHAR(100),
    last_name               VARCHAR(100),

    email                   VARCHAR(200),
    phone                   VARCHAR(50),

    city                    VARCHAR(100),
    state                   VARCHAR(100),
    country                 VARCHAR(100),

    postal_code             VARCHAR(20),

    customer_segment        VARCHAR(50),

    loyalty_id              VARCHAR(100),
    loyalty_tier            VARCHAR(50),

    created_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===============================
-- STORES
-- ===============================
CREATE TABLE IF NOT EXISTS stores (

    store_id                INT PRIMARY KEY,

    store_name              VARCHAR(200),
    store_type              VARCHAR(50),

    city                    VARCHAR(100),
    state                   VARCHAR(100),
    country                 VARCHAR(100),

    opening_date            DATE,

    created_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===============================
-- BILLING COUNTERS
-- ===============================
CREATE TABLE IF NOT EXISTS billing_counters (

    counter_id              INT PRIMARY KEY,

    store_id                INT,

    counter_number          VARCHAR(50),
    terminal_id             VARCHAR(50),

    is_active               BOOLEAN,

    created_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===============================
-- PAYMENTS
-- ===============================
CREATE TABLE IF NOT EXISTS payments (

    payment_id              VARCHAR(100) PRIMARY KEY,

    transaction_id          VARCHAR(50),

    payment_method_id       INT,

    method                  VARCHAR(50),
    provider                VARCHAR(100),

    gateway                 VARCHAR(100),

    payment_status          VARCHAR(50),

    amount_paid             NUMERIC(12,2),
    change_given            NUMERIC(12,2),

    transaction_ref         VARCHAR(200),

    currency                VARCHAR(10),

    created_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===============================
-- RETURNS
-- ===============================
CREATE TABLE IF NOT EXISTS returned (

    return_id               BIGSERIAL PRIMARY KEY,

    transaction_id          VARCHAR(50),

    return_reason           VARCHAR(200),
    return_date             DATE,

    refund_amount           NUMERIC(12,2),

    refund_status           VARCHAR(50),

    created_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===============================
-- STOCK MOVEMENTS (Inventory)
-- ===============================
CREATE TABLE IF NOT EXISTS stock_movements (

    movement_id             BIGSERIAL PRIMARY KEY,

    product_id              INT,
    store_id                INT,

    transaction_id          VARCHAR(50),

    movement_type           VARCHAR(50),

    quantity_change         INT,

    available_quantity      INT,

    movement_timestamp      TIMESTAMP,

    sale_date               DATE,

    reference_type          VARCHAR(50),

    reference_id            VARCHAR(100),

    created_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);