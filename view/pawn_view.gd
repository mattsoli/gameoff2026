class_name PawnView
extends Node2D

const RADIUS: float = 16.0

var _facing: Vector2 = Vector2.ZERO
var _intent: PawnState.Intent = PawnState.Intent.NONE
var _intent_direction: Vector2 = Vector2.ZERO


func set_facing(direction: Direction.Type) -> void:
	_facing = Vector2(Direction.to_vector(direction))
	queue_redraw()


func set_intent(intent: PawnState.Intent, direction: Direction.Type) -> void:
	_intent = intent
	_intent_direction = Vector2(Direction.to_vector(direction))
	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2.ZERO, RADIUS, Color.CORNFLOWER_BLUE)
	draw_arc(Vector2.ZERO, RADIUS, 0.0, TAU, 24, Color.BLACK, 2.0)
	draw_circle(_facing * RADIUS * 0.6, 4.0, Color.WHITE)

	if _intent == PawnState.Intent.NONE:
		return
	var color: Color = Color.GREEN if _intent == PawnState.Intent.MOVE else Color.ORANGE
	var perp: Vector2 = Vector2(-_intent_direction.y, _intent_direction.x)
	var start: Vector2 = _intent_direction * (RADIUS + 4.0)
	var tip: Vector2 = _intent_direction * (RADIUS + 22.0)
	draw_line(start, tip, color, 4.0)
	draw_line(tip, tip - _intent_direction * 8.0 + perp * 6.0, color, 4.0)
	draw_line(tip, tip - _intent_direction * 8.0 - perp * 6.0, color, 4.0)
	if _intent == PawnState.Intent.ROTATE:
		draw_arc(Vector2.ZERO, RADIUS + 6.0, 0.0, TAU, 24, color, 2.0)
