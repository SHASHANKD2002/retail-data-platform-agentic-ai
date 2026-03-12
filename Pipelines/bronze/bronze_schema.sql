-- Create Bronze Schema
CREATE SCHEMA IF NOT EXISTS bronze;

--==============================================
    --  Transaction schema 

-- ===================================


CREATE TABLE IF NOT EXISTS billing_transactions (

    -- Event Metadata
    event_type              VARCHAR(50),
    event_version           VARCHAR(10),
    generated_at            TIMESTAMP,

    -- Transaction Identifiers
    transaction_id          VARCHAR(50) PRIMARY KEY,
    invoice_number          VARCHAR(100),
    order_status            VARCHAR(50),

    -- Return Info (JSON)
    return_info             JSONB,

    -- Store Information
    store                   JSONB,

    -- Billing Counter Info
    billing_counter         JSONB,

    -- Sales Channel
    sales_channel           VARCHAR(50),

    -- Transaction Time Details
    transaction_timestamp   TIMESTAMP,
    transaction_date        DATE,
    transaction_time        TIME,
    payment_timestamp       TIMESTAMP,

    -- Calendar Dimensions
    day_of_week             VARCHAR(20),
    week_number             INT,
    month                   VARCHAR(20),
    quarter                 VARCHAR(5),
    fiscal_year             INT,

    -- Customer Details
    customer                JSONB,

    -- Line Items (Array of products)
    items                   JSONB,

    -- Payment Details
    payment                 JSONB,

    -- Billing Summary
    billing_summary         JSONB,

    -- Data Mart Flattened Row
    data_mart               JSONB,

    created_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);



-- =====================================================
-- 1. PIPELINE RUN AUDIT  (One record per pipeline run)
-- =====================================================

CREATE TABLE IF NOT EXISTS bronze_etl_audit.pipeline_run_audit (

    run_id              BIGSERIAL PRIMARY KEY,

    pipeline_name       VARCHAR(100) NOT NULL,
    source_system       VARCHAR(100),

    run_date            DATE DEFAULT CURRENT_DATE,

    start_time          TIMESTAMP,
    end_time            TIMESTAMP,

    status              VARCHAR(20),   -- RUNNING / SUCCESS / FAILED

    files_processed     INT DEFAULT 0,
    total_records       BIGINT DEFAULT 0,

    error_message       TEXT,

    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);



-- =====================================================
-- 2. FILE LOAD AUDIT  (One record per file processed)
-- =====================================================

CREATE TABLE IF NOT EXISTS bronze_etl_audit.file_load_audit (

    file_audit_id       BIGSERIAL PRIMARY KEY,

    run_id              BIGINT,

    file_name           VARCHAR(500),
    s3_path             VARCHAR(1000),

    file_date           DATE,

    records_loaded      BIGINT DEFAULT 0,

    load_status         VARCHAR(20),   -- SUCCESS / FAILED

    error_message       TEXT,

    load_start_time     TIMESTAMP,
    load_end_time       TIMESTAMP,

    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_pipeline_run
    FOREIGN KEY (run_id)
    REFERENCES bronze.pipeline_run_audit(run_id)
);



-- =====================================================
-- Indexes (recommended for performance)
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_pipeline_run_date
ON bronze_etl_audit.pipeline_run_audit(run_date);

CREATE INDEX IF NOT EXISTS idx_file_run_id
ON bronze_etl_audit.file_load_audit(run_id);

CREATE INDEX IF NOT EXISTS idx_file_date
ON bronzbronze_etl_audite.file_load_audit(file_date);