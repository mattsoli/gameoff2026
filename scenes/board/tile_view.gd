class_name TileView
extends Node2D
## Disegna una casella con freccia ed elemento. L'origine del nodo è il centro della casella.
## Casella ed elemento possono essere scene animate dai Designer (board_scene), altrimenti
## si usano le texture delle definizioni o un disegno di prova.
##
## Livelli, dal basso verso l'alto (i figli si disegnano sopra il _draw del padre):
##   casella disegnata (_draw) -> scena della casella -> freccia -> elemento -> valore di attacco.

const HATCH_SPACING_RATIO: float = 0.12

var cell_data: CellData

var _settings: BoardVisualSettings
var _tile_size: float = 0.0
var _goal_unlocked: bool = false
var _tile_style: StyleBoxFlat = StyleBoxFlat.new()

var _tile_visual: SceneVisual
var _arrow_layer: Node2D = Node2D.new()
var _entity_layer: Node2D = Node2D.new()
var _badge_layer: Node2D = Node2D.new()
var _entity_visual: SceneVisual
## L'elemento mostrato da _entity_visual: se sparisce dalla cella, la sua scena esce di scena.
var _entity_visual_owner: BoardEntity


func setup(data: CellData, settings: BoardVisualSettings, tile_size: float) -> void:
	cell_data = data
	_settings = settings
	_tile_size = tile_size
	_tile_style.set_corner_radius_all(settings.tile_corner_radius)

	_tile_visual = SceneVisual.create(data.tile.board_scene, self, settings.scene_reference_size, tile_size)
	for layer: Node2D in [_arrow_layer, _entity_layer, _badge_layer]:
		add_child(layer)
	_arrow_layer.draw.connect(_draw_arrow_layer)
	_entity_layer.draw.connect(_draw_entity_layer)
	_badge_layer.draw.connect(_draw_badge_layer)
	refresh()


## `animate` = false per impostare lo stato iniziale senza far partire "unlock".
func set_goal_unlocked(value: bool, animate: bool = true) -> void:
	if _goal_unlocked == value:
		return
	_goal_unlocked = value
	if _tile_visual != null and cell_data.tile.is_goal and value:
		if not animate or not _tile_visual.play(SceneVisual.UNLOCK):
			_tile_visual.play(SceneVisual.UNLOCKED)
	queue_redraw()


## Da chiamare quando cambia il contenuto della cella (chiave raccolta, nemico sconfitto...).
func refresh() -> void:
	_sync_entity_visual()
	queue_redraw()
	_arrow_layer.queue_redraw()
	_entity_layer.queue_redraw()
	_badge_layer.queue_redraw()


## Crea la scena dell'elemento presente o fa uscire quella di un elemento che non c'è più.
func _sync_entity_visual() -> void:
	var entity: BoardEntity = cell_data.entity
	if entity == _entity_visual_owner:
		return
	if _entity_visual != null:
		var exit_animation: StringName = SceneVisual.DEFEAT if _entity_visual_owner is EnemyEntity else SceneVisual.PICKUP
		_remove_visual(_entity_visual, exit_animation)
		_entity_visual = null
	_entity_visual_owner = entity
	if entity != null:
		_entity_visual = SceneVisual.create(entity.definition.board_scene, _entity_layer, _settings.scene_reference_size, _tile_size)


func _remove_visual(visual: SceneVisual, exit_animation: StringName) -> void:
	await visual.play_and_wait(exit_animation)
	visual.destroy()


func _draw() -> void:
	if cell_data == null or _tile_visual != null:
		return
	var rect: Rect2 = _get_rect()
	_draw_tile(rect)
	if cell_data.tile.is_goal:
		_draw_goal(rect)


func _get_rect() -> Rect2:
	return Rect2(Vector2.ONE * -_tile_size * 0.5, Vector2.ONE * _tile_size)


func _draw_tile(rect: Rect2) -> void:
	var tile: TileDefinition = cell_data.tile
	var texture: Texture2D = tile.get_texture(cell_data.variant_seed)
	if texture != null:
		draw_texture_rect(texture, rect, false)
		return
	_tile_style.bg_color = tile.color
	draw_style_box(_tile_style, rect)
	if tile.pattern == TileDefinition.Pattern.HATCHED:
		DrawUtils.draw_hatch(self, rect.grow(-4.0), _tile_size * HATCH_SPACING_RATIO, tile.accent_color)


func _draw_goal(rect: Rect2) -> void:
	var tile: TileDefinition = cell_data.tile
	if not _goal_unlocked:
		if tile.texture_locked != null:
			var icon_rect: Rect2 = rect.grow(-rect.size.x * 0.2)
			draw_texture_rect(tile.texture_locked, icon_rect, false)
		else:
			var color: Color = cell_data.tile.accent_color
			_draw_lock(rect.end - Vector2.ONE * rect.size.x * 0.2, rect.size.x * 0.1, color)
	else:
		if tile.texture_unlocked != null:
			var icon_rect: Rect2 = rect.grow(-rect.size.x * 0.2)
			draw_texture_rect(tile.texture_unlocked, icon_rect, false)


func _draw_lock(center: Vector2, half_size: float, color: Color) -> void:
	var body: Rect2 = Rect2(center - Vector2(half_size, 0.0), Vector2(half_size * 2.0, half_size * 1.4))
	draw_rect(body, color)
	draw_arc(center, half_size * 0.65, PI, TAU, 16, color, 3.0, true)


## Freccia grande al centro se la casella è vuota, piccola nell'angolo se c'è un elemento.
func _draw_arrow_layer() -> void:
	if cell_data == null or not cell_data.has_arrow():
		return
	var has_entity: bool = cell_data.has_entity()
	var scale_factor: float = _tile_size * (0.45 if has_entity else 1.0)
	var center: Vector2 = Vector2(_tile_size * 0.28, -_tile_size * 0.28) if has_entity else Vector2.ZERO
	if has_entity:
		_arrow_layer.draw_circle(center, scale_factor * 0.42, _settings.board_color, true, -1.0, true)
	DrawUtils.draw_arrow(_arrow_layer, center, cell_data.arrow, scale_factor, _settings.arrow, _get_rect())


## Elemento disegnato (texture o icona di prova) quando non ha una scena animata.
func _draw_entity_layer() -> void:
	if cell_data == null or not cell_data.has_entity() or _entity_visual != null:
		return
	var definition: EntityDefinition = cell_data.entity.definition
	var icon_rect: Rect2 = _get_rect().grow(-_tile_size * 0.2)
	if definition.texture != null:
		_entity_layer.draw_texture_rect(definition.texture, icon_rect, false)
	else:
		_entity_layer.draw_circle(Vector2.ZERO, icon_rect.size.x * 0.5, definition.color, true, -1.0, true)
		DrawUtils.draw_centered_text(_entity_layer, definition.label, Vector2.ZERO, _tile_size, _settings.label_font_size, _settings.label_color)


## Valore di attacco visibile sulla griglia: dei nemici e, con il "+", delle armi.
func _draw_badge_layer() -> void:
	if cell_data == null or not cell_data.has_entity():
		return
	var entity: BoardEntity = cell_data.entity
	var badge_position: Vector2 = Vector2(0.0, _get_rect().end.y - _settings.label_font_size * 0.7)
	if entity is EnemyEntity:
		var enemy_attack: int = (entity as EnemyEntity).get_enemy_definition().attack
		DrawUtils.draw_attack_badge(_badge_layer, badge_position, enemy_attack, _settings.label_font_size)
	elif entity is WeaponEntity:
		var bonus: int = (entity as WeaponEntity).get_weapon_definition().attack_bonus
		DrawUtils.draw_attack_badge(_badge_layer, badge_position, bonus, _settings.label_font_size, "+")
