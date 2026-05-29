CREATE TABLE [dbo].[dim_calendar] (

	[date_key] int NOT NULL, 
	[full_date] date NOT NULL, 
	[year] int NOT NULL, 
	[month] int NOT NULL, 
	[month_name] varchar(20) NOT NULL, 
	[quarter] int NOT NULL, 
	[week_of_year] int NOT NULL, 
	[day_of_month] int NOT NULL, 
	[day_name] varchar(20) NOT NULL, 
	[is_weekend] bit NOT NULL
);