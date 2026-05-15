[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "dim_hint_DataDestination", IsNewTarget = true], Settings = [Kind = "Manual", AllowCreation = true, ColumnSettings = [Mappings = {[SourceColumnName = "hint_id", DestinationColumnName = "hint_id"], [SourceColumnName = "hint_stage", DestinationColumnName = "hint_stage"], [SourceColumnName = "hint_priority", DestinationColumnName = "hint_priority"], [SourceColumnName = "hint_type", DestinationColumnName = "hint_type"], [SourceColumnName = "hint_label", DestinationColumnName = "hint_label"], [SourceColumnName = "hint_description", DestinationColumnName = "hint_description"], [SourceColumnName = "hint_template", DestinationColumnName = "hint_template"], [SourceColumnName = "hint_category", DestinationColumnName = "hint_category"], [SourceColumnName = "is_dynamic", DestinationColumnName = "is_dynamic"], [SourceColumnName = "is_active", DestinationColumnName = "is_active"], [SourceColumnName = "source_table", DestinationColumnName = "source_table"], [SourceColumnName = "source_field", DestinationColumnName = "source_field"]}], DynamicSchema = false, UpdateMethod = [Kind = "Replace"], TypeSettings = [Kind = "Table"]]]}]
shared dim_hint = let
  Source = Fabric.Warehouse(null),
  Navigation = Source{[workspaceId = "033093b9-ab6e-4de5-8f71-92e3f1cfc945"]}[Data],
  #"Navigation 1" = Navigation{[warehouseId = "db2942b9-4c6e-43a8-974b-ded16abfd378"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Schema = "dbo", Item = "dim_hint"]}[Data]
in
  #"Navigation 2";
shared dim_hint_DataDestination = let
  Pattern = Fabric.Warehouse([CreateNavigationProperties = false, HierarchicalNavigation = null]),
  Navigation_1 = Pattern{[workspaceId = "."]}[Data],
  Navigation_2 = Navigation_1{[displayName = "wh_gold"]}[Data],
  TableNavigation = Navigation_2{[Item = "dim_hint_gold", Schema = "dbo"]}?[Data]?
in
  TableNavigation;
