# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {
# META     "lakehouse": {
# META       "default_lakehouse": "8c839497-fa14-48b6-8342-2d6b4f335b1f",
# META       "default_lakehouse_name": "lh_game_export",
# META       "default_lakehouse_workspace_id": "e0a788ba-e0d8-4649-9eb4-89f26d881a53",
# META       "known_lakehouses": [
# META         {
# META           "id": "8c839497-fa14-48b6-8342-2d6b4f335b1f"
# META         }
# META       ]
# META     }
# META   }
# META }

# CELL ********************

# Welcome to your new notebook
# Type here in the cell editor to add code!


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# #### Set up

# CELL ********************

import os

EXPORT_PATH = "/lakehouse/default/Files/cityclues_export"
os.makedirs(EXPORT_PATH, exist_ok=True)

cities_df = spark.read.table("city_game_context_export")
hints_df = spark.read.table("dim_hint_export")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# #### Create files

# CELL ********************

import json
import pandas as pd

def lower_columns(df):
    for col in df.columns:
        df = df.withColumnRenamed(col, col.lower())
    return df

cities_df = lower_columns(cities_df)
hints_df = lower_columns(hints_df)

cities_pd = cities_df.toPandas()
hints_pd = (
    hints_df
    .filter("is_active = 1")
    .orderBy("hint_stage", "hint_priority")
    .toPandas()
)

cities_json = cities_pd.to_json(
    orient="records",
    indent=2,
    force_ascii=False,
    date_format="iso"
)

hints_json = hints_pd.to_json(
    orient="records",
    indent=2,
    force_ascii=False
)

with open(f"{EXPORT_PATH}/cities.json", "w", encoding="utf-8") as f:
    f.write(cities_json)

with open(f"{EXPORT_PATH}/hints.json", "w", encoding="utf-8") as f:
    f.write(hints_json)

print(f"cities.json created: {len(cities_pd)} rows")
print(f"hints.json created: {len(hints_pd)} rows")
print(f"Export path: {EXPORT_PATH}")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# MARKDOWN ********************

# #### Control step

# CELL ********************

import json

with open(f"{EXPORT_PATH}/cities.json", "r", encoding="utf-8") as f:
    cities_check = json.load(f)

with open(f"{EXPORT_PATH}/hints.json", "r", encoding="utf-8") as f:
    hints_check = json.load(f)

print("=== CITIES SAMPLE ===")
print(json.dumps(cities_check[0], indent=2, ensure_ascii=False))

print("\n=== HINTS SAMPLE ===")
print(json.dumps(hints_check[0], indent=2, ensure_ascii=False))

print("\n=== COUNTS ===")
print("Cities:", len(cities_check))
print("Hints:", len(hints_check))

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

hints_df.filter("hint_id = 17").show(truncate=False)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
