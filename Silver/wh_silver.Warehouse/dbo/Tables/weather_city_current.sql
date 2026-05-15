CREATE TABLE [dbo].[weather_city_current] (

	[city_id] bigint NULL, 
	[weather_api_city_id] bigint NULL, 
	[humidity] bigint NULL, 
	[temperature] float NULL, 
	[weather_type] varchar(8000) NULL, 
	[timezone_offset_sec] bigint NULL, 
	[weather_timestamp] datetime2(6) NULL, 
	[ingestion_timestamp] datetime2(6) NULL
);