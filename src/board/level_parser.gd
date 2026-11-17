@tool
class_name LevelParser
extends RefCounted
## Converte una LevelDefinition (layout testuali) in una BoardModel.
## Raccoglie tutti gli errori invece di fermarsi al primo, così il Designer
## vede subito cosa correggere.


static func parse(level: LevelDefinition) -> ParsedLevel:
	var result: ParsedLevel = ParsedLevel.new()
	if level == null:
		result.errors.append("Missing LevelDefinition")
		return result
	if level.legend == null:
		result.errors.append("Level '%s' has no LevelLegend" % level.display_name)
		return result

	var tile_rows: PackedStringArray = split_rows(level.tiles_layout)
	if tile_rows.is_empty():
		result.errors.append("tiles_layout is empty")
		return result

	var size: Vector2i = Vector2i(tile_rows[0].length(), tile_rows.size())
	var entity_rows: PackedStringArray = split_rows(level.entities_layout)
	var arrow_rows: PackedStringArray = split_rows(level.arrows_layout)
	_check_layer_size(tile_rows, size, "tiles_layout", false, result)
	_check_layer_size(entity_rows, size, "entities_layout", false, result)
	_check_layer_size(arrow_rows, size, "arrows_layout", true, result)
	if not result.errors.is_empty():
		return result

	var legend: LevelLegend = level.legend
	var board: BoardModel = BoardModel.new(size)
	for cell: Vector2i in board.get_all_positions():
		var tile: TileDefinition = _parse_tile(tile_rows[cell.y][cell.x], cell, legend, result)
		var arrow: Direction.Type = Direction.Type.NONE
		if not arrow_rows.is_empty():
			arrow = _parse_arrow(arrow_rows[cell.y][cell.x], cell, legend, result)
		var entity: BoardEntity = _parse_entity(entity_rows[cell.y][cell.x], cell, legend, result)
		if entity != null and tile != null and not tile.is_walkable:
			result.errors.append("Element on a non-walkable tile at %s" % cell)
		board.set_cell(cell, CellData.new(tile, arrow, entity))

	_validate_player_start(board, result)
	if result.errors.is_empty():
		result.board = board
	return result


## Divide il testo in righe (usato anche dal Level Editor), ignorando righe vuote e spazi/tab (servono solo a leggere meglio).
static func split_rows(text: String) -> PackedStringArray:
	var rows: PackedStringArray = PackedStringArray()
	for raw_row: String in text.split("\n"):
		var row: String = raw_row.replace(" ", "").replace("\t", "").replace("\r", "")
		if not row.is_empty():
			rows.append(row)
	return rows


static func _check_layer_size(rows: PackedStringArray, size: Vector2i, layer_name: String, is_optional: bool, result: ParsedLevel) -> void:
	if rows.is_empty() and is_optional:
		return
	if rows.size() != size.y:
		result.errors.append("%s has %d rows, expected %d" % [layer_name, rows.size(), size.y])
		return
	for y: int in rows.size():
		if rows[y].length() != size.x:
			result.errors.append("%s row %d has %d columns, expected %d" % [layer_name, y + 1, rows[y].length(), size.x])


static func _parse_tile(symbol: String, cell: Vector2i, legend: LevelLegend, result: ParsedLevel) -> TileDefinition:
	if not legend.tiles.has(symbol):
		result.errors.append("Tile symbol '%s' not found in the legend (%s)" % [symbol, cell])
		return null
	return legend.tiles[symbol]


static func _parse_arrow(symbol: String, cell: Vector2i, legend: LevelLegend, result: ParsedLevel) -> Direction.Type:
	if symbol == legend.empty_symbol:
		return Direction.Type.NONE
	var direction: Direction.Type = legend.get_arrow_direction(symbol)
	if direction == Direction.Type.NONE:
		result.errors.append("Invalid arrow symbol '%s' (%s)" % [symbol, cell])
	return direction


static func _parse_entity(symbol: String, cell: Vector2i, legend: LevelLegend, result: ParsedLevel) -> BoardEntity:
	if symbol == legend.empty_symbol:
		return null
	if symbol == legend.player_start_symbol:
		if result.player_start != Vector2i(-1, -1):
			result.errors.append("More than one player start position (%s)" % cell)
		result.player_start = cell
		return null
	if not legend.entities.has(symbol):
		result.errors.append("Element symbol '%s' not found in the legend (%s)" % [symbol, cell])
		return null
	var definition: EntityDefinition = legend.entities[symbol]
	return definition.create_entity()


static func _validate_player_start(board: BoardModel, result: ParsedLevel) -> void:
	if result.player_start == Vector2i(-1, -1):
		result.errors.append("Missing player start position")
		return
	var start_tile: TileDefinition = board.get_cell(result.player_start).tile
	if start_tile != null and (not start_tile.is_walkable or start_tile.is_goal):
		result.errors.append("The start position must be a walkable, non-goal tile")
