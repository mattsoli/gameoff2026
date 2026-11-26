class_name UiAnimator
extends RefCounted
## Esegue le UiTransition sui Control e collega il feedback animato dei pulsanti.
## Le scene non creano Tween per comparse/scomparse: chiamano queste funzioni passando
## la UiTransition configurata dal Designer.
##
## Regola d'uso: play_in va chiamato con il controllo nella sua posizione normale
## (per i figli di un Container, dopo che il Container li ha disposti: attendere un frame);
## dopo play_out il controllo resta "fuori" finché non si chiama reset().

const REST_POSITION_META: StringName = &"ui_rest_position"


## Nasconde subito il controllo se la transizione parte trasparente: evita che resti visibile
## per un frame mentre si aspetta che i Container lo dispongano.
static func prepare_in(control: Control, transition: UiTransition) -> void:
	if transition != null and transition.fade:
		control.modulate.a = 0.0


## Fa comparire il controllo: dallo stato descritto dalla transizione alla posizione normale.
static func play_in(control: Control, transition: UiTransition) -> void:
	var rest_position: Vector2 = control.position
	control.pivot_offset = control.size * 0.5
	if transition == null:
		control.modulate.a = 1.0
		return
	control.modulate.a = 0.0 if transition.fade else 1.0
	control.position = rest_position + transition.slide_offset
	control.scale = transition.start_scale

	var tween: Tween = control.create_tween().set_parallel(true)
	UiAnimation.tween_property(tween, control, "modulate:a", 1.0, transition)
	UiAnimation.tween_property(tween, control, "position", rest_position, transition)
	UiAnimation.tween_property(tween, control, "scale", Vector2.ONE, transition)
	await tween.finished


## Fa scomparire il controllo verso lo stato descritto dalla transizione.
static func play_out(control: Control, transition: UiTransition) -> void:
	control.set_meta(REST_POSITION_META, control.position)
	control.pivot_offset = control.size * 0.5
	if transition == null:
		return
	var tween: Tween = control.create_tween().set_parallel(true)
	if transition.fade:
		UiAnimation.tween_property(tween, control, "modulate:a", 0.0, transition)
	UiAnimation.tween_property(tween, control, "position", control.position + transition.slide_offset, transition)
	UiAnimation.tween_property(tween, control, "scale", transition.start_scale, transition)
	await tween.finished


## Riporta il controllo allo stato normale dopo un play_out (di solito dopo averlo nascosto).
static func reset(control: Control) -> void:
	if control.has_meta(REST_POSITION_META):
		var rest_position: Vector2 = control.get_meta(REST_POSITION_META)
		control.position = rest_position
		control.remove_meta(REST_POSITION_META)
	control.scale = Vector2.ONE
	control.modulate.a = 1.0


## Porta l'opacità del controllo a `alpha` con i tempi di `animation`.
static func fade_to(control: CanvasItem, alpha: float, animation: UiAnimation) -> void:
	var tween: Tween = control.create_tween()
	UiAnimation.tween_property(tween, control, "modulate:a", alpha, animation)
	await tween.finished


## Reazione animata del pulsante al mouse, secondo il ButtonFeedback del suo stile del Theme.
static func attach_button_feedback(button: BaseButton, ui: UiSettings) -> void:
	ButtonFeedbackController.attach(button, ui.get_button_feedback(button.theme_type_variation))
