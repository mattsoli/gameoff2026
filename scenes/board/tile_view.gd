class_name TileView
extends Node2D
## Disegna una casella con freccia ed elemento. L'origine del nodo è il centro della casella.
## Usa le texture delle definizioni se presenti, altrimenti un placeholder generico.

const ARROW_SHAPE: PackedVector2Array = [
	Vector2(-0.32, -0.08), Vector2(0.04, -0.08), Vector2(0.04, -0.2), Vector2(0.32, 0.0),
	Vector2(0.04, 0.2), Vector2(0.04, 0.08), Vector2(-0.32, 0.08),
]
const HATCH_SPACING_RATIO: float = 0.12

var cell_data: CellData

var _settings: BoardVisualSettings
var _tile_size: float = 0.0
var _goal_unlocked: bool = false
var _tile_style: StyleBoxFlat = StyleBoxFlat.new()


func setup(data: CellData, settings: BoardVisualSettings, tile_size: float) -> void:
	cell_data = data
	_settings = settings
	_tile_size = tile_size
	_tile_style.set_corner_radius_all(settings.tile_corner_radius)
	queue_redraw()


func set_goal_unlocked(value: bool) -> void:
	if _goal_unlocked == value:
		return
	_goal_unlocked = value
	queue_redraw()


## Da chiamare quando cambia il contenuto della cella (chiave raccolta, baule aperto...).
func refresh() -> void:
	queue_redraw()


func _draw() -> void:
	if cell_data == null:
		return
	var rect: Rect2 = Rect2(Vector2.ONE * -_tile_size * 0.5, Vector2.ONE * _tile_size)
	_draw_tile(rect)
	if cell_data.tile.is_goal:
		_draw_goal(rect)
	if cell_data.has_entity():
		_draw_entity(rect)
	if cell_data.has_arrow():
		_draw_arrow()


func _draw_tile(rect: Rect2) -> void:
	var tile: TileDefinition = cell_data.tile
	if tile.texture != null:
		draw_texture_rect(tile.texture, rect, false)
		return
	_tile_style.bg_color = tile.color
	draw_style_box(_tile_style, rect)
	if tile.pattern == TileDefinition.Pattern.HATCHED:
		_draw_hatch(rect.grow(-4.0), tile.accent_color)


## Righe diagonali ritagliate dentro il rettangolo.
func _draw_hatch(rect: Rect2, color: Color) -> void:
	var spacing: float = _tile_size * HATCH_SPACING_RATIO
	var start: float = rect.position.x + rect.position.y
	var end: float = rect.end.x + rect.end.y
	var offset: float = start + spacing
	while offset < end:
		var x_from: float = maxf(rect.position.x, offset - rect.end.y)
		var x_to: float = minf(rect.end.x, offset - rect.position.y)
		draw_line(Vector2(x_from, offset - x_from), Vector2(x_to, offset - x_to), color, 2.0, true)
		offset += spacing


func _draw_goal(rect: Rect2) -> void:
	var color: Color = cell_data.tile.accent_color
	var radius: float = rect.size.x * 0.3
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 48, color, 5.0, true)
	draw_arc(Vector2.ZERO, radius * 0.6, 0.0, TAU, 48, color, 5.0, true)
	draw_circle(Vector2.ZERO, radius * 0.22, color)
	if not _goal_unlocked:
		_draw_lock(rect.end - Vector2.ONE * rect.size.x * 0.2, rect.size.x * 0.1, color)


func _draw_lock(center: Vector2, half_size: float, color: Color) -> void:
	var body: Rect2 = Rect2(center - Vector2(half_size, 0.0), Vector2(half_size * 2.0, half_size * 1.4))
	draw_rect(body, color)
	draw_arc(center, half_size * 0.65, PI, TAU, 16, color, 3.0, true)


func _draw_entity(rect: Rect2) -> void:
	var entity: BoardEntity = cell_data.entity
	var definition: EntityDefinition = entity.definition
	var alpha: float = 1.0
	if entity is ChestEntity and (entity as ChestEntity).is_opened:
		alpha = (entity as ChestEntity).get_chest_definition().opened_alpha

	var icon_rect: Rect2 = rect.grow(-rect.size.x * 0.2)
	if definition.texture != null:
		draw_texture_rect(definition.texture, icon_rect, false, Color(1.0, 1.0, 1.0, alpha))
	else:
		var color: Color = definition.color
		color.a = alpha
		draw_circle(Vector2.ZERO, icon_rect.size.x * 0.5, color, true, -1.0, true)
		_draw_centered_text(definition.label, Vector2.ZERO, _settings.label_font_size, _settings.label_color)

	if entity is EnemyEntity:
		var enemy: EnemyEntity = entity as EnemyEntity
		var stats: String = "%d/%d" % [enemy.hp, enemy.get_enemy_definition().max_hp]
		var stats_position: Vector2 = Vector2(0.0, rect.end.y - _settings.label_font_size * 0.6)
		_draw_centered_text(stats, stats_position, int(_settings.label_font_size * 0.8), Color.WHITE)


## Freccia grande al centro se la casella è vuota, piccola nell'angolo se c'è un elemento.
func _draw_arrow() -> void:
	var has_entity: bool = cell_data.has_entity()
	var scale_factor: float = _tile_size * (0.45 if has_entity else 1.0)
	var center: Vector2 = Vector2(_tile_size * 0.28, -_tile_size * 0.28) if has_entity else Vector2.ZERO
	if has_entity:
		draw_circle(center, scale_factor * 0.42, _settings.board_color, true, -1.0, true)
	draw_set_transform(center, Direction.to_angle(cell_data.arrow), Vector2.ONE * scale_factor)
	draw_colored_polygon(ARROW_SHAPE, _settings.arrow_color)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_centered_text(text: String, center: Vector2, font_size: int, color: Color) -> void:
	if text.is_empty():
		return
	var font: Font = ThemeDB.fallback_font
	var baseline: float = center.y + (font.get_ascent(font_size) - font.get_descent(font_size)) * 0.5
	draw_string(font, Vector2(-_tile_size * 0.5, baseline), text, HORIZONTAL_ALIGNMENT_CENTER, _tile_size, font_size, color)
