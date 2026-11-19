class_name PawnView
extends Node2D
## Pedina del giocatore. L'origine del nodo è il centro della casella.

const RADIUS_RATIO: float = 0.3

var _definition: PlayerDefinition
var _tile_size: float = 0.0
var _font_size: int = 22
var _attack: int = 0


func setup(definition: PlayerDefinition, tile_size: float, font_size: int) -> void:
	_definition = definition
	_tile_size = tile_size
	_font_size = font_size
	queue_redraw()


## Valore di attacco disegnato sulla pedina.
func set_attack(value: int) -> void:
	_attack = value
	queue_redraw()


## Feedback di movimento impossibile: piccolo scatto verso la direzione e ritorno.
func play_bump(direction: Direction.Type, distance: float, duration: float) -> void:
	var origin: Vector2 = position
	var offset: Vector2 = Vector2(Direction.to_vector(direction)) * _tile_size * distance
	var tween: Tween = create_tween()
	tween.tween_property(self, "position", origin + offset, duration * 0.4).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", origin, duration * 0.6).set_ease(Tween.EASE_IN)
	await tween.finished


func _draw() -> void:
	if _definition == null:
		return
	var radius: float = _tile_size * RADIUS_RATIO
	if _definition.board_texture != null:
		var rect: Rect2 = Rect2(-Vector2.ONE * radius, Vector2.ONE * radius * 2.0)
		draw_texture_rect(_definition.board_texture, rect, false)
	else:
		draw_circle(Vector2(0.0, radius * 0.15), radius, _definition.color.darkened(0.45), true, -1.0, true)
		draw_circle(Vector2.ZERO, radius, _definition.color, true, -1.0, true)
	DrawUtils.draw_attack_badge(self, Vector2(0.0, _tile_size * 0.36), _attack, _font_size)
