CREATE TABLE [dbo].[city_difficulty] (

	[city_id] bigint NULL, 
	[nb_sessions] int NULL, 
	[difficulty_level] bigint NULL, 
	[difficulty_initial] float NULL, 
	[difficulty_real] float NULL, 
	[difficulty_score] float NULL, 
	[event_source] varchar(8000) NULL, 
	[is_simulated] bit NULL
);