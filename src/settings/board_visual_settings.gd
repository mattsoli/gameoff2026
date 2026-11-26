@tool
class_name BoardVisualSettings
extends Resource
## Aspetto e animazioni della board. Lo sfondo della schermata di gioco è in UiSettings.

@export_group("Dimensioni")
## Lato di una casella in pixel (viene ridotto se la board non entra in max_board_size).
@export_range(16.0, 256.0, 1.0) var tile_size: float = 120.0
@export_range(0.0, 64.0, 1.0) var tile_gap: float = 10.0
@export_range(0, 64) var tile_corner_radius: int = 10
## Area massima occupata dalla board sullo schermo (1920x1080).
@export var max_board_size: Vector2 = Vector2(1700.0, 900.0)
@export_range(8, 64) var label_font_size: int = 22
## Lato della casella (in pixel) per cui sono disegnate le scene animate (board_scene):
## in gioco vengono scalate alla dimensione reale della casella.
@export_range(16.0, 1024.0, 1.0) var scene_reference_size: float = 128.0

@export_group("Colori")
@export var board_color: Color = Color(0.1, 0.11, 0.14)
@export var arrow: ArrowSettings
## Bordo tratteggiato delle caselle raggiungibili dalla pedina.
@export var reachable_preview_color: Color = Color(1.0, 0.55, 0.2)
## Riempimento della riga/colonna influenzata dalla freccia sotto il mouse.
@export var shift_preview_color: Color = Color(1.0, 0.55, 0.2, 0.18)
@export var label_color: Color = Color(0.05, 0.05, 0.07)

@export_group("Animazioni")
## Spostamento della pedina da una casella all'altra.
@export var move_animation: UiAnimation = UiAnimation.create(0.14)
## Scorrimento della riga/colonna attivato da una freccia.
@export var shift_animation: UiAnimation = UiAnimation.create(0.3, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
## "Urto" contro una casella non calpestabile: vale per l'andata e, uguale, per il ritorno.
@export var bump_animation: UiAnimation = UiAnimation.create(0.08)
## Di quanto la pedina "rimbalza" verso una casella non calpestabile (frazione della casella).
@export_range(0.0, 1.0, 0.01) var bump_distance: float = 0.18
