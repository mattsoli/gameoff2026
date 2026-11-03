class_name GameConfig
extends Resource

## Cosa succede alla casella espulsa dalla linea.
enum PushedOutTilePolicy { RETURN_TO_HAND, DISCARD }
## Cosa succede se la pedina viene spinta fuori dalla board senza centrare l'obiettivo.
enum PawnPushedOutPolicy { WRAP, LOSE }

@export_group("Board")
@export var board_size: Vector2i = Vector2i(5, 5)
@export var tile_pool: Array[TileDefinition] = []

@export_group("Mano")
@export var hand_size: int = 3
@export var pushed_out_tile_policy: PushedOutTilePolicy = PushedOutTilePolicy.RETURN_TO_HAND
## Usato solo con DISCARD: se false la mano si svuota; a mano vuota il giocatore perde.
@export var refill_hand_from_pool: bool = true

@export_group("Pedina")
@export var start_cell: Vector2i = Vector2i(2, 2)
@export var start_direction: Direction.Type = Direction.Type.RIGHT
@export var pawn_behavior: PawnBehavior
@export var pawn_pushed_out_policy: PawnPushedOutPolicy = PawnPushedOutPolicy.WRAP

@export_group("Obiettivo")
@export var goal: GoalDefinition

@export_group("Generale")
## 0 = seed casuale a ogni avvio.
@export var rng_seed: int = 0
@export var tile_size: float = 72.0
@export var shift_duration: float = 0.25
@export var move_duration: float = 0.2
