extends Node
## Autoload "RunManager": livello corrente e passaggio tra le scene.
## Il giocatore non porta nulla da un livello all'altro (riparte senza arma),
## quindi qui non c'è stato del giocatore: lo crea la scena di gioco a ogni livello.
## Le impostazioni si modificano aprendo il file SETTINGS_PATH.

const SETTINGS_PATH: String = GameSettings.SETTINGS_PATH

var settings: GameSettings = preload(SETTINGS_PATH)

var current_level_index: int = 0

## Livello aperto dal pulsante "Test level" del Level Editor (null in una partita normale).
var _test_level: LevelDefinition


func _ready() -> void:
	assert(settings != null, "GameSettings non trovate in " + SETTINGS_PATH)
	assert(not settings.levels.is_empty(), "GameSettings non contiene livelli")
	# Se il gioco è stato avviato dal pulsante "Test level" la richiesta è già pronta.
	_test_level = EditorTestLevel.consume()
	_apply_theme(settings.get_ui())


## Il Theme di UiSettings vale per tutte le scene: lo si applica alla finestra principale.
## Il suo font predefinito viene usato anche per le scritte disegnate sulla board.
func _apply_theme(ui: UiSettings) -> void:
	if ui.theme == null:
		return
	get_tree().root.theme = ui.theme
	if ui.theme.has_default_font():
		DrawUtils.board_font = ui.theme.default_font


## Avvia la partita dal livello `level_index` (0 = il primo).
func start_new_run(level_index: int = 0) -> void:
	current_level_index = clampi(level_index, 0, settings.levels.size() - 1)
	_test_level = null
	go_to_game()


func is_testing_level() -> bool:
	return _test_level != null


func get_current_level() -> LevelDefinition:
	if _test_level != null:
		return _test_level
	return settings.levels[current_level_index]


func get_level_number() -> int:
	return current_level_index + 1


func has_next_level() -> bool:
	if _test_level != null:
		return false
	return current_level_index + 1 < settings.levels.size()


func restart_level() -> void:
	go_to_game()


func advance_to_next_level() -> void:
	assert(has_next_level(), "Non ci sono altri livelli")
	current_level_index += 1
	go_to_game()


func go_to_game() -> void:
	_change_scene(settings.game_scene)


func go_to_main_menu() -> void:
	_change_scene(settings.main_menu_scene)


func go_to_level_select() -> void:
	_change_scene(settings.level_select_scene)


func _change_scene(path: String) -> void:
	var error: Error = get_tree().change_scene_to_file(path)
	if error != OK:
		push_error("Impossibile caricare la scena '%s' (errore %d)" % [path, error])
