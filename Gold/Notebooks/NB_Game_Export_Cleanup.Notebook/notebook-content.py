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

spark.sql("DROP TABLE IF EXISTS city_game_context_export")
spark.sql("DROP TABLE IF EXISTS dim_hint_export")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
