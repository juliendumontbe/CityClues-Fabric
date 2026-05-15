CREATE TABLE [dbo].[cities_selection_gold] (

	[city_id] bigint NULL, 
	[city_name] varchar(8000) NULL, 
	[country_code] varchar(8000) NULL, 
	[latitude] decimal(9,6) NULL, 
	[longitude] decimal(9,6) NULL, 
	[city_pop] int NULL, 
	[is_capital] int NULL, 
	[city_score] float NULL, 
	[selection_source] varchar(15) NULL, 
	[difficulty_level] bigint NULL
);