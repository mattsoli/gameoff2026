class_name LevelDefinition
extends Resource
## Un livello descritto con tre layer testuali della stessa dimensione.
## Ogni riga del testo è una riga della board; gli spazi vengono ignorati,
## quindi "# . . #" e "#..#" sono equivalenti.

@export var display_name: String = "Level"
@export var legend: LevelLegend

## Tipi di casella (simboli di legend.tiles). Obbligatorio.
@export_multiline var tiles_layout: String = ""
## Elementi e posizione iniziale della pedina (simboli di legend.entities + player_start_symbol).
@export_multiline var entities_layout: String = ""
## Frecce di shifting (simboli freccia della legenda). Opzionale.
@export_multiline var arrows_layout: String = ""
