import os
import snowflake.connector

SNOWFLAKE_ACCOUNT = os.getenv("SNOWFLAKE_ACCOUNT")
SNOWFLAKE_USER = os.getenv("SNOWFLAKE_USER")
SNOWFLAKE_PASSWORD = os.getenv("SNOWFLAKE_PASSWORD")

# List of SQL files in sequential execution order
SQL_FILES = [
    "snowflake/01_rbac_and_infra.sql",
    "snowflake/02_azure_integration.sql",
    "snowflake/03_bronze_ingestion.sql",
    "snowflake/04_transformations.sql",
    "snowflake/05_cdc_automation.sql"
]

def run_sql_scripts():
    print("Connecting to Snowflake...")
    conn = snowflake.connector.connect(
        user=SNOWFLAKE_USER,
        password=SNOWFLAKE_PASSWORD,
        account=SNOWFLAKE_ACCOUNT,
        role="ACCOUNTADMIN"
    )
    cursor = conn.cursor()

    for sql_file in SQL_FILES:
        print(f"--- Executing {sql_file} ---")
        if os.path.exists(sql_file):
            with open(sql_file, "r") as f:
                sql_content = f.read()
                # execute_string seamlessly handles multi-statement SQL scripts
                for cur in conn.execute_string(sql_content):
                    print(f"Executed statement: {cur.query[:60]}...")
        else:
            print(f"File not found: {sql_file}")

    conn.close()
    print("All Snowflake SQL scripts executed successfully!")

if __name__ == "__main__":
    run_sql_scripts()