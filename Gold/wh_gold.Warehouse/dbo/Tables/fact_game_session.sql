CREATE TABLE [dbo].[fact_game_session] (

	[session_id] varchar(8000) NULL, 
	[city_id] bigint NULL, 
	[session_date_key] varchar(8000) NULL, 
	[session_duration_sec] int NULL, 
	[session_result] varchar(8000) NULL, 
	[is_success] bigint NULL, 
	[is_failed] bigint NULL, 
	[is_abandoned] bigint NULL, 
	[nb_hints_requested] int NULL, 
	[nb_hints_shown] int NULL, 
	[nb_guesses] bigint NULL, 
	[avg_response_time_sec] float NULL, 
	[max_hint_stage_reached] bigint NULL, 
	[event_source] varchar(8000) NULL, 
	[is_simulated] bit NULL
);