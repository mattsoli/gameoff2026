class_name MainMenu
extends Control
## Menu principale: titolo (o logo) e pulsante Gioca, che avvia una nuova partita.
## Sfondo, logo e animazioni di comparsa vengono da UiSettings.

@onready var _background_color: ColorRect = %BackgroundColor
@onready var _background_texture: TextureRect = %BackgroundTexture
@onready var _logo: TextureRect = %Logo
@onready var _title_label: Label = %TitleLabel
@onready var _play_button: Button = %PlayButton


func _ready() -> void:
	var settings: GameSettings = RunManager.settings
	var ui: UiSettings = settings.get_ui()
	_title_label.text = settings.game_title
	if ui.menu_background != null:
		ui.menu_background.apply(_background_color, _background_texture)

	# Con un logo assegnato l'immagine sostituisce il titolo testuale.
	_logo.texture = ui.menu_logo
	_logo.custom_minimum_size = ui.menu_logo_size
	_logo.visible = ui.menu_logo != null
	_title_label.visible = not _logo.visible

	UiAnimator.attach_button_feedback(_play_button, ui)
	_play_button.pressed.connect(_on_play_pressed)
	_play_button.grab_focus()
	_play_entrance(ui)


func _play_entrance(ui: UiSettings) -> void:
	var title: Control = _logo if _logo.visible else _title_label
	UiAnimator.prepare_in(title, ui.menu_title_appear)
	UiAnimator.prepare_in(_play_button, ui.menu_buttons_appear)
	# I Container dispongono i figli dopo _ready: si anima dalla posizione definitiva.
	await get_tree().process_frame
	UiAnimator.play_in(title, ui.menu_title_appear)
	UiAnimator.play_in(_play_button, ui.menu_buttons_appear)


func _on_play_pressed() -> void:
	_play_button.disabled = true
	RunManager.start_new_run()
