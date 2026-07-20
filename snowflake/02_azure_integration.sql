-- =====================================================================
-- 02. AZURE BLOB STORAGE INTEGRATION & EXTERNAL STAGE
-- =====================================================================
USE ROLE ACCOUNTADMIN;

-- Create Storage Integration pointing to Azure Blob Container
CREATE OR REPLACE STORAGE INTEGRATION AZURE_BLOB_INT
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = 'AZURE'
    ENABLED = TRUE
    AZURE_TENANT_ID = 'b1362067-4ff1-4d5c-a968-6ad37f3732b1'
    STORAGE_ALLOWED_LOCATIONS = ('azure://azuredeblob.blob.core.windows.net/raw-data/');

-- Grant Usage on Integration to ETL Role
GRANT USAGE ON INTEGRATION AZURE_BLOB_INT TO ROLE DE_ETL_ROLE;

-- IMPORTANT STEP FOR AZURE AD AUTHENTICATION:
-- Execute the following command and copy AZURE_CONSENT_URL to authorize Snowflake in your Azure Portal.
DESC INTEGRATION AZURE_BLOB_INT;

-- Switch to ETL Role to create stage and ingestion objects
USE ROLE DE_ETL_ROLE;
USE WAREHOUSE DE_COMPUTE_WH;
USE DATABASE OPEN_SOURCE_DB;
USE SCHEMA BRONZE_RAW;

-- Create File Format for JSON and Parquet
CREATE OR REPLACE FILE FORMAT FF_JSON
    TYPE = 'JSON'
    STRIP_OUTER_ARRAY = TRUE
    IGNORE_UTF8_ERRORS = TRUE;

CREATE OR REPLACE FILE FORMAT FF_PARQUET
    TYPE = 'PARQUET';

-- Create External Stage pointing to Azure Storage
CREATE OR REPLACE STAGE STG_AZURE_RAW_BLOB
    STORAGE_INTEGRATION = AZURE_BLOB_INT
    URL = 'azure://azuredeblob.blob.core.windows.net/raw-data/'
    FILE_FORMAT = FF_JSON;