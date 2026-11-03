class_name PawnState
extends RefCounted

## Cosa la pedina ha deciso di fare al prossimo turno di azione (mostrato al giocatore).
enum Intent { NONE, MOVE, ROTATE }

var cell: Vector2i
var direction: Direction.Type
var turns_elapsed: int = 0
var intent: Intent = Intent.NONE
var intent_direction: Direction.Type = Direction.Type.NONE


func _init(p_cell: Vector2i, p_direction: Direction.Type) -> void:
	cell = p_cell
	direction = p_direction
