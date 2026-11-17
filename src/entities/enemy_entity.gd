class_name EnemyEntity
extends BoardEntity
## Nemico sulla board. Gli HP persistono se il nemico sopravvive al combattimento.

var hp: int


func _init(p_definition: EnemyDefinition) -> void:
	super(p_definition)
	hp = p_definition.max_hp


func get_enemy_definition() -> EnemyDefinition:
	return definition as EnemyDefinition
