@tool
class_name LevelGridView
extends Control
## Disegna la griglia del Level Editor e trasforma il mouse in "pennellate":
## tasto sinistro = dipingi, tasto destro = cancella, trascinando si dipingono più celle.
## Non modifica dati: emette segnali e il LevelEditorPanel decide cosa fare.

signal stroke_started
signal cell_painted(cell: Vector2i, is_erase: bool)
signal stroke_finished
signal cell_hovered(cell: Vector2i)

const INVALID_CELL: Vector2i = Vector2i(-1, -1)
const MIN_CELL_SIZE: float = 22.0
const MAX_CELL_SIZE: float = 64.0
const GAP: float = 2.0
const BACKGROUND_COLOR: Color = Color(0.08, 0.09, 0.11)
const ARROW_COLOR: Color = Color(1.0, 0.55, 0.2)
const PLAYER_COLOR: Color = Color(0.4, 0.6, 1.0)
const UNKNOWN_COLOR: Color = Color(1.0, 0.0, 1.0)
const HOVER_COLOR: Color = Color(1.0, 1.0, 1.0, 0.9)
const LABEL_COLOR: Color = Color(0.05, 0.05, 0.07)

var _grid: LevelLayoutGrid
var _legend: LevelLegend
var _cell_size: float = 32.0
var _origin: Vector2 = Vector2.ZERO
var _hovered_cell: Vector2i = INVALID_CELL
var _painting_button: MouseButton = MOUSE_BUTTON_NONE
var _last_painted_cell: Vector2i = INVALID_CELL


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	size_flags_horizontal = Control.SIZE_EXPAND_FILL


func setup(grid: LevelLayoutGrid, legend: LevelLegend) -> void:
	_grid = grid
	_legend = legend
	_update_layout()


func cell_to_rect(cell: Vector2i) -> Rect2:
	var position_in_grid: Vector2 = Vector2.ONE * GAP + Vector2(cell) * (_cell_size + GAP)
	return Rect2(_origin + position_in_grid, Vector2.ONE * _cell_size)


func local_to_cell(local_position: Vector2) -> Vector2i:
	if not _has_content():
		return INVALID_CELL
	var cell: Vector2i = Vector2i(((local_position - _origin - Vector2.ONE * GAP * 0.5) / (_cell_size + GAP)).floor())
	return cell if _grid.is_inside(cell) else INVALID_CELL


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_RESIZED:
			_update_layout()
		NOTIFICATION_MOUSE_EXIT:
			_set_hovered_cell(INVALID_CELL)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var button: InputEventMouseButton = event as InputEventMouseButton
		if button.button_index != MOUSE_BUTTON_LEFT and button.button_index != MOUSE_BUTTON_RIGHT:
			return
		if button.pressed and _painting_button == MOUSE_BUTTON_NONE:
			_painting_button = button.button_index
			_last_painted_cell = INVALID_CELL
			stroke_started.emit()
			_paint(local_to_cell(button.position))
			accept_event()
		elif not button.pressed and button.button_index == _painting_button:
			_painting_button = MOUSE_BUTTON_NONE
			stroke_finished.emit()
			accept_event()
	elif event is InputEventMouseMotion:
		var cell: Vector2i = local_to_cell((event as InputEventMouseMotion).position)
		_set_hovered_cell(cell)
		if _painting_button != MOUSE_BUTTON_NONE:
			_paint(cell)


func _paint(cell: Vector2i) -> void:
	if cell == INVALID_CELL or cell == _last_painted_cell:
		return
	_last_painted_cell = cell
	cell_painted.emit(cell, _painting_button == MOUSE_BUTTON_RIGHT)


func _set_hovered_cell(cell: Vector2i) -> void:
	if cell == _hovered_cell:
		return
	_hovered_cell = cell
	cell_hovered.emit(cell)
	queue_redraw()


## Adatta la dimensione delle celle alla larghezza dell'Inspector.
func _update_layout() -> void:
	if not _has_content():
		custom_minimum_size = Vector2.ZERO
		queue_redraw()
		return
	var columns: float = float(_grid.size.x)
	var fit: float = floorf((size.x - GAP) / columns - GAP)
	_cell_size = clampf(fit, MIN_CELL_SIZE, MAX_CELL_SIZE)
	var grid_size: Vector2 = _get_grid_pixel_size()
	custom_minimum_size = Vector2(Vector2(_grid.size).x * (MIN_CELL_SIZE + GAP) + GAP, grid_size.y)
	_origin = Vector2(maxf((size.x - grid_size.x) * 0.5, 0.0), 0.0)
	queue_redraw()


func _get_grid_pixel_size() -> Vector2:
	return Vector2(_grid.size) * (_cell_size + GAP) + Vector2.ONE * GAP


func _has_content() -> bool:
	return _grid != null and _legend != null and not _grid.is_empty()


func _draw() -> void:
	if not _has_content():
		return
	draw_rect(Rect2(_origin, _get_grid_pixel_size()), BACKGROUND_COLOR)
	for cell: Vector2i in _grid.get_all_cells():
		_draw_cell(cell)
	if _hovered_cell != INVALID_CELL:
		draw_rect(cell_to_rect(_hovered_cell).grow(1.0), HOVER_COLOR, false, 2.0)


func _draw_cell(cell: Vector2i) -> void:
	var rect: Rect2 = cell_to_rect(cell)
	_draw_tile_layer(rect, _grid.get_symbol(LevelLayoutGrid.Layer.TILES, cell))
	var has_entity: bool = _draw_entity_layer(rect, _grid.get_symbol(LevelLayoutGrid.Layer.ENTITIES, cell))
	_draw_arrow_layer(rect, _grid.get_symbol(LevelLayoutGrid.Layer.ARROWS, cell), has_entity)


func _draw_tile_layer(rect: Rect2, symbol: String) -> void:
	if not _legend.tiles.has(symbol):
		_draw_unknown(rect, symbol)
		return
	var tile: TileDefinition = _legend.tiles[symbol]
	if tile.texture != null:
		draw_texture_rect(tile.texture, rect, false)
	else:
		draw_rect(rect, tile.color)
		if tile.pattern == TileDefinition.Pattern.HATCHED:
			DrawUtils.draw_hatch(self, rect.grow(-2.0), _cell_size * 0.2, tile.accent_color, 1.0)
	if tile.is_goal:
		DrawUtils.draw_goal_rings(self, rect.get_center(), _cell_size * 0.32, tile.accent_color, maxf(_cell_size * 0.06, 1.5))


## Restituisce true se nella cella c'è un elemento (la freccia va allora nell'angolo).
func _draw_entity_layer(rect: Rect2, symbol: String) -> bool:
	if symbol == _legend.empty_symbol:
		return false
	var center: Vector2 = rect.get_center()
	var radius: float = _cell_size * 0.3
	if symbol == _legend.player_start_symbol:
		draw_circle(center, radius, PLAYER_COLOR, true, -1.0, true)
		_draw_label("P", center)
		return true
	if not _legend.entities.has(symbol):
		_draw_unknown(rect, symbol)
		return true
	var definition: EntityDefinition = _legend.entities[symbol]
	if definition.texture != null:
		draw_texture_rect(definition.texture, rect.grow(-_cell_size * 0.2), false)
	else:
		draw_circle(center, radius, definition.color, true, -1.0, true)
		_draw_label(definition.label, center)
	return true


func _draw_arrow_layer(rect: Rect2, symbol: String, has_entity: bool) -> void:
	if symbol == _legend.empty_symbol:
		return
	var direction: Direction.Type = _legend.get_arrow_direction(symbol)
	if direction == Direction.Type.NONE:
		_draw_unknown(rect, symbol)
		return
	if has_entity:
		var corner: Vector2 = rect.position + Vector2(rect.size.x * 0.78, rect.size.y * 0.22)
		draw_circle(corner, _cell_size * 0.2, BACKGROUND_COLOR, true, -1.0, true)
		DrawUtils.draw_arrow(self, corner, direction, _cell_size * 0.45, ARROW_COLOR)
	else:
		DrawUtils.draw_arrow(self, rect.get_center(), direction, _cell_size, ARROW_COLOR)


## Simbolo non presente nella legenda: cella evidenziata in magenta.
func _draw_unknown(rect: Rect2, symbol: String) -> void:
	draw_rect(rect, UNKNOWN_COLOR, false, 2.0)
	_draw_label(symbol, rect.get_center(), UNKNOWN_COLOR)


func _draw_label(text: String, center: Vector2, color: Color = LABEL_COLOR) -> void:
	DrawUtils.draw_centered_text(self, text, center, _cell_size, int(_cell_size * 0.4), color)
