class_name TileDefinition
extends Resource
## Un tipo di casella della board (calpestabile, muro, buco, obiettivo...).
## Per creare un nuovo tipo basta un nuovo file .tres e un simbolo nella LevelLegend.

enum Pattern { FLAT, HATCHED }

@export var id: StringName
@export var display_name: String = ""
## Se false la pedina non può entrarci (muro, buco...).
@export var is_walkable: bool = true
## Casella obiettivo: calpestabile solo dopo aver raccolto la chiave; raggiungerla completa il livello.
@export var is_goal: bool = false

@export_group("Visual")
@export var color: Color = Color(0.17, 0.19, 0.24)
## Colore secondario: tratteggio, simbolo dell'obiettivo, lucchetto.
@export var accent_color: Color = Color(0.45, 0.5, 0.6)
@export var pattern: Pattern = Pattern.FLAT
## Se assegnata sostituisce il disegno placeholder.
@export var texture: Texture2D
