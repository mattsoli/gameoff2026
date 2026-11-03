class_name GameSession
extends RefCounted

enum Outcome { PLAYING, WON, LOST }

var board: BoardModel
var pawn: PawnState
var hand: Array[TileInstance] = []
var selected_hand_index: int = 0
var outcome: Outcome = Outcome.PLAYING

var _config: GameConfig
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _init(config: GameConfig) -> void:
	assert(config.hand_size > 0, "hand_size deve essere > 0")
	assert(config.pawn_behavior != null, "Assegna un PawnBehavior nel GameConfig")
	assert(config.start_direction != Direction.Type.NONE, "start_direction non può essere NONE")
	_config = config

	if config.rng_seed == 0:
		_rng.randomize()
	else:
		_rng.seed = config.rng_seed

	board = BoardGenerator.generate(config.board_size, config.tile_pool, _rng)
	for i: int in config.hand_size:
		hand.append(BoardGenerator.create_random_tile(config.tile_pool, _rng))

	assert(board.is_inside(config.start_cell), "start_cell fuori dalla board")
	_ensure_accessible_start()
	pawn = PawnState.new(config.start_cell, config.start_direction)


func cycle_selection(step: int) -> void:
	if hand.is_empty():
		return
	selected_hand_index = posmod(selected_hand_index + step, hand.size())


## Slot realmente utilizzabili. L'obiettivo è una casella fissa fuori dal bordo:
## occupa il punto d'ingresso opposto, quindi quella linea non si può spingere da quel lato.
func get_available_slots() -> Array[InsertSlot]:
	var slots: Array[InsertSlot] = []
	for slot: InsertSlot in board.get_all_slots():
		if not _is_slot_blocked_by_goal(slot):
			slots.append(slot)
	return slots


## Esegue un turno completo. Restituisce null se il turno non è giocabile.
func play_turn(slot: InsertSlot) -> TurnResult:
	if outcome != Outcome.PLAYING or hand.is_empty():
		return null
	if not board.is_valid_slot(slot) or _is_slot_blocked_by_goal(slot):
		return null

	var turn: TurnResult = TurnResult.new()
	var push: Vector2i = Direction.to_vector(slot.push_direction)
	var line: Array[Vector2i] = board.get_line_cells(slot)

	# 1. La linea che scorre trascina la pedina.
	turn.pawn_cell_before = pawn.cell
	turn.pawn_shifted = line.has(pawn.cell)
	turn.pawn_pushed_out = turn.pawn_shifted and not board.is_inside(pawn.cell + push)
	var reached_goal: bool = turn.pawn_pushed_out and _is_goal(pawn.cell, slot.push_direction)
	turn.pawn_cell_after_shift = board.shift_cell(pawn.cell, slot)

	# 2. Inserimento e gestione della casella espulsa.
	turn.insert = board.insert_tile(slot, hand[selected_hand_index])
	_update_hand(turn.insert.pushed_out)
	pawn.cell = turn.pawn_cell_after_shift

	# 3. Pedina espulsa dalla board: obiettivo, sconfitta o rientro dal lato opposto.
	if turn.pawn_pushed_out:
		if reached_goal:
			outcome = Outcome.WON
		elif _config.pawn_pushed_out_policy == GameConfig.PawnPushedOutPolicy.LOSE:
			outcome = Outcome.LOST
		else:
			turn.pawn_wrapped = true

	# 4. Comportamento della pedina (specifico della modalità).
	if outcome == Outcome.PLAYING:
		_config.pawn_behavior.resolve_turn(self, turn)

	if outcome == Outcome.PLAYING and hand.is_empty():
		outcome = Outcome.LOST

	turn.direction = pawn.direction
	turn.intent = pawn.intent
	turn.intent_direction = pawn.intent_direction
	turn.outcome = outcome
	return turn


# --- API pubblica per le PawnBehavior ---------------------------------------

## Se la casella sotto la pedina impone una direzione, la applica.
func apply_forced_direction() -> void:
	var forced: Direction.Type = board.get_tile(pawn.cell).definition.direction
	if forced != Direction.Type.NONE:
		pawn.direction = forced


## True se la pedina può entrare nella cella adiacente in quella direzione
## (cella accessibile, oppure uscita sull'obiettivo).
func can_pawn_enter(direction: Direction.Type) -> bool:
	assert(direction != Direction.Type.NONE, "direction non può essere NONE")
	var target: Vector2i = pawn.cell + Direction.to_vector(direction)
	if not board.is_inside(target):
		return _is_goal(pawn.cell, direction)
	return board.get_tile(target).definition.is_accessible


## Sposta la pedina di una cella e registra il movimento nel TurnResult.
## Se esce sull'obiettivo la partita è vinta. Restituisce false se il passo è bloccato.
func try_step_pawn(direction: Direction.Type, turn: TurnResult) -> bool:
	turn.move_from = pawn.cell
	turn.move_to = pawn.cell
	if not can_pawn_enter(direction):
		return false

	var target: Vector2i = pawn.cell + Direction.to_vector(direction)
	if board.is_inside(target):
		pawn.cell = target
	else:
		outcome = Outcome.WON
	turn.move_to = target
	turn.pawn_moved = true
	return true


# --- Interni -----------------------------------------------------------------

func _is_goal(cell: Vector2i, exit_direction: Direction.Type) -> bool:
	return _config.goal != null and _config.goal.matches(cell, exit_direction)


func _is_slot_blocked_by_goal(slot: InsertSlot) -> bool:
	var goal: GoalDefinition = _config.goal
	return goal != null \
		and slot.push_direction == Direction.opposite(goal.exit_side) \
		and slot.line_index == goal.line_index


func _update_hand(pushed_out: TileInstance) -> void:
	match _config.pushed_out_tile_policy:
		GameConfig.PushedOutTilePolicy.RETURN_TO_HAND:
			hand[selected_hand_index] = pushed_out
		GameConfig.PushedOutTilePolicy.DISCARD:
			if _config.refill_hand_from_pool:
				hand[selected_hand_index] = BoardGenerator.create_random_tile(_config.tile_pool, _rng)
			else:
				hand.remove_at(selected_hand_index)
				selected_hand_index = clampi(selected_hand_index, 0, maxi(hand.size() - 1, 0))


func _ensure_accessible_start() -> void:
	if board.get_tile(_config.start_cell).definition.is_accessible:
		return
	for definition: TileDefinition in _config.tile_pool:
		if definition.is_accessible:
			board.set_tile(_config.start_cell, TileInstance.new(definition))
			return
	push_error("Il tile_pool non contiene nessuna casella accessibile")
