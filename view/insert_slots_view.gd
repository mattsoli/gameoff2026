class_name InsertSlotsView
extends Node2D

signal slot_pressed(slot: InsertSlot)

const BUTTON_SIZE: float = 32.0
const MARGIN: float = 8.0

var _buttons: Array[Button] = []


func setup(slots: Array[InsertSlot], board_size: Vector2i, tile_size: float) -> void:
	for slot: InsertSlot in slots:
		var button: Button = Button.new()
		button.size = Vector2.ONE * BUTTON_SIZE
		button.text = _label_for(slot.push_direction)
		button.focus_mode = Control.FOCUS_NONE
		button.position = _position_for(slot, board_size, tile_size)
		button.pressed.connect(_on_button_pressed.bind(slot))
		add_child(button)
		_buttons.append(button)


func set_enabled(enabled: bool) -> void:
	for button: Button in _buttons:
		button.disabled = not enabled


func _on_button_pressed(slot: InsertSlot) -> void:
	slot_pressed.emit(slot)


func _label_for(direction: Direction.Type) -> String:
	match direction:
		Direction.Type.RIGHT:
			return ">"
		Direction.Type.LEFT:
			return "<"
		Direction.Type.DOWN:
			return "v"
		Direction.Type.UP:
			return "^"
		_:
			return "?"


func _position_for(slot: InsertSlot, board_size: Vector2i, tile_size: float) -> Vector2:
	var center: float = (slot.line_index + 0.5) * tile_size
	var half: float = BUTTON_SIZE * 0.5
	match slot.push_direction:
		Direction.Type.RIGHT:
			return Vector2(-BUTTON_SIZE - MARGIN, center - half)
		Direction.Type.LEFT:
			return Vector2(board_size.x * tile_size + MARGIN, center - half)
		Direction.Type.DOWN:
			return Vector2(center - half, -BUTTON_SIZE - MARGIN)
		Direction.Type.UP:
			return Vector2(center - half, board_size.y * tile_size + MARGIN)
		_:
			return Vector2.ZERO
