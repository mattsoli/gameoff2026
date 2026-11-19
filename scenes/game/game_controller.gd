class_name GameController
extends Control
## Regista della scena di gioco: legge l'input, chiede a LevelSession di applicare le regole
## e fa animare il risultato a BoardView / CombatScreen. Mentre un'animazione è in corso
## l'input viene ignorato (_is_busy).

@export_group("Testi")
@export var level_completed_title: String = "Level complete!"
@export var next_level_text: String = "Next level"
@export var victory_title: String = "Victory!"
@export var victory_message: String = "You completed all the levels."
@export var menu_text: String = "Main menu"
@export var level_error_title: String = "Level error"

var _settings: GameSettings
var _session: LevelSession
var _is_busy: bool = false

@onready var _background: ColorRect = %Background
@onready var _board_view: BoardView = %BoardView
@onready var _hud: GameHud = %Hud
@onready var _combat_screen: CombatScreen = %CombatScreen
@onready var _result_overlay: ResultOverlay = %ResultOverlay


func _ready() -> void:
	_settings = RunManager.settings
	_background.color = _settings.board.background_color
	_hud.restart_requested.connect(RunManager.restart_level)
	_hud.menu_requested.connect(RunManager.go_to_main_menu)

	var parsed: ParsedLevel = LevelParser.parse(RunManager.get_current_level())
	if not parsed.is_valid():
		_show_level_errors(parsed.errors)
		return

	# Il giocatore riparte da zero a ogni livello (senza arma).
	_session = LevelSession.new(parsed, PlayerState.create(_settings.player))
	_board_view.setup(_session.board, _settings.board, _settings.player, _session.player_cell)
	_board_view.set_player_attack(_session.player.get_attack())
	_board_view.cell_clicked.connect(_on_cell_clicked)
	_refresh()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"restart_level"):
		RunManager.restart_level()
		return
	if not _can_act():
		return
	var direction: Direction.Type = _get_event_direction(event)
	if direction != Direction.Type.NONE:
		get_viewport().set_input_as_handled()
		_request_move(direction, true)


## Movimento continuo tenendo premuto il tasto (senza feedback "bump" ripetuto).
func _process(_delta: float) -> void:
	if not _settings.hold_to_move or not _can_act():
		return
	var direction: Direction.Type = _get_held_direction()
	if direction != Direction.Type.NONE:
		_request_move(direction, false)


func _can_act() -> bool:
	return not _is_busy and _session != null and _session.is_playing()


func _on_cell_clicked(cell: Vector2i) -> void:
	if not _can_act():
		return
	var direction: Direction.Type = Direction.from_vector(cell - _session.player_cell)
	if direction != Direction.Type.NONE:
		_request_move(direction, true)


func _request_move(direction: Direction.Type, show_blocked_feedback: bool) -> void:
	var move: MoveResult = _session.try_move(direction)
	if move.type == MoveResult.Type.BLOCKED and not show_blocked_feedback:
		return

	_is_busy = true
	_board_view.clear_reachable_cells()
	match move.type:
		MoveResult.Type.BLOCKED:
			await _board_view.play_pawn_bump(direction)
		MoveResult.Type.MOVED:
			await _board_view.play_pawn_move(move.to)
			await _handle_arrival(_session.arrive())
		MoveResult.Type.COMBAT:
			await _board_view.play_pawn_move(move.to)
			await _handle_combat(move)
	_is_busy = false
	_refresh()


func _handle_combat(move: MoveResult) -> void:
	var player: Combatant = Combatant.from_player(_session.player)
	var enemy: Combatant = Combatant.from_enemy(move.enemy)
	var result: CombatResult = await _combat_screen.run_combat(player, enemy, _settings.combat)
	var arrival: ArrivalResult = _session.resolve_combat(result)
	if not result.is_player_winner:
		# Game over: il livello ricomincia subito da capo.
		RunManager.restart_level()
		return
	await _handle_arrival(arrival)


func _handle_arrival(arrival: ArrivalResult) -> void:
	_board_view.refresh_cells()
	if arrival.picked_key:
		_board_view.set_goals_unlocked(true)
	_board_view.set_player_attack(_session.player.get_attack())
	_refresh()

	if arrival.reached_goal:
		await _show_level_completed()
	elif arrival.shift != null:
		await _board_view.play_shift(arrival.shift)


func _show_level_completed() -> void:
	if RunManager.has_next_level():
		if await _result_overlay.ask(level_completed_title, "", next_level_text, menu_text):
			RunManager.advance_to_next_level()
		else:
			RunManager.go_to_main_menu()
	else:
		await _result_overlay.ask(victory_title, victory_message, menu_text)
		RunManager.go_to_main_menu()


func _show_level_errors(errors: PackedStringArray) -> void:
	for error: String in errors:
		push_error("[Level] %s" % error)
	await _result_overlay.ask(level_error_title, "\n".join(errors), menu_text)
	RunManager.go_to_main_menu()


func _refresh() -> void:
	var level: LevelDefinition = RunManager.get_current_level()
	_hud.refresh(RunManager.get_level_number(), level.display_name, _session.player, _session.has_key)
	if _can_act():
		_board_view.set_reachable_cells(_session.get_reachable_cells())
	else:
		_board_view.clear_reachable_cells()


func _get_event_direction(event: InputEvent) -> Direction.Type:
	if event.is_action_pressed(&"move_up"):
		return Direction.Type.UP
	if event.is_action_pressed(&"move_right"):
		return Direction.Type.RIGHT
	if event.is_action_pressed(&"move_down"):
		return Direction.Type.DOWN
	if event.is_action_pressed(&"move_left"):
		return Direction.Type.LEFT
	return Direction.Type.NONE


func _get_held_direction() -> Direction.Type:
	if Input.is_action_pressed(&"move_up"):
		return Direction.Type.UP
	if Input.is_action_pressed(&"move_right"):
		return Direction.Type.RIGHT
	if Input.is_action_pressed(&"move_down"):
		return Direction.Type.DOWN
	if Input.is_action_pressed(&"move_left"):
		return Direction.Type.LEFT
	return Direction.Type.NONE
