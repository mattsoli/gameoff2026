@tool
class_name EnemyEntity
extends BoardEntity
## Nemico sulla board. Il combattimento è deterministico: o vince o viene rimosso.


func get_enemy_definition() -> EnemyDefinition:
	return definition as EnemyDefinition
