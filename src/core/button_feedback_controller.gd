class_name ButtonFeedbackController
extends RefCounted
## Applica un ButtonFeedback a un pulsante: segue gli eventi del mouse, decide lo stato
## (riposo / mouse sopra / premuto) e anima il pulsante verso l'aspetto di quello stato.
## Si crea con attach(); resta vivo finché esiste il pulsante (è salvato nei suoi metadati).

enum State { REST, HOVER, PRESSED }

const META_KEY: StringName = &"button_feedback_controller"

var _button: BaseButton
var _feedback: ButtonFeedback
var _visual: SceneVisual
var _is_hovered: bool = false
var _is_pressed: bool = false
var _state: State = State.REST
var _tween: Tween
## Posizione a riposo, rilevata ogni volta che il pulsante lascia il riposo
## (i Container possono averlo spostato nel frattempo, es. una finestra ridimensionata).
var _rest_position: Vector2


## Collega il feedback al pulsante. `feedback` null = nessuna reazione.
static func attach(button: BaseButton, feedback: ButtonFeedback) -> void:
	if feedback == null:
		return
	var controller: ButtonFeedbackController = ButtonFeedbackController.new()
	controller._button = button
	controller._feedback = feedback
	button.set_meta(META_KEY, controller)
	controller._connect_signals()
	controller._create_visual()
	controller._center_pivot()


func _connect_signals() -> void:
	_button.resized.connect(_center_pivot)
	_button.mouse_entered.connect(_on_mouse_entered)
	_button.mouse_exited.connect(_on_mouse_exited)
	_button.button_down.connect(_on_button_down)
	_button.button_up.connect(_on_button_up)


func _create_visual() -> void:
	_visual = SceneVisual.create(_feedback.scene, _button, 1.0, 1.0)
	if _visual != null and _visual.root is CanvasItem:
		(_visual.root as CanvasItem).show_behind_parent = _feedback.scene_behind_button


## Rotazione e scala avvengono attorno al centro; la scena animata sta al centro del pulsante.
func _center_pivot() -> void:
	_button.pivot_offset = _button.size * 0.5
	if _visual != null and _visual.root is Node2D:
		(_visual.root as Node2D).position = _button.size * 0.5


func _on_mouse_entered() -> void:
	_is_hovered = true
	_play_scene(SceneVisual.HOVER)
	_update_state()


func _on_mouse_exited() -> void:
	_is_hovered = false
	_play_scene(SceneVisual.UNHOVER)
	_update_state()


func _on_button_down() -> void:
	_is_pressed = true
	_play_scene(SceneVisual.PRESSED)
	_update_state()


func _on_button_up() -> void:
	_is_pressed = false
	_play_scene(SceneVisual.RELEASED)
	_update_state()


func _play_scene(animation_name: StringName) -> void:
	if _visual != null:
		_visual.play(animation_name)


func _update_state() -> void:
	var new_state: State = State.REST
	if _button.disabled:
		new_state = State.REST
	elif _is_pressed:
		new_state = State.PRESSED
	elif _is_hovered:
		new_state = State.HOVER
	if new_state == _state:
		return
	# Da/verso "premuto" si usano i tempi della pressione, altrimenti quelli del mouse sopra.
	var uses_press_timing: bool = new_state == State.PRESSED or _state == State.PRESSED
	var is_leaving_rest: bool = _state == State.REST
	_state = new_state
	_animate_to(_get_effect(new_state), _feedback.press_animation if uses_press_timing else _feedback.hover_animation, is_leaving_rest)


func _get_effect(state: State) -> ButtonStateEffect:
	match state:
		State.HOVER:
			return _feedback.hover
		State.PRESSED:
			return _feedback.pressed
		_:
			return null


func _animate_to(effect: ButtonStateEffect, animation: UiAnimation, is_leaving_rest: bool) -> void:
	var was_animating: bool = _tween != null and _tween.is_valid() and _tween.is_running()
	if _tween != null and _tween.is_valid():
		_tween.kill()
	# Se il pulsante era fermo a riposo la sua posizione attuale è quella di riposo.
	if is_leaving_rest and not was_animating:
		_rest_position = _button.position
	var target_scale: Vector2 = effect.scale if effect != null else Vector2.ONE
	var target_offset: Vector2 = effect.offset if effect != null else Vector2.ZERO
	var target_rotation: float = deg_to_rad(effect.rotation_degrees) if effect != null else 0.0
	var target_tint: Color = effect.tint if effect != null else Color.WHITE

	_tween = _button.create_tween().set_parallel(true)
	UiAnimation.tween_property(_tween, _button, "scale", target_scale, animation)
	UiAnimation.tween_property(_tween, _button, "rotation", target_rotation, animation)
	# self_modulate tinge solo il pulsante: la trasparenza delle comparse (modulate) resta libera.
	UiAnimation.tween_property(_tween, _button, "self_modulate", target_tint, animation)
	if _uses_offset():
		UiAnimation.tween_property(_tween, _button, "position", _rest_position + target_offset, animation)


## Lo spostamento si anima solo se serve: così i pulsanti nei Container non vengono toccati.
func _uses_offset() -> bool:
	var hover_offset: Vector2 = _feedback.hover.offset if _feedback.hover != null else Vector2.ZERO
	var pressed_offset: Vector2 = _feedback.pressed.offset if _feedback.pressed != null else Vector2.ZERO
	return hover_offset != Vector2.ZERO or pressed_offset != Vector2.ZERO
