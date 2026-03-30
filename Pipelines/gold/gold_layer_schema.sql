
-- ===============================
-- DIM DATE
-- ===============================
CREATE TABLE IF NOT EXISTS gold.dim_date (
    date_key            INT PRIMARY KEY,  -- YYYYMMDD format
    full_date           DATE,
    day_of_week         VARCHAR(20),
    day_number          INT,
    week_number         INT,
    month_number        INT,
    month_name          VARCHAR(20),
    quarter             VARCHAR(10),
    fiscal_year         INT,
    is_weekend          BOOLEAN
);

-- ===============================
-- DIM CUSTOMER
-- ===============================
CREATE TABLE IF NOT EXISTS gold.dim_customer (
    customer_key        BIGSERIAL PRIMARY KEY,
    customer_id         INT,              -- NK from silver
    full_name           VARCHAR(200),
    email               VARCHAR(200),
    phone               VARCHAR(50),
    city                VARCHAR(100),
    state               VARCHAR(100),
    country             VARCHAR(100),
    postal_code         VARCHAR(20),
    customer_segment    VARCHAR(50),
    loyalty_id          VARCHAR(100),
    loyalty_tier        VARCHAR(50),
    created_at          TIMESTAMP
);

-- ===============================
-- DIM STORE
-- ===============================
CREATE TABLE IF NOT EXISTS gold.dim_store (
    store_key           BIGSERIAL PRIMARY KEY,
    store_id            INT,              -- NK from silver
    store_name          VARCHAR(200),
    store_type          VARCHAR(50),
    city                VARCHAR(100),
    state               VARCHAR(100),
    country             VARCHAR(100),
    opening_date        DATE
);

-- ===============================
-- DIM PRODUCT
-- ===============================
CREATE TABLE IF NOT EXISTS gold.dim_product (
    product_key         BIGSERIAL PRIMARY KEY,
    product_id          INT,              -- NK from silver
    sku                 VARCHAR(100),
    product_name        VARCHAR(200),
    brand_id            INT,
    brand_name          VARCHAR(200),
    category_id         INT,
    category_name       VARCHAR(200),
    subcategory_id      INT,
    subcategory_name    VARCHAR(200)
);

-- ===============================
-- DIM PAYMENT METHOD
-- ===============================
CREATE TABLE IF NOT EXISTS gold.dim_payment_method (
    payment_method_key  BIGSERIAL PRIMARY KEY,
    payment_method_id   INT,
    method              VARCHAR(50),
    provider            VARCHAR(100),
    gateway             VARCHAR(100)
);

-- ===============================
-- DIM SALES CHANNEL
-- ===============================
CREATE TABLE IF NOT EXISTS gold.dim_sales_channel (
    sales_channel_key   BIGSERIAL PRIMARY KEY,
    sales_channel       VARCHAR(50)
);



-- ===============================
-- FACT SALES (Transaction Grain)
-- ===============================
CREATE TABLE IF NOT EXISTS gold.fact_sales (
    fact_sales_id           BIGSERIAL PRIMARY KEY,

    -- Surrogate Keys (FK to dims)
    date_key                INT,          -- FK → dim_date
    customer_key            BIGINT,       -- FK → dim_customer
    store_key               BIGINT,       -- FK → dim_store
    sales_channel_key       BIGINT,       -- FK → dim_sales_channel

    -- Natural Keys (degenerate dims)
    transaction_id          VARCHAR(50),
    invoice_number          VARCHAR(100),
    order_status            VARCHAR(50),

    -- Time
    transaction_timestamp   TIMESTAMP,
    payment_timestamp       TIMESTAMP,

    -- Measures
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
-- FACT SALES ITEMS (Line Item Grain)
-- ===============================
CREATE TABLE IF NOT EXISTS gold.fact_sales_items (
    fact_sales_item_id      BIGSERIAL PRIMARY KEY,

    -- Surrogate Keys
    date_key                INT,          -- FK → dim_date
    product_key             BIGINT,       -- FK → dim_product
    store_key               BIGINT,       -- FK → dim_store
    customer_key            BIGINT,       -- FK → dim_customer

    -- Degenerate dims
    transaction_id          VARCHAR(50),
    line_number             INT,
    order_status            VARCHAR(50),
    txn_discount_type       VARCHAR(50),

    -- Measures
    quantity                INT,
    original_price          NUMERIC(12,2),
    sale_price              NUMERIC(12,2),
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
-- FACT PAYMENTS
-- ===============================
CREATE TABLE IF NOT EXISTS gold.fact_payments (
    fact_payment_id         BIGSERIAL PRIMARY KEY,

    -- Surrogate Keys
    date_key                INT,          -- FK → dim_date
    store_key               BIGINT,       -- FK → dim_store
    payment_method_key      BIGINT,       -- FK → dim_payment_method

    -- Degenerate dims
    payment_id              VARCHAR(100),
    transaction_id          VARCHAR(50),
    payment_status          VARCHAR(50),
    transaction_ref         VARCHAR(200),

    -- Measures
    amount_paid             NUMERIC(12,2),
    change_given            NUMERIC(12,2),

    currency                VARCHAR(10),
    created_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===============================
-- FACT RETURNS
-- ===============================
CREATE TABLE IF NOT EXISTS gold.fact_returns (
    fact_return_id          BIGSERIAL PRIMARY KEY,

    -- Surrogate Keys
    date_key                INT,          -- FK → dim_date
    customer_key            BIGINT,       -- FK → dim_customer
    store_key               BIGINT,       -- FK → dim_store

    -- Degenerate dims
    transaction_id          VARCHAR(50),
    return_reason           VARCHAR(200),
    refund_status           VARCHAR(50),

    -- Measures
    refund_amount           NUMERIC(12,2),

    created_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===============================
-- FACT INVENTORY (Stock Movement Grain)
-- ===============================
CREATE TABLE IF NOT EXISTS gold.fact_inventory (
    fact_inventory_id       BIGSERIAL PRIMARY KEY,

    -- Surrogate Keys
    date_key                INT,          -- FK → dim_date
    product_key             BIGINT,       -- FK → dim_product
    store_key               BIGINT,       -- FK → dim_store

    -- Degenerate dims
    movement_type           VARCHAR(50),
    reference_type          VARCHAR(50),
    reference_id            VARCHAR(100),
    transaction_id          VARCHAR(50),

    -- Measures
    quantity_change         INT,
    available_quantity      INT,

    movement_timestamp      TIMESTAMP,
    created_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- ===============================
-- AGG: Daily Sales by Store
-- ===============================
CREATE TABLE IF NOT EXISTS gold.agg_daily_sales_by_store (
    date_key                INT,
    store_key               BIGINT,
    store_name              VARCHAR(200),
    total_transactions      INT,
    total_quantity          INT,
    total_gross_amount      NUMERIC(14,2),
    total_discount          NUMERIC(14,2),
    total_tax               NUMERIC(14,2),
    total_final_amount      NUMERIC(14,2),
    avg_basket_value        NUMERIC(12,2),
    PRIMARY KEY (date_key, store_key)
);

-- ===============================
-- AGG: Monthly Sales by Category
-- ===============================
CREATE TABLE IF NOT EXISTS gold.agg_monthly_sales_by_category (
    year_month              VARCHAR(7),   -- 'YYYY-MM'
    category_id             INT,
    category_name           VARCHAR(200),
    total_quantity          INT,
    total_revenue           NUMERIC(14,2),
    total_discount          NUMERIC(14,2),
    total_mrp_saving        NUMERIC(14,2),
    avg_selling_price       NUMERIC(12,2),
    PRIMARY KEY (year_month, category_id)
);

-- ===============================
-- AGG: Customer Purchase Summary
-- ===============================
CREATE TABLE IF NOT EXISTS gold.agg_customer_summary (
    customer_key            BIGINT PRIMARY KEY,
    customer_id             INT,
    customer_segment        VARCHAR(50),
    loyalty_tier            VARCHAR(50),
    total_orders            INT,
    total_quantity          INT,
    total_spend             NUMERIC(14,2),
    total_discounts         NUMERIC(14,2),
    total_returns           INT,
    total_refunded          NUMERIC(14,2),
    avg_order_value         NUMERIC(12,2),
    first_purchase_date     DATE,
    last_purchase_date      DATE
);

-- ===============================
-- AGG: Product Performance
-- ===============================
CREATE TABLE IF NOT EXISTS gold.agg_product_performance (
    date_key                INT,
    product_key             BIGINT,
    product_name            VARCHAR(200),
    brand_name              VARCHAR(200),
    category_name           VARCHAR(200),
    subcategory_name        VARCHAR(200),
    total_quantity_sold     INT,
    total_revenue           NUMERIC(14,2),
    total_discount          NUMERIC(14,2),
    total_mrp_saving        NUMERIC(14,2),
    avg_net_price           NUMERIC(12,2),
    PRIMARY KEY (date_key, product_key)
);

-- ===============================
-- AGG: Payment Method Summary
-- ===============================
CREATE TABLE IF NOT EXISTS gold.agg_payment_method_summary (
    year_month              VARCHAR(7),
    payment_method_key      BIGINT,
    method                  VARCHAR(50),
    provider                VARCHAR(100),
    total_transactions      INT,
    total_amount_paid       NUMERIC(14,2),
    PRIMARY KEY (year_month, payment_method_key)
);

-- ===============================
-- AGG: Sales Channel Performance
-- ===============================
CREATE TABLE IF NOT EXISTS gold.agg_sales_channel_performance (
    date_key                INT,
    sales_channel           VARCHAR(50),
    total_transactions      INT,
    total_quantity          INT,
    total_revenue           NUMERIC(14,2),
    total_discount          NUMERIC(14,2),
    avg_basket_value        NUMERIC(12,2),
    PRIMARY KEY (date_key, sales_channel)
);

-- ===============================
-- AGG: Inventory Snapshot by Store
-- ===============================
CREATE TABLE IF NOT EXISTS gold.agg_inventory_snapshot (
    snapshot_date           DATE,
    product_key             BIGINT,
    store_key               BIGINT,
    available_quantity      INT,
    total_sold              INT,
    total_returned          INT,
    PRIMARY KEY (snapshot_date, product_key, store_key)
);