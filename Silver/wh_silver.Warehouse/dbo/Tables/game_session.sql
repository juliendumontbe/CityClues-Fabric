CREATE TABLE [dbo].[game_session] (

	[session_id] varchar(50) NULL, 
	[city_id] bigint NULL, 
	[session_start_ts] datetime2(3) NULL, 
	[session_end_ts] datetime2(3) NULL, 
	[session_duration_sec] int NULL, 
	[session_status] varchar(20) NULL, 
	[session_result] varchar(20) NULL, 
	[difficulty_at_start] decimal(5,2) NULL, 
	[nb_hints_requested] int NULL, 
	[nb_hints_shown] int NULL, 
	[event_source] varchar(50) NULL, 
	[is_simulated] bit NULL
);