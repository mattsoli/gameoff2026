class_name Game
extends Node2D

@export var config: GameConfig

const TOP_MARGIN: float = 90.0
const HAND_GAP: float = 70.0

var _session: GameSession
var _board_view: BoardView
var _slots_view: InsertSlotsView
var _hand_view: HandView
var _is_busy: bool = false


func _ready() -> void:
	assert(config != null, "Assegna un GameConfig nell'Inspector")
	_session = GameSession.new(config)

	var board_pixels: Vector2 = Vector2(config.board_size) * config.tile_size
	var origin: Vector2 = Vector2((get_viewport_rect().size.x - board_pixels.x) * 0.5, TOP_MARGIN)

	_board_view = BoardView.new()
	_board_view.position = origin
	add_child(_board_view)
	_board_view.setup(_session.board, config.tile_size, _session.pawn, config.goal)

	_slots_view = InsertSlotsView.new()
	_slots_view.position = origin
	add_child(_slots_view)
	_slots_view.setup(_session.get_available_slots(), config.board_size, config.tile_size)
	_slots_view.slot_pressed.connect(_on_slot_pressed)

	_hand_view = HandView.new()
	_hand_view.position = origin + Vector2(0.0, board_pixels.y + HAND_GAP)
	add_child(_hand_view)
	_refresh_hand()


func _unhandled_input(event: InputEvent) -> void:
	if _is_busy:
		return
	if event.is_action_pressed("ui_left"):
		_session.cycle_selection(-1)
		_refresh_hand()
	elif event.is_action_pressed("ui_right"):
		_session.cycle_selection(1)
		_refresh_hand()


func _on_slot_pressed(slot: InsertSlot) -> void:
	if _is_busy:
		return
	var turn: TurnResult = _session.play_turn(slot)
	if turn == null:
		return

	_is_busy = true
	_slots_view.set_enabled(false)
	await _board_view.play_shift(turn, config.shift_duration)
	_refresh_hand()
	await _board_view.play_pawn_phase(turn, config.move_duration)

	if turn.outcome == GameSession.Outcome.PLAYING:
		_slots_view.set_enabled(true)
		_is_busy = false
	else:
		_show_outcome(turn.outcome)


func _show_outcome(outcome: GameSession.Outcome) -> void:
	var label: Label = Label.new()
	label.text = "HAI VINTO" if outcome == GameSession.Outcome.WON else "HAI PERSO"
	label.add_theme_font_size_override("font_size", 32)
	label.position = Vector2(20.0, 20.0)
	add_child(label)


func _refresh_hand() -> void:
	_hand_view.refresh(_session.hand, _session.selected_hand_index, config.tile_size)
