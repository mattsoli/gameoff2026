class_name BoardOverlay
extends Node2D
## Disegna sopra la board le preview: caselle raggiungibili (bordo tratteggiato)
## e zona di influenza della freccia sotto il mouse (riempimento).

const DASH_LENGTH: float = 10.0
const LINE_WIDTH: float = 3.0

var _reachable_rects: Array[Rect2] = []
var _shift_preview_rects: Array[Rect2] = []
var _settings: BoardVisualSettings


func setup(settings: BoardVisualSettings) -> void:
	_settings = settings


func set_reachable_rects(rects: Array[Rect2]) -> void:
	_reachable_rects = rects
	queue_redraw()


func set_shift_preview_rects(rects: Array[Rect2]) -> void:
	_shift_preview_rects = rects
	queue_redraw()


func _draw() -> void:
	if _settings == null:
		return
	# Il bordo usa lo stesso colore del riempimento ma opaco.
	var outline_color: Color = Color(_settings.shift_preview_color, 1.0)
	for rect: Rect2 in _shift_preview_rects:
		draw_rect(rect, _settings.shift_preview_color)
		_draw_dashed_rect(rect, outline_color)
	for rect: Rect2 in _reachable_rects:
		_draw_dashed_rect(rect.grow(-3.0), _settings.reachable_preview_color)


func _draw_dashed_rect(rect: Rect2, color: Color) -> void:
	var corners: Array[Vector2] = [rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)]
	for i: int in corners.size():
		draw_dashed_line(corners[i], corners[(i + 1) % corners.size()], color, LINE_WIDTH, DASH_LENGTH, true, true)
