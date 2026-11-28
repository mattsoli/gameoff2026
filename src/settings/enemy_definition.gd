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
## Scena animata nella schermata di combattimento (sostituisce combat_texture).
## Va disegnata con i piedi in (0, 0) (il personaggio sta sopra l'origine), alta circa
## CombatSettings.scene_reference_size: così le animazioni di scala partono dai piedi.
## Animazioni usate: "idle", "attack" (se vince), "defeat" (se perde).
@export var combat_scene: PackedScene


func create_entity() -> BoardEntity:
	return EnemyEntity.new(self)
