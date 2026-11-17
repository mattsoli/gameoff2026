class_name TileView
extends Node2D
## Disegna una casella con freccia ed elemento. L'origine del nodo è il centro della casella.
## Usa le texture delle definizioni se presenti, altrimenti un placeholder generico.

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
		DrawUtils.draw_hatch(self, rect.grow(-4.0), _tile_size * HATCH_SPACING_RATIO, tile.accent_color)


func _draw_goal(rect: Rect2) -> void:
	var color: Color = cell_data.tile.accent_color
	var radius: float = rect.size.x * 0.3
	DrawUtils.draw_goal_rings(self, Vector2.ZERO, radius, color, 5.0)
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
		DrawUtils.draw_centered_text(self, definition.label, Vector2.ZERO, _tile_size, _settings.label_font_size, _settings.label_color)

	if entity is EnemyEntity:
		var enemy: EnemyEntity = entity as EnemyEntity
		var stats: String = "%d/%d" % [enemy.hp, enemy.get_enemy_definition().max_hp]
		var stats_position: Vector2 = Vector2(0.0, rect.end.y - _settings.label_font_size * 0.6)
		DrawUtils.draw_centered_text(self, stats, stats_position, _tile_size, int(_settings.label_font_size * 0.8), Color.WHITE)


## Freccia grande al centro se la casella è vuota, piccola nell'angolo se c'è un elemento.
func _draw_arrow() -> void:
	var has_entity: bool = cell_data.has_entity()
	var scale_factor: float = _tile_size * (0.45 if has_entity else 1.0)
	var center: Vector2 = Vector2(_tile_size * 0.28, -_tile_size * 0.28) if has_entity else Vector2.ZERO
	if has_entity:
		draw_circle(center, scale_factor * 0.42, _settings.board_color, true, -1.0, true)
	DrawUtils.draw_arrow(self, center, cell_data.arrow, scale_factor, _settings.arrow_color)
