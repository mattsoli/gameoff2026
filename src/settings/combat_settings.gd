class_name CombatSettings
extends Resource
## Regole numeriche, aspetto e tempi della schermata di combattimento.

@export_group("Regole")
## Probabilità che una moneta esca SPADA (il resto è SCUDO).
@export_range(0.0, 1.0, 0.01) var sword_chance: float = 0.5

@export_group("Monete")
@export_range(16.0, 256.0, 1.0) var coin_size: float = 72.0
@export_range(0.0, 64.0, 1.0) var coin_spacing: float = 12.0
@export var sword_color: Color = Color(0.9, 0.35, 0.3)
@export var shield_color: Color = Color(0.35, 0.6, 0.95)
@export var hidden_color: Color = Color(0.75, 0.65, 0.3)
## Bordo delle monete aggiunte dagli effetti (bonus).
@export var bonus_outline_color: Color = Color(1.0, 1.0, 1.0)
@export var sword_label: String = "ATK"
@export var shield_label: String = "DEF"
@export var hidden_label: String = "?"
## Texture opzionali: se assegnate sostituiscono il disegno placeholder.
@export var sword_texture: Texture2D
@export var shield_texture: Texture2D
@export var hidden_texture: Texture2D

@export_group("Animazioni")
@export_range(0.0, 3.0, 0.01) var intro_duration: float = 0.4
@export_range(0.0, 3.0, 0.01) var coin_flip_duration: float = 0.25
## Ritardo tra il lancio di una moneta e la successiva.
@export_range(0.0, 1.0, 0.01) var coin_flip_stagger: float = 0.08
@export_range(0.0, 3.0, 0.01) var coin_arrange_duration: float = 0.35
@export_range(0.0, 3.0, 0.01) var attack_duration: float = 0.3
@export_range(0.0, 3.0, 0.01) var pause_between_steps: float = 0.35
@export_range(0.0, 3.0, 0.01) var outro_duration: float = 0.3
