class_name CombatScreen
extends CanvasLayer
## Schermata di combattimento, sovrapposta alla board.
## Gestisce le 3 fasi del Game Bible (Inizio -> Battaglia -> Risoluzione) come macchina a stati.
## Le regole sono in CombatResolver: qui c'è solo la sequenza e le animazioni.

signal state_changed(new_state: State)

enum State { HIDDEN, INTRO, BATTLE, RESOLUTION, OUTCOME }

## Ordine delle monete dall'alto: le spade del giocatore si confrontano con gli scudi del nemico.
const PLAYER_COIN_ORDER: Array[CoinFace.Type] = [CoinFace.Type.SWORD, CoinFace.Type.SHIELD]
const ENEMY_COIN_ORDER: Array[CoinFace.Type] = [CoinFace.Type.SHIELD, CoinFace.Type.SWORD]

@export_group("Testi")
@export var title_text: String = "Fight"
@export var roll_button_text: String = "Toss coins"
@export var continue_button_text: String = "Continue"
@export var enemy_defeated_text: String = "Enemy defeated!"
@export var player_defeated_text: String = "You have been defeated..."
@export var enemy_survived_text: String = "The enemy survived your attack."

var state: State = State.HIDDEN

var _settings: CombatSettings

@onready var _root: Control = %Root
@onready var _title_label: Label = %TitleLabel
@onready var _player_panel: CombatantPanel = %PlayerPanel
@onready var _enemy_panel: CombatantPanel = %EnemyPanel
@onready var _player_coins: CoinColumn = %PlayerCoins
@onready var _enemy_coins: CoinColumn = %EnemyCoins
@onready var _result_label: Label = %ResultLabel
@onready var _action_button: Button = %ActionButton


func _ready() -> void:
	visible = false


## Esegue un combattimento completo e restituisce l'esito quando il giocatore chiude la schermata.
func run_combat(player: Combatant, enemy: Combatant, settings: CombatSettings, rng: RandomNumberGenerator) -> CombatResult:
	_settings = settings

	# --- Fase 1: Inizio ---
	CombatResolver.apply_before_roll_effects(player, enemy)
	_prepare_view(player, enemy)
	_set_state(State.INTRO)
	await _play_intro()

	# --- Fase 2: Battaglia ---
	_set_state(State.BATTLE)
	await _wait_action_button(roll_button_text)
	CombatResolver.roll(player, rng, settings.sword_chance)
	CombatResolver.roll(enemy, rng, settings.sword_chance)
	await _reveal_coins(player, enemy)
	CombatResolver.apply_after_roll_effects(player, enemy)
	await _add_bonus_coins(player, enemy)
	await _arrange_coins()

	# --- Fase 3: Risoluzione ---
	_set_state(State.RESOLUTION)
	var result: CombatResult = CombatResolver.resolve(player, enemy)
	await _play_resolution(result)

	_set_state(State.OUTCOME)
	_result_label.text = _get_outcome_text(result)
	await _wait_action_button(continue_button_text)
	await _play_outro()
	_set_state(State.HIDDEN)
	return result


func _prepare_view(player: Combatant, enemy: Combatant) -> void:
	_title_label.text = title_text
	_result_label.text = ""
	_player_panel.setup(player)
	_enemy_panel.setup(enemy)
	_player_coins.setup(_settings)
	_enemy_coins.setup(_settings)
	_player_coins.show_hidden_coins(player.coin_count)
	_enemy_coins.show_hidden_coins(enemy.coin_count)
	_set_action_button_shown(false)


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


func _wait_action_button(text: String) -> void:
	_action_button.text = text
	_set_action_button_shown(true)
	await _action_button.pressed
	_set_action_button_shown(false)


## Il pulsante resta nel layout (trasparente) per non far "saltare" il resto della schermata.
func _set_action_button_shown(is_shown: bool) -> void:
	_action_button.disabled = not is_shown
	_action_button.modulate.a = 1.0 if is_shown else 0.0


## Le due colonne vengono lanciate in parallelo; si attende la più lunga.
func _reveal_coins(player: Combatant, enemy: Combatant) -> void:
	_player_coins.reveal(player.rolled_faces)
	_enemy_coins.reveal(enemy.rolled_faces)
	var duration: float = maxf(
		_player_coins.get_reveal_duration(player.rolled_faces.size()),
		_enemy_coins.get_reveal_duration(enemy.rolled_faces.size()))
	await _wait(duration)


func _add_bonus_coins(player: Combatant, enemy: Combatant) -> void:
	if player.bonus_faces.is_empty() and enemy.bonus_faces.is_empty():
		return
	_player_coins.add_bonus_coins(player.bonus_faces)
	_enemy_coins.add_bonus_coins(enemy.bonus_faces)
	await _wait(_settings.coin_arrange_duration)


func _arrange_coins() -> void:
	_player_coins.arrange(PLAYER_COIN_ORDER)
	await _enemy_coins.arrange(ENEMY_COIN_ORDER)


## Attacca prima il giocatore; il nemico risponde solo se è ancora vivo.
func _play_resolution(result: CombatResult) -> void:
	await _wait(_settings.pause_between_steps)
	await _player_panel.play_attack(1.0, _settings.attack_duration)
	await _enemy_panel.play_hit(result.damage_to_enemy, _settings.attack_duration)
	if result.enemy_responded:
		await _wait(_settings.pause_between_steps)
		await _enemy_panel.play_attack(-1.0, _settings.attack_duration)
		await _player_panel.play_hit(result.damage_to_player, _settings.attack_duration)


func _get_outcome_text(result: CombatResult) -> String:
	if not result.is_player_alive():
		return player_defeated_text
	if not result.is_enemy_alive():
		return enemy_defeated_text
	return enemy_survived_text


func _set_state(new_state: State) -> void:
	state = new_state
	state_changed.emit(new_state)


func _wait(seconds: float) -> void:
	if seconds > 0.0:
		await get_tree().create_timer(seconds).timeout
