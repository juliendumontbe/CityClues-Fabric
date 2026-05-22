[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared Game_event_raw_real = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "d9bd2de4-97a5-4cbe-80f4-5e4d4fb42b70"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "dc3ad09d-93e7-41a0-8301-c0f8ec6cb84e"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "Game_event_raw_real", ItemKind = "Table"]}[Data],
  #"Renamed columns" = Table.RenameColumns(#"Navigation 2", {{"payload_hint_stage", "hint_stage"}, {"payload_response_time_sec", "response_time_sec"}, {"payload_session_result", "session_result"}, {"payload_difficulty_at_start", "difficulty_at_start"}, {"payload_is_correct", "is_correct"}, {"payload_guess_text", "guess_text"}}),
  #"Reordered columns" = Table.ReorderColumns(#"Renamed columns", {"firestore_doc_id", "event_source", "is_simulated", "session_id", "city_id", "event_id", "event_sequence", "event_ts", "event_type", "hint_stage", "hint_id", "response_time_sec", "session_result", "difficulty_at_start", "is_correct", "guess_text"})
in
  #"Reordered columns";
shared Game_event_raw_simulated = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "d9bd2de4-97a5-4cbe-80f4-5e4d4fb42b70"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "dc3ad09d-93e7-41a0-8301-c0f8ec6cb84e"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "Game_event_raw_simulated", ItemKind = "Table"]}[Data],
  #"Renamed columns" = Table.RenameColumns(#"Navigation 2", {{"payload_hint_stage", "hint_stage"}, {"payload_response_time_sec", "response_time_sec"}, {"payload_session_result", "session_result"}, {"payload_difficulty_at_start", "difficulty_at_start"}, {"payload_is_correct", "is_correct"}, {"payload_guess_text", "guess_text"}}),
  #"Reordered columns" = Table.ReorderColumns(#"Renamed columns", {"firestore_doc_id", "event_source", "is_simulated", "session_id", "city_id", "event_id", "event_sequence", "event_ts", "event_type", "hint_stage", "hint_id", "response_time_sec", "session_result", "difficulty_at_start", "is_correct", "guess_text"})
in
  #"Reordered columns";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Append_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Append = let
  Source = Table.Combine({Game_event_raw_simulated, Game_event_raw_real})
in
  Source;
shared Append_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "033093b9-ab6e-4de5-8f71-92e3f1cfc945"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "efc71201-3a98-41b9-81f4-1235d7f9d37b"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "Game_event_clean", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
