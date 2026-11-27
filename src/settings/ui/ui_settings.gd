@tool
class_name UiSettings
extends Resource
## Aspetto e animazioni dell'interfaccia.
## Lo stile di testi, pulsanti e pannelli (font, colori, dimensioni, texture) sta nel `theme`
## e si modifica con l'editor dei Theme di Godot; qui c'è tutto ciò che il Theme non copre.

@export_group("Stile")
## Theme applicato a tutto il gioco. Ogni elemento usa uno stile con nome
## (es. TitleLabel, AttackValueLabel, PrimaryButton): vedi la guida per l'elenco.
@export var theme: Theme

@export_group("Menu principale")
@export var menu_background: ScreenBackground = ScreenBackground.create(Color(0.06, 0.07, 0.09))
## Se assegnata, l'immagine del logo sostituisce il titolo testuale.
@export var menu_logo: Texture2D
@export var menu_logo_size: Vector2 = Vector2(900.0, 360.0)
## Secondo logo in basso al centro (es. lo studio). Vuoto = nascosto.
@export var menu_footer_logo: Texture2D
@export var menu_footer_logo_size: Vector2 = Vector2(420.0, 160.0)
## Comparsa dei loghi.
@export var menu_title_appear: UiTransition = UiTransition.create_transition(0.5, Vector2(0.0, -40.0))
## Comparsa dei pulsanti (Play, Levels, audio).
@export var menu_buttons_appear: UiTransition = _create_delayed_transition(0.4, Vector2(0.0, 40.0), 0.2)
## Icone dei pulsanti audio in alto a sinistra. Senza icone i pulsanti mostrano un testo.
@export var music_on_icon: Texture2D
@export var music_off_icon: Texture2D
@export var sound_on_icon: Texture2D
@export var sound_off_icon: Texture2D

@export_group("Schermata livelli")
@export var level_select_background: ScreenBackground = ScreenBackground.create(Color(0.06, 0.07, 0.09))
## Numero massimo di colonne della griglia: con meno livelli le colonne si riducono.
@export_range(1, 12) var level_select_max_columns: int = 4
## Lato dei pulsanti quadrati dei livelli, in pixel.
@export var level_button_size: Vector2 = Vector2(240.0, 240.0)
## Spazio tra un pulsante e l'altro.
@export var level_grid_spacing: Vector2 = Vector2(48.0, 48.0)
## Icona sui livelli bloccati (vuota = solo il pulsante disabilitato).
@export var level_locked_icon: Texture2D
## Comparsa di ogni pulsante; ognuno parte un po' dopo il precedente (level_buttons_stagger).
@export var level_buttons_appear: UiTransition = UiTransition.create_transition(0.3, Vector2.ZERO, Vector2(0.8, 0.8), Tween.TRANS_BACK)
@export_range(0.0, 1.0, 0.01, "suffix:s") var level_buttons_stagger: float = 0.04

@export_group("Gioco")
@export var game_background: ScreenBackground = ScreenBackground.create(Color(0.06, 0.07, 0.09))
## Comparsa della barra in alto all'inizio di ogni livello.
@export var hud_appear: UiTransition = UiTransition.create_transition(0.35, Vector2(0.0, -60.0))
## Comparsa della board all'inizio di ogni livello.
@export var board_appear: UiTransition = UiTransition.create_transition(0.35, Vector2.ZERO, Vector2(0.92, 0.92))

@export_group("Combattimento")
## Sfondo dietro ai combattenti. Vuoto = si vede lo sfondo del gioco (la board sparisce).
@export var combat_background: ScreenBackground

@export_group("Finestre (fine livello, errori)")
## Colore che oscura il gioco dietro la finestra.
@export var overlay_dim_color: Color = Color(0.0, 0.0, 0.0, 0.75)
@export var overlay_appear: UiTransition = UiTransition.create_transition(0.3, Vector2.ZERO, Vector2(0.85, 0.85), Tween.TRANS_BACK)
@export var overlay_disappear: UiTransition = UiTransition.create_transition(0.15, Vector2.ZERO, Vector2(0.95, 0.95), Tween.TRANS_QUAD, Tween.EASE_IN)

@export_group("Pulsanti")
## Reazione al mouse di tutti i pulsanti. Vuoto = nessuna reazione.
@export var button_feedback: ButtonFeedback = ButtonFeedback.new()
## Reazioni diverse per uno stile del Theme: chiave = nome dello stile (es. "PrimaryButton",
## "HudButton"), valore = un ButtonFeedback. Gli stili non elencati usano button_feedback.
@export var button_feedback_by_style: Dictionary[StringName, ButtonFeedback] = {}


## Reazione da usare per un pulsante con lo stile del Theme `style` (theme_type_variation).
func get_button_feedback(style: StringName) -> ButtonFeedback:
	if button_feedback_by_style.has(style):
		return button_feedback_by_style[style]
	return button_feedback


static func _create_delayed_transition(p_duration: float, p_slide_offset: Vector2, p_delay: float) -> UiTransition:
	var transition_settings: UiTransition = UiTransition.create_transition(p_duration, p_slide_offset)
	transition_settings.delay = p_delay
	return transition_settings
