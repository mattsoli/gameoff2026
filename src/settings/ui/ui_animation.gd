@tool
class_name UiAnimation
extends Resource
## Parametri di un'animazione: durata, ritardo e curva di accelerazione.
## Si usa per tutti i movimenti del gioco (pedina, shift, schermate, pulsanti).
## Lasciare vuoto (null) un campo di tipo UiAnimation = cambio istantaneo, senza animazione.

@export_range(0.0, 5.0, 0.01, "suffix:s") var duration: float = 0.25
## Attesa prima che l'animazione parta.
@export_range(0.0, 5.0, 0.01, "suffix:s") var delay: float = 0.0
## Forma della curva: LINEAR costante, QUAD/CUBIC morbida, BACK con "rimbalzo" oltre l'arrivo,
## ELASTIC a molla, BOUNCE a rimbalzi.
@export var transition: Tween.TransitionType = Tween.TRANS_QUAD
## Dove si applica la curva: IN all'inizio, OUT alla fine, IN_OUT a entrambi.
@export var easing: Tween.EaseType = Tween.EASE_OUT


static func create(p_duration: float, p_transition: Tween.TransitionType = Tween.TRANS_QUAD, p_easing: Tween.EaseType = Tween.EASE_OUT) -> UiAnimation:
	var animation: UiAnimation = UiAnimation.new()
	animation.duration = p_duration
	animation.transition = p_transition
	animation.easing = p_easing
	return animation


## Aggiunge al tween l'animazione di una proprietà con i parametri di `animation`.
## Unico punto in cui le UiAnimation diventano Tween: se `animation` è null il valore arriva subito.
static func tween_property(tween: Tween, target: Object, property: NodePath, final_value: Variant, animation: UiAnimation) -> PropertyTweener:
	if animation == null:
		return tween.tween_property(target, property, final_value, 0.0)
	return tween.tween_property(target, property, final_value, animation.duration) \
		.set_trans(animation.transition) \
		.set_ease(animation.easing) \
		.set_delay(animation.delay)
