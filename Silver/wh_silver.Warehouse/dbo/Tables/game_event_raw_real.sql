CREATE TABLE [dbo].[game_event_raw_real] (

	[firestore_doc_id] varchar(100) NULL, 
	[event_source] varchar(50) NULL, 
	[session_id] varchar(100) NULL, 
	[city_id] bigint NULL, 
	[is_simulated] int NULL, 
	[event_sequence] int NULL, 
	[event_ts] varchar(30) NULL, 
	[event_type] varchar(100) NULL, 
	[event_id] varchar(100) NULL, 
	[hint_id] bigint NULL, 
	[payload_guess_text] varchar(500) NULL, 
	[payload_is_correct] int NULL, 
	[payload_session_result] varchar(50) NULL, 
	[payload_hint_stage] int NULL, 
	[payload_response_time_sec] int NULL, 
	[payload_difficulty_at_start] decimal(10,3) NULL
);