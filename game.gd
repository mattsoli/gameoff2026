class_name Game
extends Node2D

signal reload_requested
signal menu_requested

@export var config: GameConfig

const TOP_MARGIN: float = 90.0
const HAND_GAP: float = 70.0
const HUD_BOTTOM_MARGIN: float = 36.0
const DEBUG_BAR_POSITION: Vector2 = Vector2(20.0, 10.0)

var _session: GameSession
var _board_view: BoardView
var _slots_view: InsertSlotsView
var _hand_view: HandView
var _hud: Label
var _turns_played: int = 0
var _is_busy: bool = false


func _ready() -> void:
	assert(config != null, "Game richiede un GameConfig prima di entrare nell'albero")
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

	_hud = Label.new()
	_hud.position = Vector2(20.0, get_viewport_rect().size.y - HUD_BOTTOM_MARGIN)
	add_child(_hud)
	_refresh_hud()

	_build_debug_bar()


func _unhandled_input(event: InputEvent) -> void:
	# Il restart funziona sempre, anche a partita finita o durante le animazioni.
	if event.is_action_pressed("ui_cancel"):
		reload_requested.emit()
		return
	if _is_busy:
		return
	if event.is_action_pressed("ui_left"):
		_session.cycle_selection(-1)
		_refresh_hand()
	elif event.is_action_pressed("ui_right"):
		_session.cycle_selection(1)
		_refresh_hand()


func _build_debug_bar() -> void:
	var bar: HBoxContainer = HBoxContainer.new()
	bar.position = DEBUG_BAR_POSITION
	add_child(bar)
	_add_debug_button(bar, "Ricarica (Esc)", reload_requested)
	_add_debug_button(bar, "Menu", menu_requested)


func _add_debug_button(parent: Control, text: String, target: Signal) -> void:
	var button: Button = Button.new()
	button.text = text
	# Evita che ui_left/ui_right/Invio agiscano sul focus dei bottoni.
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(target.emit)
	parent.add_child(button)


func _on_slot_pressed(slot: InsertSlot) -> void:
	if _is_busy:
		return
	var turn: TurnResult = _session.play_turn(slot)
	if turn == null:
		return

	_turns_played += 1
	_is_busy = true
	_slots_view.set_enabled(false)
	await _board_view.play_shift(turn, config.shift_duration)
	_refresh_hand()
	await _board_view.play_pawn_phase(turn, config.move_duration)

	if turn.outcome == GameSession.Outcome.PLAYING:
		_refresh_hud()
		_slots_view.set_enabled(true)
		_is_busy = false
	else:
		_show_outcome(turn.outcome)


func _show_outcome(outcome: GameSession.Outcome) -> void:
	var result: String = "HAI VINTO" if outcome == GameSession.Outcome.WON else "HAI PERSO"
	_hud.text = "%s in %d mosse   |   Esc per ricominciare" % [result, _turns_played]
	# _is_busy resta true: l'input di gioco è bloccato, ma restart e menu funzionano.


func _refresh_hand() -> void:
	_hand_view.refresh(_session.hand, _session.selected_hand_index, config.tile_size)


func _refresh_hud() -> void:
	_hud.text = "Mosse: %d   |   ←/→ scegli la casella   |   click sui bordi per inserire" % _turns_played
