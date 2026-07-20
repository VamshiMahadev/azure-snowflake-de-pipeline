-- =====================================================================
-- 03. BRONZE LAYER: RAW TABLE CREATION
-- =====================================================================
USE ROLE DE_ETL_ROLE;
USE DATABASE OPEN_SOURCE_DB;
USE SCHEMA BRONZE_RAW;

-- Internal Raw Ingestion Table
CREATE TABLE IF NOT EXISTS RAW_BREWERIES (
    RAW_PAYLOAD VARIANT,
    FILE_NAME STRING,
    INGESTION_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);