@tool
class_name PlayerDefinition
extends Resource
## Valori di partenza del giocatore all'inizio di una nuova partita.

@export var display_name: String = "Player"

@export_group("Statistiche iniziali")
@export_range(1, 999) var max_hp: int = 10
@export_range(0, 99) var coin_count: int = 3
@export var starting_weapon: EquipmentDefinition
@export var starting_armor: EquipmentDefinition

@export_group("Visual")
@export var color: Color = Color(0.4, 0.6, 1.0)
## Icona della pedina sulla board. Se vuota viene disegnato un cerchio.
@export var board_texture: Texture2D
## Sprite nella schermata di combattimento. Se vuota usa il colore.
@export var combat_texture: Texture2D
