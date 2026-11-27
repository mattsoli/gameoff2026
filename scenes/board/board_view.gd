class_name BoardView
extends Control
## Rappresentazione grafica della board: crea le TileView, la pedina e l'overlay delle preview,
## gestisce hover/click del mouse e anima movimento e shifting.
## Legge il BoardModel ma non lo modifica mai: le regole stanno in LevelSession.

signal cell_clicked(cell: Vector2i)

const INVALID_CELL: Vector2i = Vector2i(-1, -1)
const PAWN_Z_INDEX: int = 5
const OVERLAY_Z_INDEX: int = 10

var _board: BoardModel
var _settings: BoardVisualSettings
var _player_definition: PlayerDefinition
var _tile_size: float = 0.0
var _pitch: float = 0.0
var _tile_views: Dictionary[CellData, TileView] = {}
var _pawn_view: PawnView
var _overlay: BoardOverlay
var _board_style: StyleBoxFlat = StyleBoxFlat.new()
var _hovered_cell: Vector2i = INVALID_CELL
var _reachable_cells: Array[Vector2i] = []
var _goals_unlocked: bool = false
var _player_attack: int = 0


func setup(board: BoardModel, settings: BoardVisualSettings, player_definition: PlayerDefinition, player_cell: Vector2i) -> void:
	_board = board
	_settings = settings
	_player_definition = player_definition
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP

	_tile_size = _compute_tile_size()
	_pitch = _tile_size + settings.tile_gap
	custom_minimum_size = Vector2(board.size) * _pitch + Vector2.ONE * settings.tile_gap
	_board_style.bg_color = settings.board_color
	_board_style.set_corner_radius_all(settings.tile_corner_radius)

	for cell: Vector2i in board.get_all_positions():
		var view: TileView = _create_tile_view(board.get_cell(cell))
		view.position = cell_to_center(cell)
		_tile_views[board.get_cell(cell)] = view

	_pawn_view = _create_pawn_view()
	_pawn_view.position = cell_to_center(player_cell)

	_overlay = BoardOverlay.new()
	_overlay.z_index = OVERLAY_Z_INDEX
	_overlay.setup(settings)
	add_child(_overlay)
	queue_redraw()


func cell_to_center(cell: Vector2i) -> Vector2:
	return Vector2.ONE * (_settings.tile_gap + _tile_size * 0.5) + Vector2(cell) * _pitch


func cell_to_rect(cell: Vector2i) -> Rect2:
	return Rect2(cell_to_center(cell) - Vector2.ONE * _tile_size * 0.5, Vector2.ONE * _tile_size)


## INVALID_CELL se il punto è fuori dalla board.
func local_to_cell(local_position: Vector2) -> Vector2i:
	var cell: Vector2i = Vector2i(((local_position - Vector2.ONE * _settings.tile_gap * 0.5) / _pitch).floor())
	return cell if _board.is_inside(cell) else INVALID_CELL


func set_reachable_cells(cells: Array[Vector2i]) -> void:
	_reachable_cells = cells
	_refresh_previews()


func clear_reachable_cells() -> void:
	_reachable_cells = []
	_refresh_previews()


func set_goals_unlocked(value: bool) -> void:
	_goals_unlocked = value
	for view: TileView in _tile_views.values():
		view.set_goal_unlocked(value)


## Valore di attacco mostrato sulla pedina (cambia raccogliendo un'arma).
func set_player_attack(value: int) -> void:
	_player_attack = value
	_pawn_view.set_attack(value)


## Ridisegna tutte le caselle (dopo raccolta chiave, apertura baule, combattimento...).
## Si ridisegna tutto e non per posizione perché nel frattempo uno shift può aver
## già spostato nel modello la casella modificata.
func refresh_cells() -> void:
	for view: TileView in _tile_views.values():
		view.refresh()


func play_pawn_move(cell: Vector2i) -> void:
	_pawn_view.play_move_animation()
	var tween: Tween = create_tween()
	UiAnimation.tween_property(tween, _pawn_view, "position", cell_to_center(cell), _settings.move_animation)
	await tween.finished


## La pedina fa solo una parte (`fraction`) del passo verso `cell` e si ferma lì.
func play_pawn_stop(cell: Vector2i, fraction: float, animation: UiAnimation) -> void:
	_pawn_view.play_move_animation()
	var target: Vector2 = _pawn_view.position.lerp(cell_to_center(cell), fraction)
	var tween: Tween = create_tween()
	UiAnimation.tween_property(tween, _pawn_view, "position", target, animation)
	await tween.finished


func play_pawn_bump(direction: Direction.Type) -> void:
	await _pawn_view.play_bump(direction, _settings.bump_distance, _settings.bump_animation)


## Anima uno shift già applicato al modello. La casella che esce dal bordo scorre fuori,
## mentre una sua copia temporanea ("ghost") rientra dal lato opposto. Idem per la pedina.
func play_shift(shift: ShiftResult) -> void:
	var line: Array[Vector2i] = shift.line
	var step: Vector2i = Direction.to_vector(shift.direction)
	var last_cell: Vector2i = line[line.size() - 1]
	var animation: UiAnimation = _settings.shift_animation
	var tween: Tween = create_tween().set_parallel(true)

	for i: int in range(1, line.size()):
		UiAnimation.tween_property(tween, _get_view(line[i]), "position", cell_to_center(line[i]), animation)

	var wrapped_data: CellData = _board.get_cell(line[0])
	var wrapped_view: TileView = _tile_views[wrapped_data]
	var tile_ghost: TileView = _create_tile_view(wrapped_data)
	tile_ghost.position = cell_to_center(line[0] - step)
	UiAnimation.tween_property(tween, wrapped_view, "position", cell_to_center(last_cell + step), animation)
	UiAnimation.tween_property(tween, tile_ghost, "position", cell_to_center(line[0]), animation)

	var pawn_ghost: PawnView = null
	if shift.does_player_wrap():
		pawn_ghost = _create_pawn_view()
		pawn_ghost.position = cell_to_center(shift.player_to - step)
		UiAnimation.tween_property(tween, _pawn_view, "position", cell_to_center(shift.player_from + step), animation)
		UiAnimation.tween_property(tween, pawn_ghost, "position", cell_to_center(shift.player_to), animation)
	elif shift.does_player_move():
		UiAnimation.tween_property(tween, _pawn_view, "position", cell_to_center(shift.player_to), animation)

	await tween.finished

	wrapped_view.position = cell_to_center(line[0])
	tile_ghost.queue_free()
	if pawn_ghost != null:
		_pawn_view.position = cell_to_center(shift.player_to)
		pawn_ghost.queue_free()
	_refresh_previews()


func _draw() -> void:
	if _board != null:
		draw_style_box(_board_style, Rect2(Vector2.ZERO, size))


func _gui_input(event: InputEvent) -> void:
	if _board == null:
		return
	if event is InputEventMouseMotion:
		_set_hovered_cell(local_to_cell((event as InputEventMouseMotion).position))
	elif event is InputEventMouseButton:
		var button: InputEventMouseButton = event as InputEventMouseButton
		if button.pressed and button.button_index == MOUSE_BUTTON_LEFT:
			var cell: Vector2i = local_to_cell(button.position)
			if cell != INVALID_CELL:
				cell_clicked.emit(cell)
				accept_event()


func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_EXIT:
		_set_hovered_cell(INVALID_CELL)


func _set_hovered_cell(cell: Vector2i) -> void:
	if cell == _hovered_cell:
		return
	_hovered_cell = cell
	_refresh_previews()


func _refresh_previews() -> void:
	if _overlay == null:
		return
	var reachable_rects: Array[Rect2] = []
	for cell: Vector2i in _reachable_cells:
		reachable_rects.append(cell_to_rect(cell))
	_overlay.set_reachable_rects(reachable_rects)

	var shift_rects: Array[Rect2] = []
	if _hovered_cell != INVALID_CELL:
		var data: CellData = _board.get_cell(_hovered_cell)
		if data.has_arrow():
			for cell: Vector2i in _board.get_line(_hovered_cell, data.arrow):
				shift_rects.append(cell_to_rect(cell))
	_overlay.set_shift_preview_rects(shift_rects)


func _get_view(cell: Vector2i) -> TileView:
	return _tile_views[_board.get_cell(cell)]


func _create_tile_view(data: CellData) -> TileView:
	var view: TileView = TileView.new()
	# Prima nell'albero, poi setup: le scene animate partono subito con "idle".
	add_child(view)
	view.setup(data, _settings, _tile_size)
	view.set_goal_unlocked(_goals_unlocked, false)
	return view


func _create_pawn_view() -> PawnView:
	var pawn: PawnView = PawnView.new()
	pawn.z_index = PAWN_Z_INDEX
	add_child(pawn)
	pawn.setup(_player_definition, _tile_size, _settings.label_font_size, _settings.scene_reference_size)
	pawn.set_attack(_player_attack)
	return pawn


## Riduce la casella se la board non entra nell'area massima configurata.
func _compute_tile_size() -> float:
	var gap: float = _settings.tile_gap
	var available: Vector2 = _settings.max_board_size - Vector2.ONE * gap
	var fit: Vector2 = available / Vector2(_board.size) - Vector2.ONE * gap
	return minf(_settings.tile_size, minf(fit.x, fit.y))
