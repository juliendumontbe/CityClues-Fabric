CREATE TABLE [dbo].[dim_hint] (

	[hint_id] int NOT NULL, 
	[hint_stage] int NOT NULL, 
	[hint_priority] int NOT NULL, 
	[hint_type] varchar(100) NOT NULL, 
	[hint_label] varchar(255) NOT NULL, 
	[hint_description] varchar(500) NULL, 
	[hint_template] varchar(1000) NULL, 
	[hint_category] varchar(100) NULL, 
	[is_dynamic] bit NOT NULL, 
	[is_active] bit NOT NULL, 
	[source_table] varchar(100) NULL, 
	[source_field] varchar(100) NULL
);