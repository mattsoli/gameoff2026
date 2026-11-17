@tool
class_name ParsedLevel
extends RefCounted
## Risultato di LevelParser: la board pronta da giocare oppure la lista degli errori.

var board: BoardModel
var player_start: Vector2i = Vector2i(-1, -1)
var errors: PackedStringArray = PackedStringArray()


func is_valid() -> bool:
	return errors.is_empty() and board != null
