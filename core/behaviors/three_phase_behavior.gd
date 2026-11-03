class_name ThreePhaseBehavior
extends PawnBehavior

enum Phase { DECIDE, ACT, PAUSE }


func resolve_turn(session: GameSession, turn: TurnResult) -> void:
	var pawn: PawnState = session.pawn
	var phase: Phase = (pawn.turns_elapsed % Phase.size()) as Phase
	pawn.turns_elapsed += 1

	match phase:
		Phase.DECIDE:
			_decide(session)
		Phase.ACT:
			_act(session, turn)
		Phase.PAUSE:
			pass


## Punto unico da cambiare se i designer definiscono una logica di decisione diversa.
## Ora: segue la direzione corrente (o quella imposta dalla casella); se è bloccata,
## ruota in senso orario verso la prima direzione libera.
func _decide(session: GameSession) -> void:
	var pawn: PawnState = session.pawn
	session.apply_forced_direction()

	if session.can_pawn_enter(pawn.direction):
		pawn.intent = PawnState.Intent.MOVE
		pawn.intent_direction = pawn.direction
		return

	var candidate: Direction.Type = pawn.direction
	for i: int in 3:
		candidate = Direction.rotated_clockwise(candidate)
		if session.can_pawn_enter(candidate):
			pawn.intent = PawnState.Intent.ROTATE
			pawn.intent_direction = candidate
			return

	pawn.intent = PawnState.Intent.NONE
	pawn.intent_direction = Direction.Type.NONE


## Esegue l'intento preso al turno precedente. La board può essere cambiata nel frattempo:
## se la destinazione non è più valida, il movimento semplicemente fallisce.
func _act(session: GameSession, turn: TurnResult) -> void:
	var pawn: PawnState = session.pawn
	match pawn.intent:
		PawnState.Intent.MOVE:
			if session.try_step_pawn(pawn.intent_direction, turn):
				pawn.direction = pawn.intent_direction
		PawnState.Intent.ROTATE:
			pawn.direction = pawn.intent_direction
		_:
			pass
	pawn.intent = PawnState.Intent.NONE
	pawn.intent_direction = Direction.Type.NONE
