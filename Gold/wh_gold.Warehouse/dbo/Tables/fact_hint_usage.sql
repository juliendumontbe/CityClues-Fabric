CREATE TABLE [dbo].[fact_hint_usage] (

	[session_id] varchar(8000) NULL, 
	[city_id] bigint NULL, 
	[hint_id] bigint NULL, 
	[hint_stage] bigint NULL, 
	[guesses_before_hint] bigint NULL, 
	[guesses_after_hint] bigint NULL, 
	[is_last_hint_before_success] bigint NULL, 
	[is_session_success] bigint NULL, 
	[session_date_key] bigint NULL, 
	[event_source] varchar(8000) NULL, 
	[is_simulated] bit NULL
);