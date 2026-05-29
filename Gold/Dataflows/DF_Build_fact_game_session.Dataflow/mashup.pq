[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared Game_event_clean_base = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "033093b9-ab6e-4de5-8f71-92e3f1cfc945"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "efc71201-3a98-41b9-81f4-1235d7f9d37b"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "Game_event_clean", ItemKind = "Table"]}[Data],
  #"Sorted rows" = Table.Sort(#"Navigation 2", {{"session_id", Order.Ascending}})
in
  #"Sorted rows";
shared Q_session_start = let
  Source = Game_event_clean_base,
  #"Filtered rows" = Table.SelectRows(Source, each ([event_type] = "session_started")),
  #"Changed column type" = Table.TransformColumnTypes(#"Filtered rows", {{"event_ts", type datetime}}),
  #"Removed other columns" = Table.SelectColumns(#"Changed column type", {"session_id", "event_ts", "event_type"}),
  #"Added custom" = Table.AddColumn(#"Removed other columns", "session_date_key", each Int64.From(Date.ToText(DateTime.Date([event_ts]), "yyyyMMdd"))),
  #"Removed columns" = Table.RemoveColumns(#"Added custom", {"event_ts", "event_type"})
in
  #"Removed columns";
shared Q_nb_guesses = let
  Source = Game_event_clean_base,
  #"Filtered rows" = Table.SelectRows(Source, each ([event_type] = "guess_submitted")),
  #"Grouped rows" = Table.Group(#"Filtered rows", {"session_id"}, {{"nb_guesses", each Table.RowCount(_), Int64.Type}})
in
  #"Grouped rows";
shared Q_avg_response_time_sec = let
  Source = Game_event_clean_base,
  #"Filtered rows" = Table.SelectRows(Source, each ([event_type] = "guess_submitted")),
  #"Grouped rows" = Table.Group(#"Filtered rows", {"session_id"}, {{"avg_response_time_sec", each List.Average([response_time_sec]), type nullable number}})
in
  #"Grouped rows";
shared Q_max_hint_stage_reached = let
  Source = Game_event_clean_base,
  #"Grouped rows" = Table.Group(Source, {"session_id"}, {{"max_hint_stage_reached", each if List.Max([hint_stage]) = null then 0 else List.Max([hint_stage]), Int64.Type}}),
  #"Sorted rows" = Table.Sort(#"Grouped rows", {{"session_id", Order.Ascending}})
in
  #"Sorted rows";
shared Game_event_clean_final = let
  Source = Game_event_clean_base,
  #"Merged queries" = Table.NestedJoin(Source, {"session_id"}, Q_nb_guesses, {"session_id"}, "Q_nb_guesses", JoinKind.LeftOuter),
  #"Expanded Q_nb_guesses" = Table.ExpandTableColumn(#"Merged queries", "Q_nb_guesses", {"nb_guesses"}, {"nb_guesses"}),
  #"Merged queries 1" = Table.NestedJoin(#"Expanded Q_nb_guesses", {"session_id"}, Q_avg_response_time_sec, {"session_id"}, "Q_avg_response_time_sec", JoinKind.LeftOuter),
  #"Expanded Q_avg_response_time_sec" = Table.ExpandTableColumn(#"Merged queries 1", "Q_avg_response_time_sec", {"avg_response_time_sec"}, {"avg_response_time_sec"}),
  #"Merged queries 2" = Table.NestedJoin(#"Expanded Q_avg_response_time_sec", {"session_id"}, Q_max_hint_stage_reached, {"session_id"}, "Q_max_hint_stage_reached", JoinKind.LeftOuter),
  #"Expanded Q_max_hint_stage_reached" = Table.ExpandTableColumn(#"Merged queries 2", "Q_max_hint_stage_reached", {"max_hint_stage_reached"}, {"max_hint_stage_reached"}),
  #"Removed columns" = Table.RemoveColumns(#"Expanded Q_max_hint_stage_reached", {"hint_stage", "session_result", "event_sequence", "event_ts", "difficulty_at_start", "response_time_sec", "is_correct", "guess_text", "event_type", "hint_id", "city_id", "event_id"}),
  #"Merged queries 3" = Table.NestedJoin(#"Removed columns", {"session_id"}, Q_session_start, {"session_id"}, "Q_session_start", JoinKind.LeftOuter),
  #"Expanded Q_session_start" = Table.ExpandTableColumn(#"Merged queries 3", "Q_session_start", {"session_date_key"}, {"session_date_key"}),
  #"Reordered columns" = Table.ReorderColumns(#"Expanded Q_session_start", {"session_id", "session_date_key", "nb_guesses", "avg_response_time_sec", "max_hint_stage_reached"})
in
  #"Reordered columns";
shared Game_session_base = let
  Source = Fabric.Warehouse(null),
  Navigation = Source{[workspaceId = "033093b9-ab6e-4de5-8f71-92e3f1cfc945"]}[Data],
  #"Navigation 1" = Navigation{[warehouseId = "db2942b9-4c6e-43a8-974b-ded16abfd378"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Schema = "dbo", Item = "game_session"]}[Data],
  #"Replaced value" = Table.ReplaceValue(#"Navigation 2", null, "abandoned", Replacer.ReplaceValue, {"session_result"})
in
  #"Replaced value";
shared #"Q_is_success, failed or abandoned" = let
  Source = Game_session_base,
  #"Removed columns" = Table.RemoveColumns(Source, {"city_id", "session_start_ts", "session_end_ts", "session_duration_sec", "session_status", "difficulty_at_start", "nb_hints_requested", "nb_hints_shown"}),
  #"Added custom" = Table.AddColumn(#"Removed columns", "is_success", each if [session_result] = "success" then 1 else 0),
  #"Inserted conditional column" = Table.AddColumn(#"Added custom", "is_failed", each if [session_result] = "failed" then 1 else 0),
  #"Added custom 1" = Table.AddColumn(#"Inserted conditional column", "is_abandoned", each if [session_result] = null then 1 else 0),
  #"Removed columns 1" = Table.RemoveColumns(#"Added custom 1", {"session_result"})


in
  #"Removed columns 1";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Q_event_&_session_final_DataDestination", IsNewTarget = true], Settings = [Kind = "Manual", AllowCreation = true, ColumnSettings = [Mappings = {[SourceColumnName = "session_id", DestinationColumnName = "session_id"], [SourceColumnName = "city_id", DestinationColumnName = "city_id"], [SourceColumnName = "session_date_key", DestinationColumnName = "session_date_key"], [SourceColumnName = "session_duration_sec", DestinationColumnName = "session_duration_sec"], [SourceColumnName = "session_result", DestinationColumnName = "session_result"], [SourceColumnName = "is_success", DestinationColumnName = "is_success"], [SourceColumnName = "is_failed", DestinationColumnName = "is_failed"], [SourceColumnName = "is_abandoned", DestinationColumnName = "is_abandoned"], [SourceColumnName = "nb_hints_requested", DestinationColumnName = "nb_hints_requested"], [SourceColumnName = "nb_hints_shown", DestinationColumnName = "nb_hints_shown"], [SourceColumnName = "nb_guesses", DestinationColumnName = "nb_guesses"], [SourceColumnName = "avg_response_time_sec", DestinationColumnName = "avg_response_time_sec"], [SourceColumnName = "max_hint_stage_reached", DestinationColumnName = "max_hint_stage_reached"], [SourceColumnName = "event_source", DestinationColumnName = "event_source"], [SourceColumnName = "is_simulated", DestinationColumnName = "is_simulated"]}], DynamicSchema = false, UpdateMethod = [Kind = "Replace"], TypeSettings = [Kind = "Table"]]]}]
shared #"Q_event_&_session_final" = let
  Source = Game_session_base,
  #"Removed columns" = Table.RemoveColumns(Source, {"session_start_ts", "session_end_ts", "session_status", "difficulty_at_start"}),
  #"Merged queries" = Table.NestedJoin(#"Removed columns", {"session_id"}, #"Q_is_success, failed or abandoned", {"session_id"}, "Q_is_success, failed or abandoned", JoinKind.LeftOuter),
  #"Expanded Q_is_success, failed or abandoned" = Table.ExpandTableColumn(#"Merged queries", "Q_is_success, failed or abandoned", {"is_success", "is_failed", "is_abandoned"}, {"is_success", "is_failed", "is_abandoned"}),
  #"Merged queries 1" = Table.NestedJoin(#"Expanded Q_is_success, failed or abandoned", {"session_id"}, Game_event_clean_final, {"session_id"}, "Game_event_clean_final", JoinKind.LeftOuter),
  #"Expanded Game_event_clean_final" = Table.ExpandTableColumn(#"Merged queries 1", "Game_event_clean_final", {"session_date_key", "nb_guesses", "avg_response_time_sec", "max_hint_stage_reached"}, {"session_date_key", "nb_guesses", "avg_response_time_sec", "max_hint_stage_reached"}),
  #"Reordered columns" = Table.ReorderColumns(#"Expanded Game_event_clean_final", {"session_id", "city_id", "session_date_key", "session_duration_sec", "session_result", "is_success", "is_failed", "is_abandoned", "nb_hints_requested", "nb_hints_shown", "nb_guesses", "avg_response_time_sec", "max_hint_stage_reached"}),
  #"Changed column type" = Table.TransformColumnTypes(#"Reordered columns", {{"session_date_key", type text}, {"is_success", Int64.Type}, {"is_failed", Int64.Type}, {"is_abandoned", Int64.Type}}),
  #"Sorted rows" = Table.Sort(#"Changed column type", {{"session_id", Order.Ascending}}),
  #"Removed duplicates" = Table.Distinct(#"Sorted rows", {"session_id"}),
  #"Reordered columns 1" = Table.ReorderColumns(#"Removed duplicates", {"session_id", "city_id", "session_date_key", "session_duration_sec", "session_result", "is_success", "is_failed", "is_abandoned", "nb_hints_requested", "nb_hints_shown", "nb_guesses", "avg_response_time_sec", "max_hint_stage_reached", "event_source", "is_simulated"}),
  #"Changed column type 1" = Table.TransformColumnTypes(#"Reordered columns 1", {{"session_date_key", Int64.Type}})
in
  #"Changed column type 1";
shared #"Q_event_&_session_final_DataDestination" = let
  Pattern = Fabric.Warehouse([CreateNavigationProperties = false, HierarchicalNavigation = null]),
  Navigation_1 = Pattern{[workspaceId = "."]}[Data],
  Navigation_2 = Navigation_1{[displayName = "wh_gold"]}[Data],
  TableNavigation = Navigation_2{[Item = "fact_game_session", Schema = "dbo"]}?[Data]?
in
  TableNavigation;
