import pandas as pd
from sqlalchemy import create_engine, text

# ==============================================================================
# 1. SETUP MYSQL DATABASE CONNECTION
# ==============================================================================
DB_USER = 'root'           
DB_PASSWORD = '<YOUR_PASSWORD>' 
DB_HOST = 'localhost'      
DB_PORT = '3306'           
DB_NAME = 'e_redes'        

# First, connect to MySQL server without database to create the database if it doesn't exist
print(f"Checking if database '{DB_NAME}' exists...")
try:
    server_connection_string = f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}"
    server_engine = create_engine(server_connection_string)
    with server_engine.connect() as conn:
        conn.execute(text(f"CREATE DATABASE IF NOT EXISTS {DB_NAME}"))
        conn.commit()
    print(f"Database '{DB_NAME}' is ready.")
except Exception as e:
    print(f"Error creating database: {e}")
    raise

# Now connect to the database
connection_string = f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
engine = create_engine(connection_string)

print(f"Connecting to MySQL database '{DB_NAME}'...")

# ==============================================================================
# 2. LOAD DIMENSIONS 
# ==============================================================================
print("Loading Dimensions...")
dims = pd.read_excel("DIMENSIONS_OUTPUT.xlsx", sheet_name=None)


dims['Dim_Date'].to_sql('dim_date', engine, if_exists='append', index=False)
dims['Dim_Voltage_Level'].to_sql('dim_voltage_level', engine, if_exists='append', index=False)
dims['Dim_Voltage_Class'].to_sql('dim_voltage_class', engine, if_exists='append', index=False)
dims['Dim_Exceptional_Event'].to_sql('dim_exceptional_event', engine, if_exists='append', index=False)
dims['Dim_Location'].to_sql('dim_location', engine, if_exists='append', index=False)
dims['Dim_Installation'].to_sql('dim_installation', engine, if_exists='append', index=False)

# ==============================================================================
# 3. LOAD FACTS AND AGGREGATES
# ==============================================================================
print("Loading Facts...")
facts = pd.read_excel("FACTS_OUTPUT.xlsx", sheet_name=None)

# 1. Load Voltage Events
facts['fact_voltage_event'].to_sql('fact_voltage_event', engine, if_exists='append', index=False)

# 2. Load Continuous Phenomena (Drop the extra column first)
fact_cont = facts['fact_continuous_phen']
if 'voltage_class_id' in fact_cont.columns:
    fact_cont = fact_cont.drop(columns=['voltage_class_id'])
fact_cont.to_sql('fact_continuous_phenomena', engine, if_exists='append', index=False)

# 3. Load Aggregates
facts['agg_muni_voltage'].to_sql('agg_municipality_voltage_event', engine, if_exists='append', index=False)
facts['agg_muni_cont'].to_sql('agg_municipality_continuous_phenomena', engine, if_exists='append', index=False)

print("Data warehouse loaded.")
