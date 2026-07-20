import os
import requests
import json
from datetime import datetime
from azure.storage.blob import BlobServiceClient
import snowflake.connector

# Environment Secrets
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
    timestamp = datetime.utcnow().strftime("%Y-%m-%d_%H%M%S")
    blob_name = f"breweries/load_date={timestamp}/data.json"
    
    blob_service_client = BlobServiceClient.from_connection_string(AZURE_CONN_STR)
    blob_client = blob_service_client.get_blob_client(container=CONTAINER_NAME, blob=blob_name)
    
    json_bytes = json.dumps(data).encode('utf-8')
    blob_client.upload_blob(json_bytes, overwrite=True)
    print(f"Successfully uploaded raw data to Azure Blob: {blob_name}")
    return blob_name

def copy_into_snowflake(blob_name):
    """Run COPY INTO command in Snowflake from Azure Stage"""
    conn = snowflake.connector.connect(
        user=SNOWFLAKE_USER,
        password=SNOWFLAKE_PASSWORD,
        account=SNOWFLAKE_ACCOUNT,
        warehouse="COMPUTE_WH_DE",
        database="OPEN_SOURCE_DB",
        schema="INGESTION"
    )
    cursor = conn.cursor()
    
    copy_query = f"""
    COPY INTO OPEN_SOURCE_DB.INGESTION.RAW_BREWERIES(SRC_DATA, LOADED_AT)
    FROM (
        SELECT $1, CURRENT_TIMESTAMP()
        FROM @AZURE_BLOB_STAGE/{blob_name}
    )
    FILE_FORMAT = (TYPE = 'JSON');
    """
    
    cursor.execute(copy_query)
    print("Successfully copied data from Azure Stage to Snowflake RAW_BREWERIES table.")
    conn.close()

if __name__ == "__main__":
    raw_data = fetch_open_source_data()
    uploaded_blob = upload_to_azure_blob(raw_data)
    copy_into_snowflake(uploaded_blob)