CREATE TABLE [dbo].[city_difficulty_history] (

	[city_id] bigint NOT NULL, 
	[calculation_ts] datetime2(6) NOT NULL, 
	[calculation_date] date NOT NULL, 
	[difficulty_initial] decimal(10,4) NULL, 
	[difficulty_real] decimal(10,4) NULL, 
	[difficulty_score] decimal(10,4) NULL, 
	[nb_sessions] int NULL, 
	[event_source] varchar(50) NULL, 
	[is_simulated] bit NULL
);