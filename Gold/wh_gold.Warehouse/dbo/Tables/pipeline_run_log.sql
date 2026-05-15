CREATE TABLE [dbo].[pipeline_run_log] (

	[log_id] uniqueidentifier NULL, 
	[run_id] uniqueidentifier NULL, 
	[pipeline_name] varchar(255) NULL, 
	[pipeline_step] varchar(255) NULL, 
	[layer_name] varchar(50) NULL, 
	[status] varchar(50) NULL, 
	[start_time] datetime2(6) NULL, 
	[end_time] datetime2(6) NULL, 
	[duration_seconds] int NULL, 
	[rows_inserted] bigint NULL, 
	[error_message] varchar(1000) NULL, 
	[run_date] date NULL
);