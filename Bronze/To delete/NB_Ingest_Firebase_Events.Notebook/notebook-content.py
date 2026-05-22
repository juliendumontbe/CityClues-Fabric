# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {
# META     "lakehouse": {
# META       "default_lakehouse": "dc3ad09d-93e7-41a0-8301-c0f8ec6cb84e",
# META       "default_lakehouse_name": "lh_bronze",
# META       "default_lakehouse_workspace_id": "d9bd2de4-97a5-4cbe-80f4-5e4d4fb42b70",
# META       "known_lakehouses": [
# META         {
# META           "id": "dc3ad09d-93e7-41a0-8301-c0f8ec6cb84e"
# META         }
# META       ]
# META     }
# META   }
# META }

# MARKDOWN ********************

# #### Install

# CELL ********************

%pip install google-cloud-firestore

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# #### Setup - Firebase connection

# CELL ********************

from google.cloud import firestore
from google.oauth2 import service_account
import pandas as pd

SERVICE_ACCOUNT_PATH = "/lakehouse/default/Files/Secrets/firebase_service_account.json"
PROJECT_ID = "cityclues-game"
COLLECTION_NAME = "cityclues_events"

credentials = service_account.Credentials.from_service_account_file(
    SERVICE_ACCOUNT_PATH
)

db = firestore.Client(
    project=PROJECT_ID,
    credentials=credentials
)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# #### Read Firebase events

# CELL ********************

docs = db.collection(COLLECTION_NAME).stream()

rows = []

for doc in docs:
    data = doc.to_dict()
    payload = data.get("payload", {}) or {}

    rows.append({
        "firestore_doc_id": doc.id,
        "event_id": data.get("event_id"),
        "session_id": data.get("session_id"),
        "city_id": data.get("city_id"),
        "hint_id": data.get("hint_id"),
        "event_type": data.get("event_type"),
        "event_ts": data.get("event_ts"),
        "event_sequence": data.get("event_sequence"),
        "event_source": data.get("event_source"),
        "is_simulated": data.get("is_simulated"),
        "payload_difficulty_at_start": payload.get("difficulty_at_start"),
        "payload_response_time_sec": payload.get("response_time_sec"),
        "payload_hint_stage": payload.get("hint_stage"),
        "payload_guess_text": payload.get("guess_text"),
        "payload_is_correct": payload.get("is_correct"),
        "payload_session_result": payload.get("session_result")
    })

print(f"Firebase events read: {len(rows)}")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# #### Write Firebase events to lakehouse

# CELL ********************

if len(rows) == 0:
    raise Exception("No Firebase events found. Table not created.")

events_pd = pd.DataFrame(rows)

events_spark = spark.createDataFrame(events_pd)

events_spark.write \
    .format("delta") \
    .mode("overwrite") \
    .option("overwriteSchema", "true") \
    .saveAsTable("firebase_game_event_landing")

print("Table created successfully: firebase_game_event_landing")
print("Rows written:", events_spark.count())

display(spark.sql("SHOW TABLES"))

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
