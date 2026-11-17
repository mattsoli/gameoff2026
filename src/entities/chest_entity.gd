@tool
class_name ChestEntity
extends BoardEntity
## Baule sulla board. Resta sulla casella anche dopo l'apertura (es. per tenere la freccia).

var is_opened: bool = false


func get_chest_definition() -> ChestDefinition:
	return definition as ChestDefinition
