@tool
class_name BoardVisualSettings
extends Resource
## Aspetto e tempi di animazione della board.

@export_group("Dimensioni")
## Lato di una casella in pixel (viene ridotto se la board non entra in max_board_size).
@export_range(16.0, 256.0, 1.0) var tile_size: float = 120.0
@export_range(0.0, 64.0, 1.0) var tile_gap: float = 10.0
@export_range(0, 64) var tile_corner_radius: int = 10
## Area massima occupata dalla board sullo schermo (1920x1080).
@export var max_board_size: Vector2 = Vector2(1700.0, 900.0)
@export_range(8, 64) var label_font_size: int = 22

@export_group("Colori")
@export var background_color: Color = Color(0.06, 0.07, 0.09)
@export var background_texture: Texture2D
@export var board_color: Color = Color(0.1, 0.11, 0.14)
## Colore delle frecce di shifting (devono essere sempre ben visibili).
@export var arrow_color: Color = Color(1.0, 0.55, 0.2)
## Bordo tratteggiato delle caselle raggiungibili dalla pedina.
@export var reachable_preview_color: Color = Color(1.0, 0.55, 0.2)
## Riempimento della riga/colonna influenzata dalla freccia sotto il mouse.
@export var shift_preview_color: Color = Color(1.0, 0.55, 0.2, 0.18)
@export var label_color: Color = Color(0.05, 0.05, 0.07)

@export_group("Animazioni")
@export_range(0.0, 2.0, 0.01) var move_duration: float = 0.14
@export_range(0.0, 2.0, 0.01) var shift_duration: float = 0.3
@export_range(0.0, 2.0, 0.01) var bump_duration: float = 0.16
## Di quanto la pedina "rimbalza" verso una casella non calpestabile (frazione della casella).
@export_range(0.0, 1.0, 0.01) var bump_distance: float = 0.18
