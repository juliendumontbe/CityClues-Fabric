[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Weather_DataDestination", IsNewTarget = true], Settings = [Kind = "Manual", AllowCreation = true, ColumnSettings = [Mappings = {[SourceColumnName = "city_id", DestinationColumnName = "city_id"], [SourceColumnName = "weather_api_city_id", DestinationColumnName = "weather_api_city_id"], [SourceColumnName = "humidity", DestinationColumnName = "humidity"], [SourceColumnName = "temperature", DestinationColumnName = "temperature"], [SourceColumnName = "weather_type", DestinationColumnName = "weather_type"], [SourceColumnName = "timezone_offset_sec", DestinationColumnName = "timezone_offset_sec"], [SourceColumnName = "weather_timestamp", DestinationColumnName = "weather_timestamp"], [SourceColumnName = "ingestion_timestamp", DestinationColumnName = "ingestion_timestamp"]}], DynamicSchema = false, UpdateMethod = [Kind = "Replace"], TypeSettings = [Kind = "Table"]]]}]
shared Weather = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "d9bd2de4-97a5-4cbe-80f4-5e4d4fb42b70"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "dc3ad09d-93e7-41a0-8301-c0f8ec6cb84e"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "Files", ItemKind = "Folder"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Name = "Weather"]}[Content],
  #"Expanded Content" = Table.ExpandTableColumn(#"Navigation 3", "Content", {"Content", "Name", "Folder Path"}, {"Content.1", "Name.1", "Folder Path.1"}),
  #"Renamed columns" = Table.RenameColumns(#"Expanded Content", {{"Name", "City_folder"}}),
  #"Expanded Content.1" = Table.ExpandTableColumn(#"Renamed columns", "Content.1", {"Content", "Name", "Folder Path"}, {"Content", "Name", "Folder Path.2"}),
  #"Renamed columns 1" = Table.RenameColumns(#"Expanded Content.1", {{"Name.1", "Year_folder"}}),
  #"Expanded Content 1" = Table.ExpandTableColumn(#"Renamed columns 1", "Content", {"Content", "Name", "Folder Path"}, {"Content.1", "Name.1", "Folder Path.3"}),
  #"Renamed columns 2" = Table.RenameColumns(#"Expanded Content 1", {{"Name", "Month_folder"}}),
  #"Expanded Content.1 1" = Table.ExpandTableColumn(#"Renamed columns 2", "Content.1", {"Content", "Name", "Folder Path"}, {"Content", "Name", "Folder Path.4"}),
  #"Renamed columns 3" = Table.RenameColumns(#"Expanded Content.1 1", {{"Name.1", "Day_folder"}}),
  #"Expanded Content 2" = Table.ExpandTableColumn(#"Renamed columns 3", "Content", {"Content", "Name", "Folder Path"}, {"Content.1", "Name.1", "Folder Path.5"}),
  #"Renamed columns 4" = Table.RenameColumns(#"Expanded Content 2", {{"Name", "Hour_folder"}}),
  #"Removed columns" = Table.RemoveColumns(#"Renamed columns 4", {"Folder Path.2", "Folder Path.1", "Folder Path.3", "Folder Path.4"}),
  #"Renamed columns 5" = Table.RenameColumns(#"Removed columns", {{"Folder Path.5", "Folder_path"}}),
  #"Filtered hidden files" = Table.SelectRows(#"Renamed columns 5", each [Attributes]?[Hidden]? <> true),
  #"Invoke custom function" = Table.AddColumn(#"Filtered hidden files", "Transform file", each #"Transform file"([Content.1])),
  #"Removed other columns" = Table.SelectColumns(#"Invoke custom function", {"Folder_path", "Transform file"}),
  #"Expanded table column" = Table.ExpandTableColumn(#"Removed other columns", "Transform file", Table.ColumnNames(#"Transform file"(#"Sample file"))),
  #"Changed column type" = Table.TransformColumnTypes(#"Expanded table column", {{"coord.lon", type number}, {"coord.lat", type number}, {"weather.id", Int64.Type}, {"weather.main", type text}, {"weather.description", type text}, {"weather.icon", type text}, {"base", type text}, {"main.temp", type number}, {"main.feels_like", type number}, {"main.temp_min", type number}, {"main.temp_max", type number}, {"main.pressure", Int64.Type}, {"main.humidity", Int64.Type}, {"main.sea_level", Int64.Type}, {"main.grnd_level", Int64.Type}, {"visibility", Int64.Type}, {"wind.speed", type number}, {"wind.deg", Int64.Type}, {"wind.gust", type number}, {"clouds.all", Int64.Type}, {"dt", Int64.Type}, {"sys.type", Int64.Type}, {"sys.id", Int64.Type}, {"sys.country", type text}, {"sys.sunrise", Int64.Type}, {"sys.sunset", Int64.Type}, {"timezone", Int64.Type}, {"id", Int64.Type}, {"name", type text}, {"cod", Int64.Type}}),
  #"Removed other columns 1" = Table.SelectColumns(#"Changed column type", {"Folder_path", "weather.main", "main.temp", "main.humidity", "dt", "id", "name", "cod", "timezone"}),
  #"Renamed columns 6" = Table.RenameColumns(#"Removed other columns 1", {{"name", "City_name_api"}, {"id", "weather_api_city_id"},{"timezone", "timezone_offset_sec"} , {"weather.main", "weather_type"}}),
  #"Reordered columns" = Table.ReorderColumns(#"Renamed columns 6", {"weather_api_city_id", "main.humidity", "main.temp", "dt", "weather_type", "City_name_api", "cod"}),
  #"Renamed columns 7" = Table.RenameColumns(#"Reordered columns", {{"dt", "weather_timestamp_unix"}, {"main.temp", "temperature"}, {"main.humidity", "humidity"}, {"City_name_api", "city_name_api"}}),
  #"Added custom" = Table.AddColumn(#"Renamed columns 7", "weather_timestamp", each #datetime(1970,1,1,0,0,0) + #duration(0,0,0,[weather_timestamp_unix])),
  #"Removed columns 1" = Table.RemoveColumns(#"Added custom", {"weather_timestamp_unix"}),
  #"Reordered columns 1" = Table.ReorderColumns(#"Removed columns 1", {"weather_api_city_id", "humidity", "temperature", "weather_type", "city_name_api", "weather_timestamp", "cod", "Folder_path"}),
  #"Added custom 1" = Table.AddColumn(#"Reordered columns 1", "ingestion_timestamp", each let
    parts = List.Select(
        Text.Split(
            Text.AfterDelimiter([Folder_path], "/Files/Weather/"),
            "/"
        ),
        each _ <> ""
    )
in
    #datetime(
        Number.FromText(parts{1}),
        Number.FromText(parts{2}),
        Number.FromText(parts{3}),
        Number.FromText(parts{4}),
        0,
        0
    )),
  #"Changed column type 1" = Table.TransformColumnTypes(#"Added custom 1", {{"ingestion_timestamp", type datetime}}),
  #"Filtered rows" = Table.SelectRows(#"Changed column type 1", each ([weather_api_city_id] <> null and [weather_api_city_id] <> "") and ([humidity] <> null and [humidity] <> "") and ([temperature] <> null and [temperature] <> "") and ([weather_type] <> null and [weather_type] <> "")),
  #"Reordered columns 2" = Table.ReorderColumns(#"Filtered rows", {"weather_api_city_id", "humidity", "temperature", "weather_type", "city_name_api", "weather_timestamp", "ingestion_timestamp", "cod", "Folder_path"}),
  #"Added custom 3" = Table.AddColumn(#"Reordered columns 2", "city_id_correct", each Number.FromText(
    Text.BeforeDelimiter(
        Text.BeforeDelimiter(
            Text.AfterDelimiter([Folder_path], "Files/Weather/"),
            "/"
        ),
        "_"
    )
)),
  #"Removed columns 2" = Table.RemoveColumns(#"Added custom 3", {"Folder_path"}),
  #"Sorted rows" = Table.Sort(#"Removed columns 2", {{"city_id_correct", Order.Ascending}, {"weather_timestamp", Order.Descending}}),
  #"Grouped rows" = Table.Group(
    #"Sorted rows", 
    {"city_id_correct"}, 
    {
        {"Allrows", each _, type table [
            weather_api_city_id = nullable Int64.Type, 
            city_id_is_correct = nullable Int64.Type,
            humidity = nullable Int64.Type, 
            temperature = nullable number, 
            weather_type = nullable text, 
            city_name_api = nullable text, 
            weather_timestamp = any, 
            ingestion_timestamp = nullable datetime, 
            cod = nullable Int64.Type,
            timezone_offset_sec = nullable Int64.Type
        ]}
    }
),
  #"Added custom 2" = Table.AddColumn(#"Grouped rows", "LatestRow", each Table.FirstN([Allrows], 1)),
  #"Expanded LatestRow 1" = Table.ExpandTableColumn(#"Added custom 2", "LatestRow", {"weather_api_city_id", "humidity", "temperature", "weather_type", "city_name_api", "weather_timestamp", "ingestion_timestamp", "timezone_offset_sec", "cod"}, {"weather_api_city_id.1", "humidity", "temperature", "weather_type", "city_name_api", "weather_timestamp", "ingestion_timestamp", "timezone_offset_sec", "cod"}),
  #"Removed columns 3" = Table.RemoveColumns(#"Expanded LatestRow 1", {"Allrows", "cod", "city_name_api"}),
  #"Changed column type 2" = Table.TransformColumnTypes(#"Removed columns 3", {{"humidity", Int64.Type}, {"temperature", type number}, {"weather_type", type text}, {"weather_timestamp", type datetime}, {"ingestion_timestamp", type datetime}, {"timezone_offset_sec", Int64.Type}}),
  #"Renamed columns 8" = Table.RenameColumns(#"Changed column type 2", {{"city_id_correct", "city_id"}, {"weather_api_city_id.1", "weather_api_city_id"}}),
  #"Reordered columns 3" = Table.ReorderColumns(#"Renamed columns 8", {"city_id", "weather_api_city_id", "humidity", "temperature", "weather_type", "timezone_offset_sec", "weather_timestamp", "ingestion_timestamp"}),
  #"Changed column type 3" = Table.TransformColumnTypes(#"Reordered columns 3", {{"city_id", Int64.Type}, {"weather_api_city_id", Int64.Type}}),
  #"Lowercased text" = Table.TransformColumns(#"Changed column type 3", {{"weather_type", each Text.Lower(_), type nullable text}})
in
  #"Lowercased text";
shared #"Sample file" = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "d9bd2de4-97a5-4cbe-80f4-5e4d4fb42b70"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "dc3ad09d-93e7-41a0-8301-c0f8ec6cb84e"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "Files", ItemKind = "Folder"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Name = "Weather"]}[Content],
  #"Expanded Content" = Table.ExpandTableColumn(#"Navigation 3", "Content", {"Content", "Name", "Folder Path"}, {"Content.1", "Name.1", "Folder Path.1"}),
  #"Renamed columns" = Table.RenameColumns(#"Expanded Content", {{"Name", "City_folder"}}),
  #"Expanded Content.1" = Table.ExpandTableColumn(#"Renamed columns", "Content.1", {"Content", "Name", "Folder Path"}, {"Content", "Name", "Folder Path.2"}),
  #"Renamed columns 1" = Table.RenameColumns(#"Expanded Content.1", {{"Name.1", "Year_folder"}}),
  #"Expanded Content 1" = Table.ExpandTableColumn(#"Renamed columns 1", "Content", {"Content", "Name", "Folder Path"}, {"Content.1", "Name.1", "Folder Path.3"}),
  #"Renamed columns 2" = Table.RenameColumns(#"Expanded Content 1", {{"Name", "Month_folder"}}),
  #"Expanded Content.1 1" = Table.ExpandTableColumn(#"Renamed columns 2", "Content.1", {"Content", "Name", "Folder Path"}, {"Content", "Name", "Folder Path.4"}),
  #"Renamed columns 3" = Table.RenameColumns(#"Expanded Content.1 1", {{"Name.1", "Day_folder"}}),
  #"Expanded Content 2" = Table.ExpandTableColumn(#"Renamed columns 3", "Content", {"Content", "Name", "Folder Path"}, {"Content.1", "Name.1", "Folder Path.5"}),
  #"Renamed columns 4" = Table.RenameColumns(#"Expanded Content 2", {{"Name", "Hour_folder"}}),
  #"Removed columns" = Table.RemoveColumns(#"Renamed columns 4", {"Folder Path.2", "Folder Path.1", "Folder Path.3", "Folder Path.4"}),
  #"Renamed columns 5" = Table.RenameColumns(#"Removed columns", {{"Folder Path.5", "Folder_path"}}),
  #"Filtered hidden files" = Table.SelectRows(#"Renamed columns 5", each [Attributes]?[Hidden]? <> true),
  #"Navigation 4" = #"Filtered hidden files"{0}[Content.1]
in
  #"Navigation 4";
shared Parameter = let
  Parameter = #"Sample file" meta [IsParameterQuery = true, IsParameterQueryRequired = false, Type = type binary, BinaryIdentifier = #"Sample file"]
in
  Parameter;
shared #"Transform Sample file" = let
  Source = Json.Document(Parameter, 65001),
  #"Converted to table" = Table.FromRecords({Source}),
  #"Expanded coord" = Table.ExpandRecordColumn(#"Converted to table", "coord", {"lon", "lat"}, {"coord.lon", "coord.lat"}),
  #"Expanded weather" = Table.ExpandListColumn(#"Expanded coord", "weather"),
  #"Expanded weather1" = Table.ExpandRecordColumn(#"Expanded weather", "weather", {"id", "main", "description", "icon"}, {"weather.id", "weather.main", "weather.description", "weather.icon"}),
  #"Expanded main" = Table.ExpandRecordColumn(#"Expanded weather1", "main", {"temp", "feels_like", "temp_min", "temp_max", "pressure", "humidity", "sea_level", "grnd_level"}, {"main.temp", "main.feels_like", "main.temp_min", "main.temp_max", "main.pressure", "main.humidity", "main.sea_level", "main.grnd_level"}),
  #"Expanded wind" = Table.ExpandRecordColumn(#"Expanded main", "wind", {"speed", "deg", "gust"}, {"wind.speed", "wind.deg", "wind.gust"}),
  #"Expanded clouds" = Table.ExpandRecordColumn(#"Expanded wind", "clouds", {"all"}, {"clouds.all"}),
  #"Expanded sys" = Table.ExpandRecordColumn(#"Expanded clouds", "sys", {"type", "id", "country", "sunrise", "sunset"}, {"sys.type", "sys.id", "sys.country", "sys.sunrise", "sys.sunset"})
in
  #"Expanded sys";
[FunctionQueryBinding = "{""exemplarFormulaName"":""Transform Sample file""}"]
shared #"Transform file" = (Parameter as binary) => let
  Source = Json.Document(Parameter, 65001),
  #"Converted to table" = Table.FromRecords({Source}),
  #"Expanded coord" = Table.ExpandRecordColumn(#"Converted to table", "coord", {"lon", "lat"}, {"coord.lon", "coord.lat"}),
  #"Expanded weather" = Table.ExpandListColumn(#"Expanded coord", "weather"),
  #"Expanded weather1" = Table.ExpandRecordColumn(#"Expanded weather", "weather", {"id", "main", "description", "icon"}, {"weather.id", "weather.main", "weather.description", "weather.icon"}),
  #"Expanded main" = Table.ExpandRecordColumn(#"Expanded weather1", "main", {"temp", "feels_like", "temp_min", "temp_max", "pressure", "humidity", "sea_level", "grnd_level"}, {"main.temp", "main.feels_like", "main.temp_min", "main.temp_max", "main.pressure", "main.humidity", "main.sea_level", "main.grnd_level"}),
  #"Expanded wind" = Table.ExpandRecordColumn(#"Expanded main", "wind", {"speed", "deg", "gust"}, {"wind.speed", "wind.deg", "wind.gust"}),
  #"Expanded clouds" = Table.ExpandRecordColumn(#"Expanded wind", "clouds", {"all"}, {"clouds.all"}),
  #"Expanded sys" = Table.ExpandRecordColumn(#"Expanded clouds", "sys", {"type", "id", "country", "sunrise", "sunset"}, {"sys.type", "sys.id", "sys.country", "sys.sunrise", "sys.sunset"})
in
  #"Expanded sys";
shared Weather_DataDestination = let
  Pattern = Fabric.Warehouse([CreateNavigationProperties = false, HierarchicalNavigation = null]),
  Navigation_1 = Pattern{[workspaceId = "."]}[Data],
  Navigation_2 = Navigation_1{[displayName = "wh_silver"]}[Data],
  TableNavigation = Navigation_2{[Item = "weather_city_current", Schema = "dbo"]}?[Data]?
in
  TableNavigation;
