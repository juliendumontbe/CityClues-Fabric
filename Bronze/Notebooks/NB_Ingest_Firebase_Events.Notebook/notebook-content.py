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

# #### Firebase Rest setup

# CELL ********************

import json
import time
import requests
import jwt
import pandas as pd

SERVICE_ACCOUNT_PATH = "/lakehouse/default/Files/Secrets/firebase_service_account.json"
PROJECT_ID = "cityclues-game"
COLLECTION_NAME = "cityclues_events"

with open(SERVICE_ACCOUNT_PATH, "r") as f:
    service_account = json.load(f)

now = int(time.time())

payload = {
    "iss": service_account["client_email"],
    "scope": "https://www.googleapis.com/auth/datastore",
    "aud": "https://oauth2.googleapis.com/token",
    "iat": now,
    "exp": now + 3600
}

signed_jwt = jwt.encode(
    payload,
    service_account["private_key"],
    algorithm="RS256"
)

token_response = requests.post(
    "https://oauth2.googleapis.com/token",
    data={
        "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
        "assertion": signed_jwt
    }
)

token_response.raise_for_status()

access_token = token_response.json()["access_token"]

headers = {
    "Authorization": f"Bearer {access_token}"
}

print("Google access token created.")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# #### Read Firebase events rest

# CELL ********************

url = (
    f"https://firestore.googleapis.com/v1/projects/"
    f"{PROJECT_ID}/databases/(default)/documents/{COLLECTION_NAME}"
)

events = []

while url:
    response = requests.get(url, headers=headers)
    response.raise_for_status()

    data = response.json()

    for doc in data.get("documents", []):
        fields = doc.get("fields", {})
        firestore_doc_id = doc["name"].split("/")[-1]

        def get_value(field_name):
            field = fields.get(field_name)

            if field is None:
                return None

            if "stringValue" in field:
                return field["stringValue"]

            if "integerValue" in field:
                return int(field["integerValue"])

            if "doubleValue" in field:
                return float(field["doubleValue"])

            if "booleanValue" in field:
                return bool(field["booleanValue"])

            if "nullValue" in field:
                return None

            return None

        payload_fields = fields.get("payload", {}).get("mapValue", {}).get("fields", {})

        def get_payload_value(field_name):
            field = payload_fields.get(field_name)

            if field is None:
                return None

            if "stringValue" in field:
                return field["stringValue"]

            if "integerValue" in field:
                return int(field["integerValue"])

            if "doubleValue" in field:
                return float(field["doubleValue"])

            if "booleanValue" in field:
                return bool(field["booleanValue"])

            if "nullValue" in field:
                return None

            return None

        events.append({
            "firestore_doc_id": firestore_doc_id,
            "event_id": get_value("event_id"),
            "session_id": get_value("session_id"),
            "city_id": get_value("city_id"),
            "hint_id": get_value("hint_id"),
            "event_type": get_value("event_type"),
            "event_ts": get_value("event_ts"),
            "event_sequence": get_value("event_sequence"),
            "event_source": get_value("event_source"),
            "is_simulated": get_value("is_simulated"),

            "payload_difficulty_at_start": get_payload_value("difficulty_at_start"),
            "payload_response_time_sec": get_payload_value("response_time_sec"),
            "payload_hint_stage": get_payload_value("hint_stage"),
            "payload_guess_text": get_payload_value("guess_text"),
            "payload_is_correct": get_payload_value("is_correct"),
            "payload_session_result": get_payload_value("session_result")
        })

    next_page_token = data.get("nextPageToken")

    if next_page_token:
        url = (
            f"https://firestore.googleapis.com/v1/projects/"
            f"{PROJECT_ID}/databases/(default)/documents/{COLLECTION_NAME}"
            f"?pageToken={next_page_token}"
        )
    else:
        url = None

print(f"Firebase events read: {len(events)}")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# #### Write Firebase Events to lakehouse

# CELL ********************

if len(events) == 0:
    raise Exception("No Firebase events found. Table not created.")

events_pd = pd.DataFrame(events)

events_spark = spark.createDataFrame(events_pd)

events_spark.write \
    .format("delta") \
    .mode("overwrite") \
    .option("overwriteSchema", "true") \
    .saveAsTable("firebase_game_event_landing")

print("Table created successfully: firebase_game_event_landing")
print("Rows written:", events_spark.count())

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# ###
