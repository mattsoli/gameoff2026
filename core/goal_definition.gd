class_name GoalDefinition
extends Resource

## Lato della board oltre il quale si trova l'obiettivo (RIGHT = oltre il bordo destro).
@export var exit_side: Direction.Type = Direction.Type.RIGHT
## Riga (lati LEFT/RIGHT) o colonna (lati UP/DOWN) in cui si trova l'obiettivo.
@export var line_index: int = 0


## `cell` deve essere una cella di bordo dal lato `exit_direction`: lo garantisce il chiamante.
func matches(cell: Vector2i, exit_direction: Direction.Type) -> bool:
	if exit_direction != exit_side:
		return false
	var line: int = cell.y if Direction.is_horizontal(exit_direction) else cell.x
	return line == line_index
