class_name CombatScreen
extends CanvasLayer
## Combattimento "sul palco": la board l'ha già nascosta GameController, qui giocatore e nemico
## entrano in scena sullo sfondo del gioco (o sullo sfondo del combattimento, se assegnato
## in UiSettings), il vincitore attacca, lo sconfitto lampeggia e fa la sua animazione,
## poi entrambi escono di scena.
## Posizione e dimensione dei due combattenti: trascinare PlayerPanel ed EnemyPanel in questa scena.
## Tempi e transizioni: CombatSettings. La regola sta in CombatResolver.

signal state_changed(new_state: State)

enum State { HIDDEN, INTRO, RESOLUTION, OUTRO }

@export_group("Testi")
## Testi vuoti = scritta nascosta.
@export var title_text: String = "Fight"
@export var enemy_defeated_text: String = "Enemy defeated!"
@export var player_defeated_text: String = "You have been defeated..."

var state: State = State.HIDDEN

var _settings: CombatSettings

@onready var _backdrop: Control = %Backdrop
@onready var _background_color: ColorRect = %BackgroundColor
@onready var _background_texture: TextureRect = %BackgroundTexture
@onready var _title_label: Label = %TitleLabel
@onready var _player_panel: CombatantPanel = %PlayerPanel
@onready var _enemy_panel: CombatantPanel = %EnemyPanel
@onready var _result_label: Label = %ResultLabel


func _ready() -> void:
	visible = false


## Sfondo del combattimento da UiSettings: se non è assegnato si vede lo sfondo del gioco.
func apply_ui(ui: UiSettings) -> void:
	_backdrop.visible = ui.combat_background != null
	if ui.combat_background != null:
		ui.combat_background.apply(_background_color, _background_texture)


## Esegue un combattimento completo e restituisce l'esito quando i combattenti sono usciti di scena.
func run_combat(player: Combatant, enemy: Combatant, settings: CombatSettings) -> CombatResult:
	_settings = settings
	_title_label.text = title_text
	_result_label.text = ""
	_player_panel.setup(player, settings)
	_enemy_panel.setup(enemy, settings)

	# --- Entrata in scena ---
	_set_state(State.INTRO)
	await _play_intro()
	await _wait(settings.pause_before_resolution)

	# --- Risoluzione: il vincitore attacca, lo sconfitto lampeggia e perde ---
	_set_state(State.RESOLUTION)
	var result: CombatResult = CombatResolver.resolve(player, enemy, settings.player_wins_ties)
	await _play_resolution(result)
	_result_label.text = enemy_defeated_text if result.is_player_winner else player_defeated_text
	UiAnimator.play_in(_result_label, settings.result_appear)
	await _wait(settings.result_pause)

	# --- Uscita di scena ---
	_set_state(State.OUTRO)
	await _play_outro()
	_set_state(State.HIDDEN)
	return result


func _play_intro() -> void:
	var animated: Array[Control] = [_backdrop, _title_label, _player_panel, _enemy_panel]
	var transitions: Array[UiTransition] = [_settings.intro, _settings.intro, _settings.player_enter, _settings.enemy_enter]
	for i: int in animated.size():
		UiAnimator.reset(animated[i])
		UiAnimator.prepare_in(animated[i], transitions[i])
	visible = true
	AudioManager.play_sfx(AudioManager.get_settings().combat_start)
	await _play_together([
		UiAnimator.play_in.bind(_backdrop, _settings.intro),
		UiAnimator.play_in.bind(_title_label, _settings.intro),
		UiAnimator.play_in.bind(_player_panel, _settings.player_enter),
		UiAnimator.play_in.bind(_enemy_panel, _settings.enemy_enter),
	])


func _play_outro() -> void:
	await _play_together([
		UiAnimator.play_out.bind(_backdrop, _settings.outro),
		UiAnimator.play_out.bind(_title_label, _settings.outro),
		UiAnimator.play_out.bind(_result_label, _settings.outro),
		UiAnimator.play_out.bind(_player_panel, _settings.player_exit),
		UiAnimator.play_out.bind(_enemy_panel, _settings.enemy_exit),
	])
	visible = false
	for control: Control in [_backdrop, _title_label, _result_label, _player_panel, _enemy_panel]:
		UiAnimator.reset(control)


## Il vincitore attacca verso l'avversario, poi lo sconfitto lampeggia e fa l'animazione di sconfitta.
func _play_resolution(result: CombatResult) -> void:
	var winner: CombatantPanel = _player_panel if result.is_player_winner else _enemy_panel
	var loser: CombatantPanel = _enemy_panel if result.is_player_winner else _player_panel
	var direction_sign: float = signf(loser.position.x - winner.position.x)
	var audio: AudioSettings = AudioManager.get_settings()
	AudioManager.play_sfx(audio.attack)
	await winner.play_attack(direction_sign if direction_sign != 0.0 else 1.0, _settings)
	AudioManager.play_sfx(audio.combat_win if result.is_player_winner else audio.combat_lose)
	await loser.play_defeat(_settings)


## Avvia tutte le animazioni insieme e attende che sia finita la più lunga.
func _play_together(jobs: Array[Callable]) -> void:
	var pending: Array[int] = [jobs.size()]
	for job: Callable in jobs:
		_run_job(job, pending)
	while pending[0] > 0:
		await get_tree().process_frame


func _run_job(job: Callable, pending: Array[int]) -> void:
	await job.call()
	pending[0] -= 1


func _set_state(new_state: State) -> void:
	state = new_state
	state_changed.emit(new_state)


func _wait(seconds: float) -> void:
	if seconds > 0.0:
		await get_tree().create_timer(seconds).timeout
