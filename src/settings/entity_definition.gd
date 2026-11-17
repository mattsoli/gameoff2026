class_name EntityDefinition
extends Resource
## Base per gli elementi che stanno sopra una casella (chiave, nemico, baule...).
## Le sottoclassi creano l'istanza runtime corrispondente con create_entity().

@export var id: StringName
@export var display_name: String = ""

@export_group("Visual")
@export var color: Color = Color.WHITE
## Testo breve disegnato sull'icona placeholder (es. "K", "E").
@export var label: String = ""
## Se assegnata sostituisce l'icona placeholder sulla board.
@export var texture: Texture2D


## Crea lo stato runtime di questo elemento. Va sovrascritto dalle sottoclassi.
func create_entity() -> BoardEntity:
	return BoardEntity.new(self)
