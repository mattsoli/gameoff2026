class_name MainMenu
extends Node

@export var base_config: GameConfig
@export var conveyor_config: GameConfig

var _menu_layer: CanvasLayer
var _game: Game
var _current_config: GameConfig


func _ready() -> void:
	assert(base_config != null, "Assegna base_config nell'Inspector")
	assert(conveyor_config != null, "Assegna conveyor_config nell'Inspector")
	_build_menu()


func _build_menu() -> void:
	_menu_layer = CanvasLayer.new()
	add_child(_menu_layer)

	var center: CenterContainer = CenterContainer.new()
	_menu_layer.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	center.add_child(column)

	var title: Label = Label.new()
	title.text = "Scegli la modalità"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	column.add_child(title)

	_add_mode_button(column, "Base", base_config)
	_add_mode_button(column, "Nastro Trasportatore", conveyor_config)


func _add_mode_button(parent: Control, text: String, config: GameConfig) -> void:
	var button: Button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(260.0, 48.0)
	button.pressed.connect(_start_game.bind(config))
	parent.add_child(button)


func _start_game(config: GameConfig) -> void:
	_current_config = config
	_menu_layer.visible = false

	_game = Game.new()
	_game.config = config # va assegnato PRIMA di add_child: Game la legge in _ready
	# CONNECT_DEFERRED: il Game viene rimosso dopo che ha finito di gestire l'evento.
	_game.reload_requested.connect(_on_reload_requested, CONNECT_DEFERRED)
	_game.menu_requested.connect(_on_menu_requested, CONNECT_DEFERRED)
	add_child(_game)


func _on_reload_requested() -> void:
	_free_game()
	_start_game(_current_config)


func _on_menu_requested() -> void:
	_free_game()
	_menu_layer.visible = true


func _free_game() -> void:
	if _game == null:
		return
	remove_child(_game) # fuori dall'albero subito, così non convive con il nuovo Game
	_game.queue_free()
	_game = null
