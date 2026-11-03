class_name GoalView
extends Node2D

var _radius: float = 0.0


## Le coordinate sono locali al BoardView (stesso spazio di cell_to_local).
func setup(goal: GoalDefinition, board_size: Vector2i, tile_size: float) -> void:
	_radius = tile_size * 0.35
	var along: float = (goal.line_index + 0.5) * tile_size
	match goal.exit_side:
		Direction.Type.RIGHT:
			position = Vector2((board_size.x + 0.5) * tile_size, along)
		Direction.Type.LEFT:
			position = Vector2(-0.5 * tile_size, along)
		Direction.Type.DOWN:
			position = Vector2(along, (board_size.y + 0.5) * tile_size)
		Direction.Type.UP:
			position = Vector2(along, -0.5 * tile_size)
		_:
			push_error("exit_side non valido")
	queue_redraw()


func _draw() -> void:
	var points: PackedVector2Array = PackedVector2Array([
		Vector2(0.0, -_radius), Vector2(_radius, 0.0),
		Vector2(0.0, _radius), Vector2(-_radius, 0.0),
	])
	draw_colored_polygon(points, Color.GOLD)
	draw_polyline(points + PackedVector2Array([points[0]]), Color.BLACK, 2.0)
