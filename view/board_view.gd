class_name BoardView
extends Node2D

var tile_size: float = 72.0

var _board: BoardModel
var _tile_views: Dictionary[TileInstance, TileView] = {}
var _pawn_view: PawnView


func setup(board: BoardModel, p_tile_size: float, pawn: PawnState, goal: GoalDefinition) -> void:
	_board = board
	tile_size = p_tile_size

	for y: int in board.size.y:
		for x: int in board.size.x:
			var cell: Vector2i = Vector2i(x, y)
			var view: TileView = _create_tile_view(board.get_tile(cell))
			view.position = cell_to_local(cell)

	if goal != null:
		var goal_view: GoalView = GoalView.new()
		add_child(goal_view)
		goal_view.setup(goal, board.size, tile_size)

	_pawn_view = PawnView.new()
	_pawn_view.z_index = 1
	add_child(_pawn_view)
	_pawn_view.position = cell_to_local(pawn.cell)
	_pawn_view.set_facing(pawn.direction)


func cell_to_local(cell: Vector2i) -> Vector2:
	return (Vector2(cell) + Vector2(0.5, 0.5)) * tile_size


func play_shift(turn: TurnResult, duration: float) -> void:
	var insert: InsertResult = turn.insert
	var push: Vector2 = Vector2(Direction.to_vector(insert.slot.push_direction)) * tile_size

	var entering: TileView = _create_tile_view(insert.inserted)
	entering.position = cell_to_local(insert.line_cells[0]) - push
	var leaving: TileView = _tile_views[insert.pushed_out]

	var tween: Tween = create_tween().set_parallel(true)
	for cell: Vector2i in insert.line_cells:
		var view: TileView = _tile_views[_board.get_tile(cell)]
		tween.tween_property(view, "position", cell_to_local(cell), duration)
	tween.tween_property(leaving, "position", leaving.position + push, duration)

	if turn.pawn_shifted:
		var target: Vector2
		if turn.pawn_pushed_out:
			target = _pawn_view.position + push
		else:
			target = cell_to_local(turn.pawn_cell_after_shift)
		tween.tween_property(_pawn_view, "position", target, duration)

	await tween.finished

	_tile_views.erase(insert.pushed_out)
	leaving.queue_free()
	if turn.pawn_wrapped:
		_pawn_view.position = cell_to_local(turn.pawn_cell_after_shift)


func play_pawn_phase(turn: TurnResult, duration: float) -> void:
	_pawn_view.set_facing(turn.direction)
	_pawn_view.set_intent(turn.intent, turn.intent_direction)
	if not turn.pawn_moved:
		return
	var tween: Tween = create_tween()
	tween.tween_property(_pawn_view, "position", cell_to_local(turn.move_to), duration)
	await tween.finished


func _create_tile_view(tile: TileInstance) -> TileView:
	var view: TileView = TileView.new()
	add_child(view)
	view.setup(tile, tile_size)
	_tile_views[tile] = view
	return view
