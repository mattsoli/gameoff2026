class_name MainMenu
extends Control
## Menu principale.
##   In alto a sinistra: pulsanti musica / suoni.   In alto al centro: logo del gioco (o titolo).
##   Al centro: Play.   In alto a destra: Levels.   In basso al centro: secondo logo.
## Loghi, sfondo, icone e animazioni vengono da UiSettings; la musica da AudioSettings.
## Le decorazioni animate stanno nel nodo "Decorations" della scena: si posizionano
## trascinandole nell'editor 2D e si animano con le loro SpriteFrames.

@onready var _background_color: ColorRect = %BackgroundColor
@onready var _background_texture: TextureRect = %BackgroundTexture
@onready var _logo: TextureRect = %Logo
@onready var _title_label: Label = %TitleLabel
@onready var _footer_logo: TextureRect = %FooterLogo
@onready var _play_button: Button = %PlayButton
@onready var _levels_button: Button = %LevelsButton
@onready var _music_button: Button = %MusicButton
@onready var _sound_button: Button = %SoundButton


func _ready() -> void:
	var settings: GameSettings = RunManager.settings
	var ui: UiSettings = settings.get_ui()
	AudioManager.play_music(settings.get_audio().menu_music)
	_title_label.text = settings.game_title
	if ui.menu_background != null:
		ui.menu_background.apply(_background_color, _background_texture)

	# Con un logo assegnato l'immagine sostituisce il titolo testuale.
	_logo.texture = ui.menu_logo
	_logo.custom_minimum_size = ui.menu_logo_size
	_logo.visible = ui.menu_logo != null
	_title_label.visible = not _logo.visible
	_footer_logo.texture = ui.menu_footer_logo
	_footer_logo.custom_minimum_size = ui.menu_footer_logo_size
	_footer_logo.visible = ui.menu_footer_logo != null

	for button: Button in _get_buttons():
		UiAnimator.attach_button_feedback(button, ui)
	_play_button.pressed.connect(_on_play_pressed)
	_levels_button.pressed.connect(RunManager.go_to_level_select)
	_play_button.grab_focus()
	_play_entrance(ui)


func _get_buttons() -> Array[Button]:
	return [_play_button, _levels_button, _music_button, _sound_button]


func _play_entrance(ui: UiSettings) -> void:
	var title: Control = _logo if _logo.visible else _title_label
	UiAnimator.prepare_in(title, ui.menu_title_appear)
	UiAnimator.prepare_in(_footer_logo, ui.menu_title_appear)
	for button: Button in _get_buttons():
		UiAnimator.prepare_in(button, ui.menu_buttons_appear)
	# I Container dispongono i figli dopo _ready: si anima dalla posizione definitiva.
	await get_tree().process_frame
	UiAnimator.play_in(title, ui.menu_title_appear)
	UiAnimator.play_in(_footer_logo, ui.menu_title_appear)
	for button: Button in _get_buttons():
		UiAnimator.play_in(button, ui.menu_buttons_appear)


func _on_play_pressed() -> void:
	_play_button.disabled = true
	RunManager.start_new_run()
