@tool
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
## Varianti: se la lista non è vuota ogni casella di questo tipo sceglie a caso una di queste
## immagini (al posto di `texture`), per dare più varietà alla board. La scelta resta fissa
## per tutta la partita, anche quando la casella scorre con lo shift.
@export var texture_variants: Array[Texture2D] = []
@export var texture_unlocked: Texture2D
@export var texture_locked: Texture2D
## Scena animata a mano (sprite + AnimationPlayer). Se assegnata sostituisce texture e disegno di prova.
## Va disegnata centrata in (0, 0) per una casella grande quanto BoardVisualSettings.scene_reference_size.
## Animazioni usate: "idle"; per gli obiettivi anche "unlock" (alla raccolta della chiave) e "unlocked".
@export var board_scene: PackedScene


## Immagine da usare per una casella: una variante scelta da `variant_seed` se ce ne sono,
## altrimenti `texture` (che può essere null: in quel caso si disegna il placeholder).
func get_texture(variant_seed: int) -> Texture2D:
	var variants: Array[Texture2D] = []
	for variant: Texture2D in texture_variants:
		if variant != null:
			variants.append(variant)
	if variants.is_empty():
		return texture
	return variants[posmod(variant_seed, variants.size())]
