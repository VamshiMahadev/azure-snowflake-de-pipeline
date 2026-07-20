import os
import requests
import json
from datetime import datetime
from azure.storage.blob import BlobServiceClient
import snowflake.connector

# Environment Variables
AZURE_CONN_STR = os.getenv("AZURE_STORAGE_CONNECTION_STRING")
CONTAINER_NAME = "raw-data"

SNOWFLAKE_ACCOUNT = os.getenv("SNOWFLAKE_ACCOUNT")
SNOWFLAKE_USER = os.getenv("SNOWFLAKE_USER")
SNOWFLAKE_PASSWORD = os.getenv("SNOWFLAKE_PASSWORD")

def fetch_open_source_data():
    """Fetch public data from Open Brewery API"""
    url = "https://api.openbrewerydb.org/v1/breweries?per_page=50"
    response = requests.get(url)
    response.raise_for_status()
    return response.json()

def upload_to_azure_blob(data):
    """Upload raw JSON payload to Azure Blob Storage"""
    if not AZURE_CONN_STR:
        raise ValueError("AZURE_STORAGE_CONNECTION_STRING environment variable is missing or empty.")

    timestamp = datetime.utcnow().strftime("%Y-%m-%d_%H%M%S")
    blob_name = f"breweries/load_date={timestamp}/data.json"
    
    blob_service_client = BlobServiceClient.from_connection_string(AZURE_CONN_STR)
    blob_client = blob_service_client.get_blob_client(container=CONTAINER_NAME, blob=blob_name)
    
    json_bytes = json.dumps(data).encode('utf-8')
    blob_client.upload_blob(json_bytes, overwrite=True)
    print(f"Successfully uploaded raw data to Azure Blob: {blob_name}")
    return blob_name

def copy_into_snowflake(blob_name):
    """Run COPY INTO command in Snowflake Bronze schema from Azure Stage"""
    print("Connecting to Snowflake for COPY INTO execution...")
    conn = snowflake.connector.connect(
        user=SNOWFLAKE_USER,
        password=SNOWFLAKE_PASSWORD,
        account=SNOWFLAKE_ACCOUNT,
        warehouse="DE_COMPUTE_WH",
        database="OPEN_SOURCE_DB",
        schema="BRONZE_RAW",
        role="DE_ETL_ROLE"
    )
    cursor = conn.cursor()
    
    copy_query = f"""
    COPY INTO OPEN_SOURCE_DB.BRONZE_RAW.RAW_BREWERIES(RAW_PAYLOAD, FILE_NAME)
    FROM (
        SELECT $1, METADATA$FILENAME
        FROM @OPEN_SOURCE_DB.BRONZE_RAW.STG_AZURE_RAW_BLOB/{blob_name}
    )
    FILE_FORMAT = (FORMAT_NAME = 'OPEN_SOURCE_DB.BRONZE_RAW.FF_JSON')
    ON_ERROR = 'CONTINUE';
    """
    
    cursor.execute(copy_query)
    print("Successfully loaded raw JSON data into OPEN_SOURCE_DB.BRONZE_RAW.RAW_BREWERIES.")
    conn.close()

if __name__ == "__main__":
    raw_data = fetch_open_source_data()
    uploaded_blob = upload_to_azure_blob(raw_data)
    copy_into_snowflake(uploaded_blob)