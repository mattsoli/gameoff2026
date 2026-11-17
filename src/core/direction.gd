@tool
class_name Direction
extends RefCounted
## Utility per le 4 direzioni cardinali, usate sia dal movimento che dallo shifting.

enum Type { NONE, UP, RIGHT, DOWN, LEFT }


static func all() -> Array[Type]:
	return [Type.UP, Type.RIGHT, Type.DOWN, Type.LEFT]


static func to_vector(direction: Type) -> Vector2i:
	match direction:
		Type.UP:
			return Vector2i.UP
		Type.RIGHT:
			return Vector2i.RIGHT
		Type.DOWN:
			return Vector2i.DOWN
		Type.LEFT:
			return Vector2i.LEFT
		_:
			return Vector2i.ZERO


## Converte un vettore unitario (es. differenza tra due celle adiacenti) in direzione.
## Restituisce NONE se le celle non sono adiacenti.
static func from_vector(vector: Vector2i) -> Type:
	match vector:
		Vector2i.UP:
			return Type.UP
		Vector2i.RIGHT:
			return Type.RIGHT
		Vector2i.DOWN:
			return Type.DOWN
		Vector2i.LEFT:
			return Type.LEFT
		_:
			return Type.NONE


static func is_horizontal(direction: Type) -> bool:
	return direction == Type.LEFT or direction == Type.RIGHT


## Angolo in radianti (0 = destra), utile per ruotare le frecce disegnate.
static func to_angle(direction: Type) -> float:
	return Vector2(to_vector(direction)).angle()
