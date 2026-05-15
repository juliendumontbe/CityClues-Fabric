[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Game_event_raw_simulated_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Game_event_raw_simulated = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "033093b9-ab6e-4de5-8f71-92e3f1cfc945"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "efc71201-3a98-41b9-81f4-1235d7f9d37b"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "Game_event_raw", ItemKind = "Table"]}[Data],
  #"Renamed columns" = Table.RenameColumns(#"Navigation 2", {{"payload.difficulty_at_start", "difficulty_at_start"}, {"payload.response_time_sec", "response_time_sec"}, {"payload.hint_stage", "hint_stage"}, {"payload.guess_text", "guess_text"}, {"payload.is_correct", "is_correct"}, {"payload.session_result", "session_result"}}),
  #"Reordered columns" = Table.ReorderColumns(#"Renamed columns", {"event_id", "session_id", "city_id", "hint_id", "event_type", "guess_text", "is_correct", "response_time_sec", "difficulty_at_start", "event_ts", "event_sequence", "hint_stage", "session_result"}),
  #"Reordered columns 1" = Table.ReorderColumns(#"Reordered columns", {"event_id", "session_id", "city_id", "hint_id", "event_type", "guess_text", "is_correct", "response_time_sec", "event_ts", "event_sequence", "session_result", "hint_stage"}),
  #"Added custom" = Table.AddColumn(#"Reordered columns 1", "event_source", each "simulated_generator"),
  #"Added custom 1" = Table.AddColumn(#"Added custom", "is_simulated", each true),
  #"Changed column type" = Table.TransformColumnTypes(#"Added custom 1", {{"event_source", type text}, {"is_simulated", type logical}})
in
  #"Changed column type";
shared Game_event_raw_simulated_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = null, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "033093b9-ab6e-4de5-8f71-92e3f1cfc945"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "efc71201-3a98-41b9-81f4-1235d7f9d37b"]}[Data],
  TableNavigation = Navigation_2{[Id = "Game_event_clean", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
