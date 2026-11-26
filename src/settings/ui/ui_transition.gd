@tool
class_name UiTransition
extends UiAnimation
## Comparsa o scomparsa di un elemento dell'interfaccia.
## Gli effetti si combinano liberamente: dissolvenza + scorrimento + scala.
## In comparsa l'elemento parte dallo stato descritto qui e arriva alla sua posizione normale;
## in scomparsa fa il percorso inverso.

## Dissolvenza dalla/alla trasparenza.
@export var fade: bool = true
## Spostamento rispetto alla posizione normale, in pixel (es. (0, -60) = arriva dall'alto).
@export var slide_offset: Vector2 = Vector2.ZERO
## Scala rispetto a quella normale: (1, 1) = nessun effetto, (0.8, 0.8) = cresce/si rimpicciolisce.
@export var start_scale: Vector2 = Vector2.ONE


static func create_transition(p_duration: float, p_slide_offset: Vector2 = Vector2.ZERO, p_start_scale: Vector2 = Vector2.ONE, p_transition: Tween.TransitionType = Tween.TRANS_CUBIC, p_easing: Tween.EaseType = Tween.EASE_OUT) -> UiTransition:
	var transition_settings: UiTransition = UiTransition.new()
	transition_settings.duration = p_duration
	transition_settings.slide_offset = p_slide_offset
	transition_settings.start_scale = p_start_scale
	transition_settings.transition = p_transition
	transition_settings.easing = p_easing
	return transition_settings
