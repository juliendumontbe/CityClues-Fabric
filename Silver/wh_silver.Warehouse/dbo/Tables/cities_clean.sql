CREATE TABLE [dbo].[cities_clean] (

	[city_id] varchar(8000) NULL, 
	[city_name] varchar(8000) NULL, 
	[country_code] varchar(8000) NULL, 
	[feature_code] varchar(8000) NULL, 
	[latitude] decimal(9,6) NULL, 
	[longitude] decimal(9,6) NULL, 
	[city_pop] int NULL, 
	[altitude] int NULL, 
	[timezone] varchar(8000) NULL, 
	[is_capital] int NOT NULL, 
	[hemisphere] varchar(19) NOT NULL, 
	[longitudinal_zone] varchar(18) NOT NULL, 
	[global_quadrant] varchar(10) NOT NULL, 
	[city_category] varchar(11) NOT NULL, 
	[city_first_letter] varchar(8) NULL, 
	[city_last_letter] varchar(8) NULL, 
	[city_name_length_category] varchar(11) NOT NULL, 
	[city_word_count_category] varchar(14) NOT NULL, 
	[altitude_category] varchar(7) NOT NULL
);