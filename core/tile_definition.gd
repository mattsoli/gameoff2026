class_name TileDefinition
extends Resource

enum Kind { NORMAL, DIRECTIONAL, GOAL }

@export var id: StringName
@export var kind: Kind = Kind.NORMAL
@export var is_accessible: bool = true
## Se diverso da NONE, forza la direzione del protagonista che si trova su questa casella.
@export var direction: Direction.Type = Direction.Type.NONE
@export var texture: Texture2D
## Usato solo come placeholder quando manca la texture.
@export var debug_color: Color = Color.GRAY
