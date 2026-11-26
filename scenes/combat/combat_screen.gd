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
@onready var _background_color: ColorRect = %BackgroundColor
@onready var _background_texture: TextureRect = %BackgroundTexture
@onready var _title_label: Label = %TitleLabel
@onready var _player_panel: CombatantPanel = %PlayerPanel
@onready var _enemy_panel: CombatantPanel = %EnemyPanel
@onready var _result_label: Label = %ResultLabel


func _ready() -> void:
	visible = false


## Applica lo sfondo configurato in UiSettings (chiamato una volta dalla scena di gioco).
func apply_ui(ui: UiSettings) -> void:
	if ui.combat_background != null:
		ui.combat_background.apply(_background_color, _background_texture)


## Esegue un combattimento completo e restituisce l'esito quando la schermata si chiude.
func run_combat(player: Combatant, enemy: Combatant, settings: CombatSettings) -> CombatResult:
	_settings = settings

	# --- Fase 1: Inizio ---
	_title_label.text = title_text
	_result_label.text = ""
	_player_panel.setup(player, settings)
	_enemy_panel.setup(enemy, settings)
	_set_state(State.INTRO)
	await _play_intro()
	await _wait(settings.pause_before_resolution)

	# --- Fase 2: Risoluzione ---
	_set_state(State.RESOLUTION)
	var result: CombatResult = CombatResolver.resolve(player, enemy, settings.player_wins_ties)
	await _play_resolution(result)
	_result_label.text = enemy_defeated_text if result.is_player_winner else player_defeated_text
	UiAnimator.play_in(_result_label, settings.result_appear)
	await _wait(settings.result_pause)

	await _play_outro()
	_set_state(State.HIDDEN)
	return result


func _play_intro() -> void:
	UiAnimator.prepare_in(_root, _settings.intro)
	visible = true
	await UiAnimator.play_in(_root, _settings.intro)


func _play_outro() -> void:
	await UiAnimator.play_out(_root, _settings.outro)
	visible = false
	UiAnimator.reset(_root)


## Il vincitore scatta verso l'avversario, poi lo sconfitto subisce il colpo.
func _play_resolution(result: CombatResult) -> void:
	var winner: CombatantPanel = _player_panel if result.is_player_winner else _enemy_panel
	var loser: CombatantPanel = _enemy_panel if result.is_player_winner else _player_panel
	var direction_sign: float = 1.0 if result.is_player_winner else -1.0
	await winner.play_attack(direction_sign, _settings)
	await loser.play_defeat(_settings)


func _set_state(new_state: State) -> void:
	state = new_state
	state_changed.emit(new_state)


func _wait(seconds: float) -> void:
	if seconds > 0.0:
		await get_tree().create_timer(seconds).timeout
