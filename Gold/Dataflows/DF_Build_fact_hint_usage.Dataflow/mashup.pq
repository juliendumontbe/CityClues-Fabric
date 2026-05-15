[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared Game_event_clean = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "033093b9-ab6e-4de5-8f71-92e3f1cfc945"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "efc71201-3a98-41b9-81f4-1235d7f9d37b"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "Game_event_clean", ItemKind = "Table"]}[Data],
  #"Removed other columns" = Table.SelectColumns(#"Navigation 2", {"session_id", "city_id", "hint_id", "event_type", "is_correct", "event_ts", "event_sequence", "session_result", "hint_stage", "event_source", "is_simulated"})
in
  #"Removed other columns";
shared Q_hint_shown = let
  Source = Game_event_clean,
  #"Filtered rows" = Table.SelectRows(Source, each ([event_type] = "hint_shown")),
  #"Removed other columns" = Table.SelectColumns(#"Filtered rows", {"session_id", "city_id", "hint_id", "event_sequence", "hint_stage", "event_source", "is_simulated"}),
  #"Renamed columns" = Table.RenameColumns(#"Removed other columns", {{"event_sequence", "hint_sequence"}})
in
  #"Renamed columns";
shared Q_guess = let
  Source = Game_event_clean,
  #"Filtered rows" = Table.SelectRows(Source, each ([event_type] = "guess_submitted")),
  #"Removed columns" = Table.RemoveColumns(#"Filtered rows", {"city_id", "hint_id", "hint_stage", "event_type", "event_ts", "is_correct", "session_result", "event_source", "is_simulated"}),
  #"Renamed columns" = Table.RenameColumns(#"Removed columns", {{"event_sequence", "guess_sequence"}})
in
  #"Renamed columns";
shared Q_session_start = let
  Source = Game_event_clean,
  #"Filtered rows" = Table.SelectRows(Source, each ([event_type] = "session_started")),
  #"Removed other columns" = Table.SelectColumns(#"Filtered rows", {"session_id", "event_ts"}),
  #"Renamed columns" = Table.RenameColumns(#"Removed other columns", {{"event_ts", "session_started_ts"}}),
  #"Changed column type" = Table.TransformColumnTypes(#"Renamed columns", {{"session_started_ts", type datetime}}),
  #"Added custom" = Table.AddColumn(#"Changed column type", "session_date_key", each Int64.From(Date.ToText(DateTime.Date([session_started_ts]), "yyyyMMdd"))),
  #"Removed columns" = Table.RemoveColumns(#"Added custom", {"session_started_ts"})
in
  #"Removed columns";
shared Q_session_success = let
  Source = Game_event_clean,
  #"Filtered rows" = Table.SelectRows(Source, each ([event_type] = "session_ended")),
  #"Removed columns" = Table.RemoveColumns(#"Filtered rows", {"city_id", "hint_id", "hint_stage", "event_sequence", "event_type", "event_ts", "is_correct"}),
  #"Added custom" = Table.AddColumn(#"Removed columns", "is_success_session", each if [session_result] = "success" then 1 else 0),
  #"Removed columns 1" = Table.RemoveColumns(#"Added custom", {"session_result", "is_simulated", "event_source"})
in
  #"Removed columns 1";
shared Q_first_correct_guess = let
  Source = Game_event_clean,
  #"Filtered rows" = Table.SelectRows(Source, each ([event_type] = "guess_submitted") and ([is_correct] = true)),
  #"Removed columns" = Table.RemoveColumns(#"Filtered rows", {"city_id", "hint_id", "hint_stage", "event_type", "event_ts", "is_correct", "session_result"}),
  #"Renamed columns" = Table.RenameColumns(#"Removed columns", {{"event_sequence", "correct_guess_sequence"}}),
  #"Grouped rows" = Table.Group(#"Renamed columns", {"session_id"}, {{"first_correct_guess_sequence", each List.Min([correct_guess_sequence]), type nullable Int64.Type}})
in
  #"Grouped rows";
shared Q_fact_hint_usage_base = let
  Source = Q_hint_shown,
  #"Merged queries" = Table.NestedJoin(Source, {"session_id"}, Q_session_start, {"session_id"}, "Q_session_start", JoinKind.LeftOuter),
  #"Expanded Q_session_start" = Table.ExpandTableColumn(#"Merged queries", "Q_session_start", {"session_date_key"}, {"session_date_key"}),
  #"Merged queries 1" = Table.NestedJoin(#"Expanded Q_session_start", {"session_id"}, Q_session_success, {"session_id"}, "Q_session_success", JoinKind.LeftOuter),
  #"Expanded Q_session_success" = Table.ExpandTableColumn(#"Merged queries 1", "Q_session_success", {"is_success_session"}, {"is_success_session"}),
  #"Merged queries 2" = Table.NestedJoin(#"Expanded Q_session_success", {"session_id"}, Q_first_correct_guess, {"session_id"}, "Q_first_correct_guess", JoinKind.LeftOuter),
  #"Expanded Q_first_correct_guess" = Table.ExpandTableColumn(#"Merged queries 2", "Q_first_correct_guess", {"first_correct_guess_sequence"}, {"first_correct_guess_sequence"}),
  #"Merged queries 3" = Table.NestedJoin(#"Expanded Q_first_correct_guess", {"session_id"}, Q_guess, {"session_id"}, "Q_guess", JoinKind.LeftOuter),
  #"Expanded Q_guess" = Table.ExpandTableColumn(#"Merged queries 3", "Q_guess", {"guess_sequence"}, {"guess_sequence"}),
  #"Added custom" = Table.AddColumn(#"Expanded Q_guess", "before_flag", each if [guess_sequence] < [hint_sequence] then 1 else 0),
  #"Added custom 1" = Table.AddColumn(#"Added custom", "after_flag", each if [guess_sequence] > [hint_sequence] then 1 else 0),
  #"Grouped rows" = Table.Group(#"Added custom 1", {"session_id", "city_id", "hint_id", "hint_stage", "hint_sequence", "session_date_key", "is_success_session", "first_correct_guess_sequence", "event_source", "is_simulated"}, {{"guesses_before_hint", each List.Sum([before_flag]), type any}, {"guesses_after_hint", each List.Sum([after_flag]), type any}})
in
  #"Grouped rows";
shared Q_Last_Hint_Candidate = let
  Source = Q_fact_hint_usage_base,
  #"Filtered rows" = Table.SelectRows(Source, each ([is_success_session] = 1)),
  #"Added custom" = Table.AddColumn(#"Filtered rows", "is_candidate", each if [hint_sequence] < [first_correct_guess_sequence] then 1 else 0),
  #"Grouped rows" = Table.Group(#"Added custom", {"session_id"}, {{"max_hint_before_success", each List.Max([hint_sequence]), type nullable Int64.Type}})
in
  #"Grouped rows";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Q_fact_hint_usage_final_DataDestination", IsNewTarget = true], Settings = [Kind = "Manual", AllowCreation = true, ColumnSettings = [Mappings = {[SourceColumnName = "session_id", DestinationColumnName = "session_id"], [SourceColumnName = "city_id", DestinationColumnName = "city_id"], [SourceColumnName = "hint_id", DestinationColumnName = "hint_id"], [SourceColumnName = "hint_stage", DestinationColumnName = "hint_stage"], [SourceColumnName = "guesses_before_hint", DestinationColumnName = "guesses_before_hint"], [SourceColumnName = "guesses_after_hint", DestinationColumnName = "guesses_after_hint"], [SourceColumnName = "is_last_hint_before_success", DestinationColumnName = "is_last_hint_before_success"], [SourceColumnName = "is_session_success", DestinationColumnName = "is_session_success"], [SourceColumnName = "session_date_key", DestinationColumnName = "session_date_key"], [SourceColumnName = "event_source", DestinationColumnName = "event_source"], [SourceColumnName = "is_simulated", DestinationColumnName = "is_simulated"]}], DynamicSchema = false, UpdateMethod = [Kind = "Replace"], TypeSettings = [Kind = "Table"]]]}]
shared Q_fact_hint_usage_final = let
  Source = Q_fact_hint_usage_base,
  #"Merged queries" = Table.NestedJoin(Source, {"session_id"}, Q_Last_Hint_Candidate, {"session_id"}, "Q_Last_Hint_Candidate", JoinKind.LeftOuter),
  #"Expanded Q_Last_Hint_Candidate" = Table.ExpandTableColumn(#"Merged queries", "Q_Last_Hint_Candidate", {"max_hint_before_success"}, {"max_hint_before_success"}),
  #"Added custom" = Table.AddColumn(#"Expanded Q_Last_Hint_Candidate", "is_last_hint_before_success", each if [is_success_session] = 1 and [hint_sequence] = [max_hint_before_success] then 1 else 0),
  #"Removed columns" = Table.RemoveColumns(#"Added custom", {"hint_sequence", "first_correct_guess_sequence", "max_hint_before_success"}),
  #"Renamed columns" = Table.RenameColumns(#"Removed columns", {{"is_success_session", "is_session_success"}}),
  #"Reordered columns" = Table.ReorderColumns(#"Renamed columns", {"session_id", "city_id", "hint_id", "hint_stage", "guesses_before_hint", "guesses_after_hint", "is_last_hint_before_success", "is_session_success", "session_date_key"}),
  #"Changed column type" = Table.TransformColumnTypes(#"Reordered columns", {{"city_id", Int64.Type}, {"guesses_before_hint", Int64.Type}, {"guesses_after_hint", Int64.Type}, {"is_last_hint_before_success", Int64.Type}, {"is_session_success", Int64.Type}, {"session_date_key", Int64.Type}}),
  #"Reordered columns 1" = Table.ReorderColumns(#"Changed column type", {"session_id", "city_id", "hint_id", "hint_stage", "guesses_before_hint", "guesses_after_hint", "is_last_hint_before_success", "is_session_success", "session_date_key", "event_source", "is_simulated"})
in
  #"Reordered columns 1";
shared Q_fact_hint_usage_final_DataDestination = let
  Pattern = Fabric.Warehouse([CreateNavigationProperties = false, HierarchicalNavigation = null]),
  Navigation_1 = Pattern{[workspaceId = "."]}[Data],
  Navigation_2 = Navigation_1{[displayName = "wh_gold"]}[Data],
  TableNavigation = Navigation_2{[Item = "fact_hint_usage", Schema = "dbo"]}?[Data]?
in
  TableNavigation;
