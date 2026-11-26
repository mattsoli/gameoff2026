class_name LevelSelect
extends Control
## Schermata dei livelli: una griglia di pulsanti quadrati, uno per livello di GameSettings.levels.
## Colonne = numero di livelli, fino a UiSettings.level_select_max_columns; poi si va a capo.
## I livelli oltre GameSettings.unlocked_levels sono bloccati (0 = tutti sbloccati).
## Aspetto dei pulsanti: stile del Theme "LevelButton" (le immagini dello stato bloccato
## vanno nello StyleBox "disabled"). Sfondo, misure e comparsa: UiSettings, gruppo "Schermata livelli".

@export_group("Testi")
@export var title_text: String = "Levels"
## Testo dei pulsanti: %d = numero del livello (con %02d diventa 01, 02...).
@export var level_button_format: String = "Level\n%02d"
@export var back_text: String = "Back"

@onready var _background_color: ColorRect = %BackgroundColor
@onready var _background_texture: TextureRect = %BackgroundTexture
@onready var _title_label: Label = %TitleLabel
@onready var _back_button: Button = %BackButton
@onready var _grid: GridContainer = %Grid

var _level_buttons: Array[Button] = []


func _ready() -> void:
	var settings: GameSettings = RunManager.settings
	var ui: UiSettings = settings.get_ui()
	AudioManager.play_music(settings.get_audio().menu_music)
	if ui.level_select_background != null:
		ui.level_select_background.apply(_background_color, _background_texture)
	_title_label.text = title_text
	_back_button.text = back_text
	UiAnimator.attach_button_feedback(_back_button, ui)
	_back_button.pressed.connect(RunManager.go_to_main_menu)

	_build_grid(settings, ui)
	_play_entrance(ui)


func _build_grid(settings: GameSettings, ui: UiSettings) -> void:
	var level_count: int = settings.levels.size()
	var unlocked_count: int = settings.get_unlocked_level_count()
	_grid.columns = clampi(level_count, 1, ui.level_select_max_columns)
	_grid.add_theme_constant_override("h_separation", int(ui.level_grid_spacing.x))
	_grid.add_theme_constant_override("v_separation", int(ui.level_grid_spacing.y))

	for index: int in level_count:
		var level: LevelDefinition = settings.levels[index]
		var is_locked: bool = index >= unlocked_count
		var button: FeedbackButton = FeedbackButton.new()
		# Lo stile va impostato prima di collegare il feedback (che lo legge).
		button.theme_type_variation = &"LevelButton"
		button.custom_minimum_size = ui.level_button_size
		button.focus_mode = Control.FOCUS_NONE
		button.expand_icon = true
		button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
		button.disabled = is_locked
		_set_button_content(button, level, index, is_locked, ui)
		_grid.add_child(button)
		UiAnimator.attach_button_feedback(button, ui)
		button.pressed.connect(RunManager.start_new_run.bind(index))
		_level_buttons.append(button)


## Immagine del livello (select_icon) o testo con il numero; sui bloccati l'icona del lucchetto.
func _set_button_content(button: Button, level: LevelDefinition, index: int, is_locked: bool, ui: UiSettings) -> void:
	if is_locked and ui.level_locked_icon != null:
		button.icon = ui.level_locked_icon
		button.text = ""
	elif level.select_icon != null:
		button.icon = level.select_icon
		button.text = ""
	else:
		button.text = level_button_format % (index + 1)


## I pulsanti compaiono uno dopo l'altro (ritardo crescente).
func _play_entrance(ui: UiSettings) -> void:
	for button: Button in _level_buttons:
		UiAnimator.prepare_in(button, ui.level_buttons_appear)
	await get_tree().process_frame
	for index: int in _level_buttons.size():
		var button: Button = _level_buttons[index]
		_play_button_entrance(button, ui.level_buttons_appear, index * ui.level_buttons_stagger)


func _play_button_entrance(button: Button, transition: UiTransition, delay: float) -> void:
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout
	UiAnimator.play_in(button, transition)
