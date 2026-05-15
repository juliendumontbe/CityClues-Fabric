CREATE TABLE [dbo].[dim_hint_gold] (

	[hint_id] int NULL, 
	[hint_stage] int NULL, 
	[hint_priority] int NULL, 
	[hint_type] varchar(8000) NULL, 
	[hint_label] varchar(8000) NULL, 
	[hint_description] varchar(8000) NULL, 
	[hint_template] varchar(8000) NULL, 
	[hint_category] varchar(8000) NULL, 
	[is_dynamic] bit NULL, 
	[is_active] bit NULL, 
	[source_table] varchar(8000) NULL, 
	[source_field] varchar(8000) NULL
);