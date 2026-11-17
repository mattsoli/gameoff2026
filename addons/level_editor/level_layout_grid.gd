@tool
class_name LevelLayoutGrid
extends RefCounted
## I tre layer testuali di un livello trasformati in una griglia di simboli modificabile.
## Il Level Editor lavora su questa griglia e poi la riscrive nella LevelDefinition,
## così il formato salvato resta quello letto dal gioco (LevelParser).

enum Layer { TILES, ENTITIES, ARROWS }

const LAYER_PROPERTIES: PackedStringArray = ["tiles_layout", "entities_layout", "arrows_layout"]

var size: Vector2i = Vector2i.ZERO
## Un array piatto di simboli per layer (indice = y * size.x + x).
var _layers: Array[PackedStringArray] = [PackedStringArray(), PackedStringArray(), PackedStringArray()]


## Legge i layout del livello. Righe mancanti o corte vengono completate con i simboli di default,
## quindi anche un livello vuoto o scritto a mano in modo incompleto si apre senza errori.
static func from_level(level: LevelDefinition, default_tile: String, empty_symbol: String) -> LevelLayoutGrid:
	var grid: LevelLayoutGrid = LevelLayoutGrid.new()
	var tile_rows: PackedStringArray = LevelParser.split_rows(level.tiles_layout)
	var width: int = 0
	for row: String in tile_rows:
		width = maxi(width, row.length())
	grid.size = Vector2i(width, tile_rows.size())

	var layouts: PackedStringArray = read_layouts(level)
	for layer: int in Layer.size():
		var rows: PackedStringArray = LevelParser.split_rows(layouts[layer])
		var fallback: String = default_tile if layer == Layer.TILES else empty_symbol
		var values: PackedStringArray = PackedStringArray()
		for cell: Vector2i in grid.get_all_cells():
			values.append(_symbol_in_rows(rows, cell, fallback))
		grid._layers[layer] = values
	return grid


func is_empty() -> bool:
	return size.x <= 0 or size.y <= 0


func is_inside(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < size.x and cell.y < size.y


func get_all_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for y: int in size.y:
		for x: int in size.x:
			cells.append(Vector2i(x, y))
	return cells


func get_symbol(layer: Layer, cell: Vector2i) -> String:
	return _get_symbol_at(layer, cell)


## Restituisce true se il simbolo è cambiato.
func set_symbol(layer: Layer, cell: Vector2i, symbol: String) -> bool:
	var values: PackedStringArray = _layers[layer]
	var index: int = _to_index(cell)
	if values[index] == symbol:
		return false
	values[index] = symbol
	_layers[layer] = values
	return true


func find_cells(layer: Layer, symbol: String) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for cell: Vector2i in get_all_cells():
		if get_symbol(layer, cell) == symbol:
			cells.append(cell)
	return cells


## Cambia la dimensione mantenendo il contenuto esistente (in alto a sinistra).
func resize(new_size: Vector2i, default_tile: String, empty_symbol: String) -> void:
	var resized: Array[PackedStringArray] = []
	for layer: int in Layer.size():
		var fallback: String = default_tile if layer == Layer.TILES else empty_symbol
		# Array locale: un PackedStringArray dentro un Array va riassegnato, non modificato sul posto.
		var values: PackedStringArray = PackedStringArray()
		for y: int in new_size.y:
			for x: int in new_size.x:
				var cell: Vector2i = Vector2i(x, y)
				values.append(_get_symbol_at(layer, cell) if is_inside(cell) else fallback)
		resized.append(values)
	size = new_size
	_layers = resized


## Testo di un layer: simboli separati da spazi, una riga per riga della board.
func to_layout(layer: Layer) -> String:
	var lines: PackedStringArray = PackedStringArray()
	for y: int in size.y:
		var symbols: PackedStringArray = PackedStringArray()
		for x: int in size.x:
			symbols.append(_get_symbol_at(layer, Vector2i(x, y)))
		lines.append(" ".join(symbols))
	return "\n".join(lines)


func get_layouts() -> PackedStringArray:
	return [to_layout(Layer.TILES), to_layout(Layer.ENTITIES), to_layout(Layer.ARROWS)]


func write_to(level: LevelDefinition) -> void:
	var layouts: PackedStringArray = get_layouts()
	for layer: int in Layer.size():
		level.set(LAYER_PROPERTIES[layer], layouts[layer])


static func read_layouts(level: LevelDefinition) -> PackedStringArray:
	return [level.tiles_layout, level.entities_layout, level.arrows_layout]


static func _symbol_in_rows(rows: PackedStringArray, cell: Vector2i, fallback: String) -> String:
	if cell.y < rows.size() and cell.x < rows[cell.y].length():
		return rows[cell.y][cell.x]
	return fallback


func _get_symbol_at(layer_index: int, cell: Vector2i) -> String:
	return _layers[layer_index][_to_index(cell)]


func _to_index(cell: Vector2i) -> int:
	assert(is_inside(cell), "Cella fuori dalla griglia: %s" % cell)
	return cell.y * size.x + cell.x
