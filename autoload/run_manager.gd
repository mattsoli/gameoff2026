extends Node
## Autoload "RunManager": stato della partita in corso (giocatore, livello corrente)
## e passaggio tra le scene. Le impostazioni si modificano aprendo il file SETTINGS_PATH.

const SETTINGS_PATH: String = "res://data/settings/game_settings.tres"

var settings: GameSettings = preload(SETTINGS_PATH)

var player_state: PlayerState
var current_level_index: int = 0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

## Stato del giocatore all'inizio del livello corrente, per il "Riprova".
var _level_start_snapshot: PlayerState


func _ready() -> void:
	assert(settings != null, "Assegna le GameSettings a run_manager.tscn")
	assert(not settings.levels.is_empty(), "GameSettings non contiene livelli")


func start_new_run() -> void:
	if settings.rng_seed == 0:
		rng.randomize()
	else:
		rng.seed = settings.rng_seed
	player_state = PlayerState.create(settings.player)
	current_level_index = 0
	_level_start_snapshot = null
	go_to_game()


## Permette di avviare direttamente la scena di gioco dall'editor (F6) senza passare dal menu.
func ensure_run_started() -> void:
	if player_state == null:
		rng.randomize()
		player_state = PlayerState.create(settings.player)


func get_current_level() -> LevelDefinition:
	return settings.levels[current_level_index]


func get_level_number() -> int:
	return current_level_index + 1


func has_next_level() -> bool:
	return current_level_index + 1 < settings.levels.size()


## Chiamato dalla scena di gioco all'avvio di ogni livello.
func begin_level() -> void:
	_level_start_snapshot = player_state.copy()


func restart_level() -> void:
	if _level_start_snapshot != null:
		player_state = _level_start_snapshot.copy()
	go_to_game()


func advance_to_next_level() -> void:
	assert(has_next_level(), "Non ci sono altri livelli")
	current_level_index += 1
	if settings.heal_between_levels:
		player_state.heal_full()
	go_to_game()


func go_to_game() -> void:
	_change_scene(settings.game_scene)


func go_to_main_menu() -> void:
	_change_scene(settings.main_menu_scene)


func _change_scene(path: String) -> void:
	var error: Error = get_tree().change_scene_to_file(path)
	if error != OK:
		push_error("Impossibile caricare la scena '%s' (errore %d)" % [path, error])
