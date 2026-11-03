class_name PawnBehavior
extends Resource


## Da sovrascrivere. Deve usare solo l'API pubblica di GameSession (pawn, try_step_pawn, ...).
## Non salvare stato in questa Resource: è condivisa tra partite, lo stato va in PawnState.
func resolve_turn(_session: GameSession, _turn: TurnResult) -> void:
	push_error("PawnBehavior.resolve_turn non implementato nella sottoclasse")
