class_name AutoForwardBehavior
extends PawnBehavior


func resolve_turn(session: GameSession, turn: TurnResult) -> void:
	session.apply_forced_direction()
	session.try_step_pawn(session.pawn.direction, turn)
