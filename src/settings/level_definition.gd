@tool
class_name LevelDefinition
extends Resource
## Un livello descritto con tre layer testuali della stessa dimensione.
## Ogni riga del testo è una riga della board; gli spazi vengono ignorati,
## quindi "# . . #" e "#..#" sono equivalenti.

@export var display_name: String = "Level"
@export var legend: LevelLegend:
	set(value):
		legend = value
		emit_changed()

# I setter emettono "changed" così il Level Editor si aggiorna anche dopo un Undo.
# Questi tre campi vengono scritti dal Level Editor (addons/level_editor):
# non serve modificarli a mano.

## Tipi di casella (simboli di legend.tiles). Obbligatorio.
@export_multiline var tiles_layout: String = "":
	set(value):
		tiles_layout = value
		emit_changed()
## Elementi e posizione iniziale della pedina (simboli di legend.entities + player_start_symbol).
@export_multiline var entities_layout: String = "":
	set(value):
		entities_layout = value
		emit_changed()
## Frecce di shifting (simboli freccia della legenda). Opzionale.
@export_multiline var arrows_layout: String = "":
	set(value):
		arrows_layout = value
		emit_changed()
