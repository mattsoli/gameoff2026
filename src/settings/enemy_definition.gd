@tool
class_name EnemyDefinition
extends EntityDefinition
## Nemico: entrare nella sua casella avvia il combattimento.

@export_group("Statistiche")
@export_range(1, 999) var max_hp: int = 3
@export_range(0, 99) var coin_count: int = 2
## Monete di combattimento guadagnate dal giocatore quando lo sconfigge.
@export_range(0, 99) var coin_reward: int = 1
## Effetti aggiuntivi della categoria di nemico (es. +1 scudo).
@export var effects: Array[CombatEffect] = []

@export_group("Visual")
## Sprite nella schermata di combattimento. Se vuota usa il colore dell'icona.
@export var combat_texture: Texture2D


func create_entity() -> BoardEntity:
	return EnemyEntity.new(self)
