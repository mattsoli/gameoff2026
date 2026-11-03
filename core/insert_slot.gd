class_name InsertSlot
extends RefCounted

var push_direction: Direction.Type
var line_index: int


func _init(p_push_direction: Direction.Type, p_line_index: int) -> void:
	push_direction = p_push_direction
	line_index = p_line_index
