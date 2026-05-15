CREATE TABLE [dbo].[dim_country] (

	[country_code] varchar(8000) NULL, 
	[country_id] varchar(8000) NULL, 
	[country_name] varchar(8000) NULL, 
	[capital] varchar(8000) NULL, 
	[country_area] int NULL, 
	[country_pop] bigint NULL, 
	[continent] varchar(13) NULL, 
	[currency_code] varchar(8000) NULL, 
	[currency_name] varchar(8000) NULL, 
	[languages] varchar(8000) NULL, 
	[neighbours] varchar(8000) NULL, 
	[country_density_category] varchar(9) NULL, 
	[languages_count] int NULL, 
	[neighbours_count] int NULL, 
	[country_category] varchar(17) NOT NULL
);