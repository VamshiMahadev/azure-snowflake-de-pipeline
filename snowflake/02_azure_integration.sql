-- =====================================================================
-- 02. FILE FORMATS & EXTERNAL STAGE
-- =====================================================================
USE ROLE DE_ETL_ROLE;
USE WAREHOUSE DE_COMPUTE_WH;
USE DATABASE OPEN_SOURCE_DB;
USE SCHEMA BRONZE_RAW;

-- Create File Formats
CREATE OR REPLACE FILE FORMAT FF_JSON
    TYPE = 'JSON'
    STRIP_OUTER_ARRAY = TRUE
    IGNORE_UTF8_ERRORS = TRUE;

CREATE OR REPLACE FILE FORMAT FF_PARQUET
    TYPE = 'PARQUET';

-- Create External Stage with dynamic Storage Account Name and Access Key
CREATE OR REPLACE STAGE STG_AZURE_RAW_BLOB
    URL = 'azure://<STORAGE_ACCOUNT_NAME>.blob.core.windows.net/raw-data/'
    CREDENTIALS = (AZURE_KEY = '<STORAGE_ACCOUNT_KEY>')
    FILE_FORMAT = FF_JSON;