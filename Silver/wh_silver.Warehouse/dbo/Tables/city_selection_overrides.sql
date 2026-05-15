CREATE TABLE [dbo].[city_selection_overrides] (

	[city_id] bigint NOT NULL, 
	[is_active] bit NOT NULL, 
	[override_reason] varchar(255) NULL, 
	[added_by] varchar(100) NULL, 
	[added_at] datetime2(6) NOT NULL
);