class_name CombatScreen
extends CanvasLayer
## Schermata di combattimento, sovrapposta alla board.
## Due fasi del Game Bible, entrambe automatiche:
##   Inizio      -> si apre mostrando bene i valori di attacco dei due combattenti;
##   Risoluzione -> attacca chi ha il valore più alto, l'altro subisce il colpo.
## La regola sta in CombatResolver: qui c'è solo la sequenza e le animazioni.

signal state_changed(new_state: State)

enum State { HIDDEN, INTRO, RESOLUTION }

@export_group("Testi")
@export var title_text: String = "Fight"
@export var enemy_defeated_text: String = "Enemy defeated!"
@export var player_defeated_text: String = "You have been defeated..."

var state: State = State.HIDDEN

var _settings: CombatSettings

@onready var _root: Control = %Root
@onready var _title_label: Label = %TitleLabel
@onready var _player_panel: CombatantPanel = %PlayerPanel
@onready var _enemy_panel: CombatantPanel = %EnemyPanel
@onready var _result_label: Label = %ResultLabel


func _ready() -> void:
	visible = false


## Esegue un combattimento completo e restituisce l'esito quando la schermata si chiude.
func run_combat(player: Combatant, enemy: Combatant, settings: CombatSettings) -> CombatResult:
	_settings = settings

	# --- Fase 1: Inizio ---
	_title_label.text = title_text
	_result_label.text = ""
	_player_panel.setup(player)
	_enemy_panel.setup(enemy)
	_set_state(State.INTRO)
	await _play_intro()
	await _wait(settings.pause_before_resolution)

	# --- Fase 2: Risoluzione ---
	_set_state(State.RESOLUTION)
	var result: CombatResult = CombatResolver.resolve(player, enemy, settings.player_wins_ties)
	await _play_resolution(result)
	_result_label.text = enemy_defeated_text if result.is_player_winner else player_defeated_text
	await _wait(settings.result_pause)

	await _play_outro()
	_set_state(State.HIDDEN)
	return result


func _play_intro() -> void:
	visible = true
	_root.modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.tween_property(_root, "modulate:a", 1.0, _settings.intro_duration)
	await tween.finished


func _play_outro() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(_root, "modulate:a", 0.0, _settings.outro_duration)
	await tween.finished
	visible = false


## Il vincitore scatta verso l'avversario, poi lo sconfitto subisce il colpo.
func _play_resolution(result: CombatResult) -> void:
	var winner: CombatantPanel = _player_panel if result.is_player_winner else _enemy_panel
	var loser: CombatantPanel = _enemy_panel if result.is_player_winner else _player_panel
	var direction_sign: float = 1.0 if result.is_player_winner else -1.0
	await winner.play_attack(direction_sign, _settings.attack_duration)
	await loser.play_defeat(_settings.defeat_duration)


func _set_state(new_state: State) -> void:
	state = new_state
	state_changed.emit(new_state)


func _wait(seconds: float) -> void:
	if seconds > 0.0:
		await get_tree().create_timer(seconds).timeout
