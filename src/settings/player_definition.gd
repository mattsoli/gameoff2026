@tool
class_name PlayerDefinition
extends Resource
## Valori del giocatore all'inizio di ogni livello (si riparte sempre senza arma).

@export var display_name: String = "Player"

@export_group("Statistiche")
## Valore di attacco base, senza arma.
@export_range(0, 999) var attack: int = 1

@export_group("Visual")
@export var color: Color = Color(0.4, 0.6, 1.0)
## Icona della pedina sulla board. Se vuota viene disegnato un cerchio.
@export var board_texture: Texture2D
## Sprite nella schermata di combattimento. Se vuota usa il colore.
@export var combat_texture: Texture2D

@export_group("Scene animate")
## Scena animata a mano (sprite + AnimationPlayer). Se assegnata sostituisce texture e disegno di prova.
## Va disegnata centrata in (0, 0) per una casella grande quanto BoardVisualSettings.scene_reference_size.
## Animazioni usate: "idle", "move" (a ogni passo), "bump" (contro un muro).
@export var board_scene: PackedScene
## Scena animata nella schermata di combattimento (sostituisce combat_texture).
## Animazioni usate: "idle", "attack" (se vince), "defeat" (se perde).
@export var combat_scene: PackedScene
