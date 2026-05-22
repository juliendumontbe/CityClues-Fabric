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

# CELL ********************

# Supprime la table et les données
spark.sql("DROP TABLE IF EXISTS lh_bronze.Game_event_raw_simulated")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
