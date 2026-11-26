@tool
class_name ButtonFeedback
extends Resource
## Reazione animata di un pulsante al mouse: effetti per "mouse sopra" e "premuto",
## i loro tempi e, facoltativa, una scena fatta a mano con AnimationPlayer.
## Lasciare vuoto un effetto = in quello stato il pulsante resta com'è.

@export_group("Effetti")
## Mouse sopra il pulsante.
@export var hover: ButtonStateEffect = ButtonStateEffect.create(Vector2(1.08, 1.08), Vector2(0.0, -4.0))
## Pulsante premuto (tasto del mouse giù).
@export var pressed: ButtonStateEffect = ButtonStateEffect.create(Vector2(0.94, 0.94), Vector2(0.0, 2.0), 0.0, Color(0.85, 0.85, 0.85))

@export_group("Tempi")
## Passaggio tra riposo e "mouse sopra".
@export var hover_animation: UiAnimation = UiAnimation.create(0.18, Tween.TRANS_BACK, Tween.EASE_OUT)
## Passaggio verso e da "premuto" (di solito più rapido).
@export var press_animation: UiAnimation = UiAnimation.create(0.08)

@export_group("Scena animata")
## Scena con AnimationPlayer mostrata al centro del pulsante (es. una cornice o delle scintille).
## Animazioni usate: "idle" (a riposo), "hover" (mouse entra), "unhover" (mouse esce),
## "pressed" (clic), "released" (rilascio). Basta crearne alcune.
@export var scene: PackedScene
## Se attivo la scena sta dietro il pulsante (sotto sfondo e testo), altrimenti sopra.
@export var scene_behind_button: bool = false
