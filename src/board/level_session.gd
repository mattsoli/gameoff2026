class_name LevelSession
extends RefCounted
## Regole di un livello in corso: movimento, raccolta oggetti, combattimento, shifting, vittoria.
## È pura logica (nessun nodo, nessuna animazione): la view legge i risultati e li anima.

enum Status { PLAYING, WON, LOST }

var board: BoardModel
var player: PlayerState
var player_cell: Vector2i
var has_key: bool = false
var status: Status = Status.PLAYING

## Mossa verso un nemico in attesa dell'esito del combattimento.
var _pending_combat: MoveResult


func _init(parsed: ParsedLevel, p_player: PlayerState) -> void:
	assert(parsed.is_valid(), "LevelSession richiede un ParsedLevel valido")
	board = parsed.board
	player_cell = parsed.player_start
	player = p_player


func is_playing() -> bool:
	return status == Status.PLAYING and _pending_combat == null


## Una casella è calpestabile se esiste, il suo tipo lo consente
## e, se è un obiettivo, la chiave è già stata raccolta.
func is_walkable(cell: Vector2i) -> bool:
	if not board.is_inside(cell):
		return false
	var tile: TileDefinition = board.get_cell(cell).tile
	if not tile.is_walkable:
		return false
	return has_key or not tile.is_goal


## Caselle adiacenti in cui la pedina può entrare adesso (per la preview).
func get_reachable_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for direction: Direction.Type in Direction.all():
		var target: Vector2i = player_cell + Direction.to_vector(direction)
		if is_walkable(target):
			cells.append(target)
	return cells


func try_move(direction: Direction.Type) -> MoveResult:
	var result: MoveResult = MoveResult.new()
	result.direction = direction
	result.from = player_cell
	result.to = player_cell + Direction.to_vector(direction)

	if not is_playing() or not is_walkable(result.to):
		result.type = MoveResult.Type.BLOCKED
		return result

	var target: CellData = board.get_cell(result.to)
	if target.entity is EnemyEntity:
		result.type = MoveResult.Type.COMBAT
		result.enemy = target.entity as EnemyEntity
		_pending_combat = result
		return result

	player_cell = result.to
	result.type = MoveResult.Type.MOVED
	return result


## Applica gli effetti della casella in cui si trova la pedina.
## Ordine: chiave/arma -> obiettivo -> freccia (lo shift avviene per ultimo).
func arrive() -> ArrivalResult:
	var arrival: ArrivalResult = ArrivalResult.new()
	arrival.cell = player_cell
	var data: CellData = board.get_cell(player_cell)

	if data.entity is KeyEntity:
		has_key = true
		data.entity = null
		arrival.picked_key = true
	elif data.entity is WeaponEntity:
		var weapon: WeaponDefinition = (data.entity as WeaponEntity).get_weapon_definition()
		player.equip_weapon(weapon)
		data.entity = null
		arrival.picked_weapon = weapon

	if data.tile.is_goal:
		status = Status.WON
		arrival.reached_goal = true
		return arrival

	if data.has_arrow():
		arrival.shift = _shift(player_cell, data.arrow)
	return arrival


## Da chiamare a fine combattimento. Se vince il giocatore il nemico viene rimosso,
## la pedina entra nella casella e ne riceve gli effetti (ArrivalResult).
## Se vince il nemico il livello è perso (LOST) e restituisce null.
func resolve_combat(combat: CombatResult) -> ArrivalResult:
	assert(_pending_combat != null, "resolve_combat chiamato senza un combattimento in corso")
	var move: MoveResult = _pending_combat
	_pending_combat = null

	if not combat.is_player_winner:
		status = Status.LOST
		return null

	board.get_cell(move.to).entity = null
	player_cell = move.to
	return arrive()


func _shift(cell: Vector2i, direction: Direction.Type) -> ShiftResult:
	var shift: ShiftResult = ShiftResult.new()
	shift.direction = direction
	shift.player_from = player_cell
	shift.line = board.shift_line(cell, direction)
	# La pedina segue la casella su cui si trova.
	player_cell = BoardModel.get_shifted_position(player_cell, shift.line)
	shift.player_to = player_cell
	return shift
