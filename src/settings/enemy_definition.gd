@tool
class_name EnemyDefinition
extends EntityDefinition
## Nemico: entrare nella sua casella avvia il combattimento.

@export_group("Statistiche")
## Valore di attacco: in combattimento vince chi ha il valore più alto.
@export_range(0, 999) var attack: int = 1

@export_group("Visual")
## Sprite nella schermata di combattimento. Se vuota usa il colore dell'icona.
@export var combat_texture: Texture2D


func create_entity() -> BoardEntity:
	return EnemyEntity.new(self)
