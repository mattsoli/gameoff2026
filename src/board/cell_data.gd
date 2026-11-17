@tool
class_name CellData
extends RefCounted
## Contenuto di una casella: tipo, freccia ed elemento.
## Durante lo shifting si sposta tutto insieme, per questo è un oggetto
## (la view lo usa anche come chiave per ritrovare la sua TileView).

var tile: TileDefinition
var arrow: Direction.Type = Direction.Type.NONE
var entity: BoardEntity


func _init(p_tile: TileDefinition, p_arrow: Direction.Type = Direction.Type.NONE, p_entity: BoardEntity = null) -> void:
	tile = p_tile
	arrow = p_arrow
	entity = p_entity


func has_arrow() -> bool:
	return arrow != Direction.Type.NONE


func has_entity() -> bool:
	return entity != null
