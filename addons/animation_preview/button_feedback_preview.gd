@tool
class_name ButtonFeedbackPreview
extends Control
## Anteprima in loop di un ButtonFeedback, mostrata nell'Inspector:
## un pulsante di esempio passa da riposo -> mouse sopra -> premuto -> mouse sopra -> riposo,
## con gli effetti e i tempi configurati. Legge la risorsa a ogni frame (si aggiorna mentre la modifichi).
## La scena animata facoltativa non viene mostrata qui: si prova in gioco.

const PREVIEW_HEIGHT: float = 140.0
const BUTTON_SIZE: Vector2 = Vector2(180.0, 52.0)
## Pausa in ogni stato prima di passare al successivo.
const HOLD_TIME: float = 0.5

const BACKGROUND_COLOR: Color = Color(0.1, 0.11, 0.13)
const BUTTON_COLOR: Color = Color(0.3, 0.32, 0.38)
const OUTLINE_COLOR: Color = Color(1.0, 1.0, 1.0, 0.15)
const TEXT_COLOR: Color = Color(0.9, 0.9, 0.95)
const LABEL_COLOR: Color = Color(0.85, 0.6, 0.3)

## Sequenza mostrata: [stato di arrivo, usa i tempi della pressione].
const STEPS: Array[Dictionary] = [
	{ "state": "hover", "press": false },
	{ "state": "pressed", "press": true },
	{ "state": "hover", "press": true },
	{ "state": "rest", "press": false },
]

var feedback: ButtonFeedback

var _time: float = 0.0
var _button_style: StyleBoxFlat = StyleBoxFlat.new()


func _init() -> void:
	custom_minimum_size = Vector2(0.0, PREVIEW_HEIGHT)
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_button_style.bg_color = BUTTON_COLOR
	_button_style.set_corner_radius_all(8)


func _process(delta: float) -> void:
	if feedback == null or not is_visible_in_tree():
		return
	_time += delta
	if _time > _get_cycle_length():
		_time = 0.0
	queue_redraw()


func _draw() -> void:
	if feedback == null:
		return
	draw_rect(Rect2(Vector2.ZERO, size), BACKGROUND_COLOR)
	var center: Vector2 = size * 0.5 + Vector2(0.0, 8.0)
	# Contorno: posizione e dimensione del pulsante a riposo.
	draw_rect(Rect2(center - BUTTON_SIZE * 0.5, BUTTON_SIZE), OUTLINE_COLOR, false, 1.0)

	var look: Dictionary = _get_current_look()
	var phase_name: String = look["phase"]
	var font: Font = get_theme_default_font()
	draw_string(font, Vector2(8.0, 18.0), "Button preview · %s" % phase_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, LABEL_COLOR)

	var offset: Vector2 = look["offset"]
	var look_scale: Vector2 = look["scale"]
	var rotation_degrees: float = look["rotation"]
	var tint: Color = look["tint"]
	draw_set_transform(center + offset, deg_to_rad(rotation_degrees), look_scale)
	_button_style.bg_color = BUTTON_COLOR * tint
	draw_style_box(_button_style, Rect2(-BUTTON_SIZE * 0.5, BUTTON_SIZE))
	var baseline: float = (font.get_ascent(16) - font.get_descent(16)) * 0.5
	draw_string(font, Vector2(-BUTTON_SIZE.x * 0.5, baseline), "Button", HORIZONTAL_ALIGNMENT_CENTER, BUTTON_SIZE.x, 16, TEXT_COLOR * tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Aspetto del pulsante al tempo corrente del loop, interpolato con la curva dello step in corso.
func _get_current_look() -> Dictionary:
	var previous_state: String = "rest"
	var step_start: float = HOLD_TIME
	for step: Dictionary in STEPS:
		var state: String = step["state"]
		var is_press: bool = step["press"]
		var animation: UiAnimation = feedback.press_animation if is_press else feedback.hover_animation
		var length: float = _get_animation_length(animation)
		if _time < step_start + length + HOLD_TIME:
			var progress: float = _progress(animation, _time - step_start)
			return _blend(_look_of(previous_state), _look_of(state), progress, state)
		previous_state = state
		step_start += length + HOLD_TIME
	return _blend(_look_of("rest"), _look_of("rest"), 1.0, "rest")


func _get_cycle_length() -> float:
	var total: float = HOLD_TIME
	for step: Dictionary in STEPS:
		var is_press: bool = step["press"]
		total += _get_animation_length(feedback.press_animation if is_press else feedback.hover_animation) + HOLD_TIME
	return total


func _get_animation_length(animation: UiAnimation) -> float:
	return 0.0 if animation == null else animation.delay + animation.duration


func _progress(animation: UiAnimation, elapsed: float) -> float:
	if animation == null:
		return 1.0
	var local_time: float = elapsed - animation.delay
	if local_time <= 0.0:
		return 0.0
	if animation.duration <= 0.0 or local_time >= animation.duration:
		return 1.0
	var value: float = Tween.interpolate_value(0.0, 1.0, local_time, animation.duration, animation.transition, animation.easing)
	return value


func _look_of(state: String) -> ButtonStateEffect:
	match state:
		"hover":
			return feedback.hover
		"pressed":
			return feedback.pressed
		_:
			return null


func _blend(from: ButtonStateEffect, to: ButtonStateEffect, progress: float, phase: String) -> Dictionary:
	var neutral: ButtonStateEffect = ButtonStateEffect.new()
	var start: ButtonStateEffect = from if from != null else neutral
	var end: ButtonStateEffect = to if to != null else neutral
	return {
		"phase": phase,
		"scale": start.scale.lerp(end.scale, progress),
		"offset": start.offset.lerp(end.offset, progress),
		"rotation": lerpf(start.rotation_degrees, end.rotation_degrees, progress),
		"tint": start.tint.lerp(end.tint, clampf(progress, 0.0, 1.0)),
	}
