class_name LevelLegend
extends Resource
## Associa i simboli usati nei layout testuali dei livelli alle risorse di gioco.
## Una legenda può essere condivisa da più livelli.

## Simbolo (1 carattere) -> tipo di casella. Usato in LevelDefinition.tiles_layout.
@export var tiles: Dictionary[String, TileDefinition] = {}
## Simbolo (1 carattere) -> elemento sulla casella. Usato in LevelDefinition.entities_layout.
@export var entities: Dictionary[String, EntityDefinition] = {}

@export_group("Simboli speciali")
## Nessun elemento / nessuna freccia.
@export var empty_symbol: String = "."
## Posizione iniziale della pedina (in entities_layout).
@export var player_start_symbol: String = "P"
@export var arrow_up_symbol: String = "^"
@export var arrow_right_symbol: String = ">"
@export var arrow_down_symbol: String = "v"
@export var arrow_left_symbol: String = "<"


## Restituisce NONE se il simbolo non è una freccia.
func get_arrow_direction(symbol: String) -> Direction.Type:
	if symbol == arrow_up_symbol:
		return Direction.Type.UP
	if symbol == arrow_right_symbol:
		return Direction.Type.RIGHT
	if symbol == arrow_down_symbol:
		return Direction.Type.DOWN
	if symbol == arrow_left_symbol:
		return Direction.Type.LEFT
	return Direction.Type.NONE
