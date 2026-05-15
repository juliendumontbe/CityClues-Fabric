CREATE TABLE [dbo].[dim_city] (

	[city_id] bigint NULL, 
	[city_name] varchar(8000) NULL, 
	[country_code] varchar(8000) NULL, 
	[latitude] decimal(9,6) NULL, 
	[longitude] decimal(9,6) NULL, 
	[city_pop] int NULL, 
	[altitude_category] varchar(7) NOT NULL, 
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
	[coastal_distance] float NULL, 
	[coastal_distance_category] varchar(29) NULL, 
	[city_score] float NULL
);