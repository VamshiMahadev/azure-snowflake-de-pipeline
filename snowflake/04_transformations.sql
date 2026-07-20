-- =====================================================================
-- 04. SILVER LAYER: STRUCTURAL FLATTENING & CLEANING
-- =====================================================================
USE ROLE DE_ETL_ROLE;
USE WAREHOUSE DE_COMPUTE_WH;
USE DATABASE OPEN_SOURCE_DB;
USE SCHEMA SILVER_STAGING;

-- Create Flattened View over Bronze Raw payload handling both arrays and objects
CREATE OR REPLACE VIEW VW_CLEAN_BREWERIES AS
SELECT
    COALESCE(f.value:id::STRING, b.RAW_PAYLOAD:id::STRING)             AS BREWERY_ID,
    COALESCE(f.value:name::STRING, b.RAW_PAYLOAD:name::STRING)           AS BREWERY_NAME,
    COALESCE(f.value:brewery_type::STRING, b.RAW_PAYLOAD:brewery_type::STRING)   AS BREWERY_TYPE,
    COALESCE(f.value:street::STRING, b.RAW_PAYLOAD:street::STRING)         AS STREET_ADDRESS,
    COALESCE(f.value:city::STRING, b.RAW_PAYLOAD:city::STRING)           AS CITY,
    COALESCE(f.value:state_province::STRING, b.RAW_PAYLOAD:state_province::STRING) AS STATE_PROVINCE,
    COALESCE(f.value:postal_code::STRING, b.RAW_PAYLOAD:postal_code::STRING)    AS POSTAL_CODE,
    COALESCE(f.value:country::STRING, b.RAW_PAYLOAD:country::STRING)        AS COUNTRY,
    COALESCE(f.value:longitude::NUMBER(10,7), b.RAW_PAYLOAD:longitude::NUMBER(10,7)) AS LONGITUDE,
    COALESCE(f.value:latitude::NUMBER(10,7), b.RAW_PAYLOAD:latitude::NUMBER(10,7))  AS LATITUDE,
    COALESCE(f.value:phone::STRING, b.RAW_PAYLOAD:phone::STRING)          AS PHONE,
    COALESCE(f.value:website_url::STRING, b.RAW_PAYLOAD:website_url::STRING)    AS WEBSITE_URL,
    b.INGESTION_TIMESTAMP
FROM OPEN_SOURCE_DB.BRONZE_RAW.RAW_BREWERIES b,
LATERAL FLATTEN(input => b.RAW_PAYLOAD, outer => true) f;

-- Create Persisted Silver Table
CREATE TABLE IF NOT EXISTS DIM_BREWERIES LIKE VW_CLEAN_BREWERIES;

-- Insert Data Into Silver Table
INSERT INTO DIM_BREWERIES
SELECT * FROM VW_CLEAN_BREWERIES
WHERE BREWERY_ID IS NOT NULL;

-- =====================================================================
-- 05. GOLD LAYER: BUSINESS AGGREGATIONS
-- =====================================================================
USE SCHEMA OPEN_SOURCE_DB.GOLD_ANALYTICS;

-- Aggregate: Brewery Count per State & Type
CREATE OR REPLACE TABLE FACT_BREWERY_SUMMARY_BY_STATE AS
SELECT
    COUNTRY,
    STATE_PROVINCE,
    BREWERY_TYPE,
    COUNT(DISTINCT BREWERY_ID) AS TOTAL_BREWERIES,
    CURRENT_TIMESTAMP()        AS AGGREGATED_AT
FROM OPEN_SOURCE_DB.SILVER_STAGING.DIM_BREWERIES
GROUP BY 1, 2, 3;