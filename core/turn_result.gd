class_name TurnResult
extends RefCounted

var insert: InsertResult

var pawn_cell_before: Vector2i
var pawn_shifted: bool = false
## True se la pedina era sull'ultima cella della linea e la spinta la porta fuori dalla board.
var pawn_pushed_out: bool = false
## True solo se, essendo uscita, rientra dal lato opposto (policy WRAP).
var pawn_wrapped: bool = false
var pawn_cell_after_shift: Vector2i

var direction: Direction.Type = Direction.Type.NONE
var intent: PawnState.Intent = PawnState.Intent.NONE
var intent_direction: Direction.Type = Direction.Type.NONE

var pawn_moved: bool = false
var move_from: Vector2i
## Può essere fuori dalla board se la pedina è uscita sull'obiettivo.
var move_to: Vector2i

var outcome: GameSession.Outcome = GameSession.Outcome.PLAYING
