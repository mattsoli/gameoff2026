class_name HandView
extends Node2D

const GAP: float = 12.0


func refresh(hand: Array[TileInstance], selected_index: int, tile_size: float) -> void:
	for child: Node in get_children():
		child.queue_free()
	for i: int in hand.size():
		var view: TileView = TileView.new()
		add_child(view)
		view.setup(hand[i], tile_size)
		view.position = Vector2((i + 0.5) * (tile_size + GAP), tile_size * 0.5)
		view.set_selected(i == selected_index)
