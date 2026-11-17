class_name MainMenu
extends Control
## Menu principale: titolo e pulsante Gioca, che avvia una nuova partita.

@onready var _background: ColorRect = %Background
@onready var _title_label: Label = %TitleLabel
@onready var _play_button: Button = %PlayButton


func _ready() -> void:
	var settings: GameSettings = RunManager.settings
	_title_label.text = settings.game_title
	_background.color = settings.board.background_color
	_play_button.pressed.connect(_on_play_pressed)
	_play_button.grab_focus()


func _on_play_pressed() -> void:
	_play_button.disabled = true
	RunManager.start_new_run()
