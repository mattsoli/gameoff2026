class_name PawnView
extends Node2D
## Pedina del giocatore. L'origine del nodo è il centro della casella.
## Se il PlayerDefinition ha una board_scene la mostra (con le sue animazioni),
## altrimenti disegna texture o cerchio di prova. Il valore di attacco sta sempre sopra.

const RADIUS_RATIO: float = 0.3

var _definition: PlayerDefinition
var _tile_size: float = 0.0
var _font_size: int = 22
var _attack: int = 0
var _visual: SceneVisual
## Livello sopra la scena animata: solo il riquadro con il valore di attacco.
var _badge_layer: Node2D = Node2D.new()


func setup(definition: PlayerDefinition, tile_size: float, font_size: int, scene_reference_size: float) -> void:
	_definition = definition
	_tile_size = tile_size
	_font_size = font_size
	_visual = SceneVisual.create(definition.board_scene, self, scene_reference_size, tile_size)
	add_child(_badge_layer)
	_badge_layer.draw.connect(_draw_badge)
	queue_redraw()


## Valore di attacco disegnato sulla pedina.
func set_attack(value: int) -> void:
	_attack = value
	_badge_layer.queue_redraw()


## Animazione "move" della scena (il movimento sulla board lo fa BoardView).
func play_move_animation() -> void:
	if _visual != null:
		_visual.play(SceneVisual.MOVE)


## Feedback di movimento impossibile: piccolo scatto verso la direzione e ritorno.
## `animation` vale sia per l'andata che per il ritorno; in parallelo parte "bump" della scena.
func play_bump(direction: Direction.Type, distance: float, animation: UiAnimation) -> void:
	var started: int = Time.get_ticks_msec()
	var scene_length: float = _visual.play_one_shot(SceneVisual.BUMP) if _visual != null else 0.0
	var origin: Vector2 = position
	var offset: Vector2 = Vector2(Direction.to_vector(direction)) * _tile_size * distance
	var tween: Tween = create_tween()
	UiAnimation.tween_property(tween, self, "position", origin + offset, animation)
	UiAnimation.tween_property(tween, self, "position", origin, animation)
	await tween.finished
	await SceneVisual.wait_remaining(get_tree(), started, scene_length)


func _draw() -> void:
	if _definition == null or _visual != null:
		return
	var radius: float = _tile_size * RADIUS_RATIO
	if _definition.board_texture != null:
		var rect: Rect2 = Rect2(-Vector2.ONE * radius, Vector2.ONE * radius * 2.0)
		draw_texture_rect(_definition.board_texture, rect, false)
	else:
		draw_circle(Vector2(0.0, radius * 0.15), radius, _definition.color.darkened(0.45), true, -1.0, true)
		draw_circle(Vector2.ZERO, radius, _definition.color, true, -1.0, true)


func _draw_badge() -> void:
	DrawUtils.draw_attack_badge(_badge_layer, Vector2(0.0, _tile_size * 0.36), _attack, _font_size)
