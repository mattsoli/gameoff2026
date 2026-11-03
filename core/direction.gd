class_name Direction
extends RefCounted

enum Type { NONE, UP, RIGHT, DOWN, LEFT }


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


static func opposite(direction: Type) -> Type:
	match direction:
		Type.UP:
			return Type.DOWN
		Type.RIGHT:
			return Type.LEFT
		Type.DOWN:
			return Type.UP
		Type.LEFT:
			return Type.RIGHT
		_:
			return Type.NONE


static func rotated_clockwise(direction: Type) -> Type:
	match direction:
		Type.UP:
			return Type.RIGHT
		Type.RIGHT:
			return Type.DOWN
		Type.DOWN:
			return Type.LEFT
		Type.LEFT:
			return Type.UP
		_:
			return Type.NONE


static func is_horizontal(direction: Type) -> bool:
	return direction == Type.LEFT or direction == Type.RIGHT
