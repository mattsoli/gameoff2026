class_name BoardModel
extends RefCounted

var size: Vector2i
var _cells: Array[TileInstance] = []


func _init(p_size: Vector2i) -> void:
	size = p_size
	_cells.resize(size.x * size.y)


func is_inside(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < size.x and cell.y < size.y


func get_tile(cell: Vector2i) -> TileInstance:
	return _cells[_to_index(cell)]


func set_tile(cell: Vector2i, tile: TileInstance) -> void:
	_cells[_to_index(cell)] = tile


func is_valid_slot(slot: InsertSlot) -> bool:
	match slot.push_direction:
		Direction.Type.LEFT, Direction.Type.RIGHT:
			return slot.line_index >= 0 and slot.line_index < size.y
		Direction.Type.UP, Direction.Type.DOWN:
			return slot.line_index >= 0 and slot.line_index < size.x
		_:
			return false


func get_all_slots() -> Array[InsertSlot]:
	var slots: Array[InsertSlot] = []
	for row: int in size.y:
		slots.append(InsertSlot.new(Direction.Type.RIGHT, row))
		slots.append(InsertSlot.new(Direction.Type.LEFT, row))
	for column: int in size.x:
		slots.append(InsertSlot.new(Direction.Type.DOWN, column))
		slots.append(InsertSlot.new(Direction.Type.UP, column))
	return slots


## Celle coinvolte nello shift, ordinate dall'ingresso all'uscita.
func get_line_cells(slot: InsertSlot) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var entry: Vector2i
	var length: int
	match slot.push_direction:
		Direction.Type.RIGHT:
			entry = Vector2i(0, slot.line_index)
			length = size.x
		Direction.Type.LEFT:
			entry = Vector2i(size.x - 1, slot.line_index)
			length = size.x
		Direction.Type.DOWN:
			entry = Vector2i(slot.line_index, 0)
			length = size.y
		Direction.Type.UP:
			entry = Vector2i(slot.line_index, size.y - 1)
			length = size.y
		_:
			return cells
	var step: Vector2i = Direction.to_vector(slot.push_direction)
	for i: int in length:
		cells.append(entry + step * i)
	return cells


## Inserisce il tile, fa scorrere la linea e restituisce il tile espulso.
func insert_tile(slot: InsertSlot, tile: TileInstance) -> InsertResult:
	assert(is_valid_slot(slot), "InsertSlot non valido")
	var line: Array[Vector2i] = get_line_cells(slot)

	var result: InsertResult = InsertResult.new()
	result.slot = slot
	result.inserted = tile
	result.pushed_out = get_tile(line[line.size() - 1])
	result.line_cells = line

	for i: int in range(line.size() - 1, 0, -1):
		set_tile(line[i], get_tile(line[i - 1]))
	set_tile(line[0], tile)
	return result


## Dove finisce una cella (es. quella del player) dopo lo shift di uno slot.
## Non dipende dal contenuto della board, quindi si può chiamare prima o dopo l'inserimento.
func shift_cell(cell: Vector2i, slot: InsertSlot) -> Vector2i:
	var line: Array[Vector2i] = get_line_cells(slot)
	if not line.has(cell):
		return cell
	var next: Vector2i = cell + Direction.to_vector(slot.push_direction)
	if is_inside(next):
		return next
	return line[0]


func _to_index(cell: Vector2i) -> int:
	assert(is_inside(cell), "Cella fuori dalla board: %s" % cell)
	return cell.y * size.x + cell.x
