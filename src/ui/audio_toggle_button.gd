class_name AudioToggleButton
extends FeedbackButton
## Pulsante che accende/spegne la colonna sonora o gli effetti sonori.
## Mostra l'icona "on" o "off" (da UiSettings); senza icone mostra un testo.

enum Channel { MUSIC, SFX }

@export var channel: Channel = Channel.MUSIC
@export_group("Testi (se mancano le icone)")
@export var music_on_text: String = "Music: on"
@export var music_off_text: String = "Music: off"
@export var sound_on_text: String = "Sound: on"
@export var sound_off_text: String = "Sound: off"

var _on_icon: Texture2D
var _off_icon: Texture2D


func _ready() -> void:
	var ui: UiSettings = RunManager.settings.get_ui()
	_on_icon = ui.music_on_icon if channel == Channel.MUSIC else ui.sound_on_icon
	_off_icon = ui.music_off_icon if channel == Channel.MUSIC else ui.sound_off_icon
	expand_icon = true
	icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pressed.connect(_on_pressed)
	if channel == Channel.MUSIC:
		AudioManager.music_enabled_changed.connect(_refresh.unbind(1))
	else:
		AudioManager.sfx_enabled_changed.connect(_refresh.unbind(1))
	_refresh()


func _on_pressed() -> void:
	if channel == Channel.MUSIC:
		AudioManager.toggle_music()
	else:
		AudioManager.toggle_sfx()


func _refresh() -> void:
	var is_enabled: bool = AudioManager.music_enabled if channel == Channel.MUSIC else AudioManager.sfx_enabled
	var state_icon: Texture2D = _on_icon if is_enabled else _off_icon
	icon = state_icon
	if state_icon != null:
		text = ""
	elif channel == Channel.MUSIC:
		text = music_on_text if is_enabled else music_off_text
	else:
		text = sound_on_text if is_enabled else sound_off_text
