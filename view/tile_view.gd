class_name TileView
extends Node2D

var tile: TileInstance
var _size: float = 0.0
var _selected: bool = false


func setup(p_tile: TileInstance, p_size: float) -> void:
	tile = p_tile
	_size = p_size
	var texture: Texture2D = tile.definition.texture
	if texture != null:
		var sprite: Sprite2D = Sprite2D.new()
		sprite.texture = texture
		sprite.scale = Vector2(_size / texture.get_width(), _size / texture.get_height())
		add_child(sprite)
	queue_redraw()


func set_selected(value: bool) -> void:
	_selected = value
	queue_redraw()


func _draw() -> void:
	if tile == null:
		return
	var half: float = _size * 0.5
	var rect: Rect2 = Rect2(-half + 2.0, -half + 2.0, _size - 4.0, _size - 4.0)

	if tile.definition.texture == null:
		_draw_placeholder(rect, half)

	if _selected:
		draw_rect(rect.grow(2.0), Color.YELLOW, false, 4.0)


func _draw_placeholder(rect: Rect2, half: float) -> void:
	var definition: TileDefinition = tile.definition
	var fill: Color = definition.debug_color
	if not definition.is_accessible:
		fill = fill.darkened(0.6)
	draw_rect(rect, fill)
	draw_rect(rect, Color.BLACK, false, 2.0)

	if not definition.is_accessible:
		draw_line(rect.position, rect.end, Color.BLACK, 3.0)
		draw_line(Vector2(rect.end.x, rect.position.y), Vector2(rect.position.x, rect.end.y), Color.BLACK, 3.0)

	if definition.direction != Direction.Type.NONE:
		var dir: Vector2 = Vector2(Direction.to_vector(definition.direction))
		var perp: Vector2 = Vector2(-dir.y, dir.x)
		var tip: Vector2 = dir * half * 0.5
		draw_line(-tip, tip, Color.WHITE, 4.0)
		draw_line(tip, tip - dir * half * 0.3 + perp * half * 0.25, Color.WHITE, 4.0)
		draw_line(tip, tip - dir * half * 0.3 - perp * half * 0.25, Color.WHITE, 4.0)
