@tool
class_name BoardEntity
extends RefCounted
## Stato runtime di un elemento sulla board. La definizione (dati del Designer)
## resta immutabile; qui va solo ciò che cambia durante la partita.

var definition: EntityDefinition


func _init(p_definition: EntityDefinition) -> void:
	definition = p_definition
