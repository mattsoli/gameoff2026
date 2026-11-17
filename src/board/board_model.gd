class_name BoardModel
extends RefCounted
## Griglia di CellData. Sa solo leggere/scrivere celle e far scorrere righe/colonne:
## non conosce le regole di gioco (quelle stanno in LevelSession).

var size: Vector2i
var _cells: Array[CellData] = []


func _init(p_size: Vector2i) -> void:
	size = p_size
	_cells.resize(size.x * size.y)


func is_inside(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < size.x and cell.y < size.y


func get_cell(cell: Vector2i) -> CellData:
	return _cells[_to_index(cell)]


func set_cell(cell: Vector2i, data: CellData) -> void:
	_cells[_to_index(cell)] = data


func get_all_positions() -> Array[Vector2i]:
	var positions: Array[Vector2i] = []
	for y: int in size.y:
		for x: int in size.x:
			positions.append(Vector2i(x, y))
	return positions


## Riga (direzione orizzontale) o colonna (verticale) che contiene `cell`,
## ordinata nel verso di `direction`: il primo elemento è il bordo da cui le caselle
## rientrano, l'ultimo quello da cui escono.
func get_line(cell: Vector2i, direction: Direction.Type) -> Array[Vector2i]:
	var line: Array[Vector2i] = []
	var step: Vector2i = Direction.to_vector(direction)
	if step == Vector2i.ZERO:
		return line

	var start: Vector2i = Vector2i.ZERO
	match direction:
		Direction.Type.RIGHT:
			start = Vector2i(0, cell.y)
		Direction.Type.LEFT:
			start = Vector2i(size.x - 1, cell.y)
		Direction.Type.DOWN:
			start = Vector2i(cell.x, 0)
		Direction.Type.UP:
			start = Vector2i(cell.x, size.y - 1)

	var length: int = size.x if Direction.is_horizontal(direction) else size.y
	for i: int in length:
		line.append(start + step * i)
	return line


## Fa scorrere di una casella la linea che contiene `cell` nel verso di `direction`.
## La casella che esce dal bordo rientra dal lato opposto. Restituisce la linea coinvolta.
func shift_line(cell: Vector2i, direction: Direction.Type) -> Array[Vector2i]:
	var line: Array[Vector2i] = get_line(cell, direction)
	if line.is_empty():
		return line
	var exiting: CellData = get_cell(line[line.size() - 1])
	for i: int in range(line.size() - 1, 0, -1):
		set_cell(line[i], get_cell(line[i - 1]))
	set_cell(line[0], exiting)
	return line


## Dove finisce una posizione dopo lo shift di `line` (invariata se non ne fa parte).
static func get_shifted_position(cell: Vector2i, line: Array[Vector2i]) -> Vector2i:
	var index: int = line.find(cell)
	if index == -1:
		return cell
	return line[(index + 1) % line.size()]


func _to_index(cell: Vector2i) -> int:
	assert(is_inside(cell), "Cella fuori dalla board: %s" % cell)
	return cell.y * size.x + cell.x
