class_name KeyDefinition
extends EntityDefinition
## Chiave: raccoglierla sblocca le caselle obiettivo del livello.


func create_entity() -> BoardEntity:
	return KeyEntity.new(self)
