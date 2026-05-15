CREATE TABLE [dbo].[hint_performance] (

	[hint_id] int NULL, 
	[hint_label] varchar(255) NULL, 
	[hint_stage] int NULL, 
	[total_requested] int NULL, 
	[total_shown] int NULL, 
	[avg_guesses_after_hint] decimal(10,2) NULL, 
	[success_after_hint_rate] decimal(10,4) NULL, 
	[event_source] varchar(50) NULL, 
	[is_simulated] bit NULL
);