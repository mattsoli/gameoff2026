class_name ShiftResult
extends RefCounted
## Descrive uno shifting già applicato al modello, per permettere alla view di animarlo.

var direction: Direction.Type = Direction.Type.NONE
## Celle della linea nel verso dello shift (line[0] = bordo di rientro).
var line: Array[Vector2i] = []
var player_from: Vector2i
var player_to: Vector2i


func does_player_move() -> bool:
	return player_from != player_to


## True se la pedina è uscita dal bordo ed è rientrata dal lato opposto.
func does_player_wrap() -> bool:
	return not line.is_empty() and player_from == line[line.size() - 1] and player_to == line[0]
