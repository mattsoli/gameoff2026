class_name MoveResult
extends RefCounted
## Esito di un tentativo di movimento della pedina.

enum Type {
	BLOCKED, ## Destinazione non calpestabile: la pedina resta ferma (feedback "bump").
	MOVED, ## La pedina è entrata nella casella: vanno risolti i suoi effetti (LevelSession.arrive).
	COMBAT, ## Nella casella c'è un nemico: si apre il combattimento.
}

var type: Type = Type.BLOCKED
var direction: Direction.Type = Direction.Type.NONE
var from: Vector2i
var to: Vector2i
## Valorizzato solo se type == COMBAT.
var enemy: EnemyEntity
