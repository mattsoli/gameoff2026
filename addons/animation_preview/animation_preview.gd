@tool
class_name AnimationPreview
extends Control
## Anteprima in loop di una UiAnimation / UiTransition, mostrata nell'Inspector.
## A sinistra il grafico della curva (con la linea del tempo che scorre), a destra un esempio:
## - UiAnimation: un quadrato che si sposta da sinistra a destra con quella curva;
## - UiTransition: un quadrato che compare con dissolvenza, scorrimento e scala impostati.
## Legge i valori della risorsa a ogni frame, quindi si aggiorna mentre li modifichi.

const PREVIEW_HEIGHT: float = 150.0
const PADDING: float = 8.0
## Pausa a fine animazione prima di ricominciare il loop.
const HOLD_TIME: float = 0.6
const CURVE_SAMPLES: int = 64
## Margine del grafico sopra 1 e sotto 0, per vedere le curve che "sforano" (BACK, ELASTIC).
const OVERSHOOT_MARGIN: float = 0.3
const BOX_SIZE: float = 40.0

const BACKGROUND_COLOR: Color = Color(0.1, 0.11, 0.13)
const GRID_COLOR: Color = Color(1.0, 1.0, 1.0, 0.12)
const CURVE_COLOR: Color = Color(1.0, 0.6, 0.25)
const DELAY_COLOR: Color = Color(1.0, 1.0, 1.0, 0.35)
const CURSOR_COLOR: Color = Color(0.45, 0.75, 1.0)
const BOX_COLOR: Color = Color(0.45, 0.75, 1.0)
const TEXT_COLOR: Color = Color(0.85, 0.85, 0.9)

var animation: UiAnimation

var _time: float = 0.0


func _init() -> void:
	custom_minimum_size = Vector2(0.0, PREVIEW_HEIGHT)
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	if animation == null or not is_visible_in_tree():
		return
	_time += delta
	if _time > _get_total_time() + HOLD_TIME:
		_time = 0.0
	queue_redraw()


func _draw() -> void:
	if animation == null:
		return
	draw_rect(Rect2(Vector2.ZERO, size), BACKGROUND_COLOR)
	var half_width: float = size.x * 0.5
	var graph_rect: Rect2 = Rect2(PADDING, PADDING + 16.0, half_width - PADDING * 2.0, size.y - PADDING * 2.0 - 16.0)
	var demo_rect: Rect2 = Rect2(half_width + PADDING, PADDING + 16.0, half_width - PADDING * 2.0, size.y - PADDING * 2.0 - 16.0)

	var font: Font = get_theme_default_font()
	var font_size: int = 12
	draw_string(font, Vector2(PADDING, PADDING + 10.0), "Curve · total %.2f s" % _get_total_time(), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, TEXT_COLOR)
	var demo_title: String = "Appear (in)" if animation is UiTransition else "Movement"
	draw_string(font, Vector2(half_width + PADDING, PADDING + 10.0), demo_title, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, TEXT_COLOR)

	_draw_graph(graph_rect)
	if animation is UiTransition:
		_draw_transition_demo(demo_rect, animation as UiTransition)
	else:
		_draw_movement_demo(demo_rect)


## Avanzamento 0..1 (può uscire dall'intervallo con le curve BACK/ELASTIC) al tempo `time`.
func _progress_at(time: float) -> float:
	var local_time: float = time - animation.delay
	if local_time <= 0.0:
		return 0.0
	if animation.duration <= 0.0 or local_time >= animation.duration:
		return 1.0
	var value: float = Tween.interpolate_value(0.0, 1.0, local_time, animation.duration, animation.transition, animation.easing)
	return value


func _get_total_time() -> float:
	return animation.delay + animation.duration


func _draw_graph(rect: Rect2) -> void:
	draw_rect(rect, GRID_COLOR, false, 1.0)
	draw_line(Vector2(rect.position.x, _graph_y(rect, 0.0)), Vector2(rect.end.x, _graph_y(rect, 0.0)), GRID_COLOR)
	draw_line(Vector2(rect.position.x, _graph_y(rect, 1.0)), Vector2(rect.end.x, _graph_y(rect, 1.0)), GRID_COLOR)

	var total: float = maxf(_get_total_time(), 0.001)
	var points: PackedVector2Array = PackedVector2Array()
	for i: int in CURVE_SAMPLES + 1:
		var time: float = total * float(i) / CURVE_SAMPLES
		points.append(Vector2(rect.position.x + rect.size.x * time / total, _graph_y(rect, _progress_at(time))))
	draw_polyline(points, CURVE_COLOR, 2.0, true)

	# Il tratto di ritardo è evidenziato: lì l'animazione non è ancora partita.
	if animation.delay > 0.0:
		var delay_x: float = rect.position.x + rect.size.x * animation.delay / total
		draw_dashed_line(Vector2(delay_x, rect.position.y), Vector2(delay_x, rect.end.y), DELAY_COLOR, 1.0, 4.0)

	var cursor_time: float = minf(_time, total)
	var cursor_x: float = rect.position.x + rect.size.x * cursor_time / total
	draw_line(Vector2(cursor_x, rect.position.y), Vector2(cursor_x, rect.end.y), CURSOR_COLOR, 1.0)
	draw_circle(Vector2(cursor_x, _graph_y(rect, _progress_at(cursor_time))), 4.0, CURSOR_COLOR, true, -1.0, true)


func _graph_y(rect: Rect2, value: float) -> float:
	var normalized: float = (value + OVERSHOOT_MARGIN) / (1.0 + OVERSHOOT_MARGIN * 2.0)
	return rect.end.y - rect.size.y * normalized


func _draw_movement_demo(rect: Rect2) -> void:
	var track_y: float = rect.get_center().y
	var start_x: float = rect.position.x + BOX_SIZE * 0.5
	var end_x: float = rect.end.x - BOX_SIZE * 0.5
	draw_line(Vector2(start_x, track_y), Vector2(end_x, track_y), GRID_COLOR, 2.0)
	var x: float = lerpf(start_x, end_x, _progress_at(_time))
	draw_rect(Rect2(Vector2(x, track_y) - Vector2.ONE * BOX_SIZE * 0.5, Vector2.ONE * BOX_SIZE), BOX_COLOR)


func _draw_transition_demo(rect: Rect2, transition: UiTransition) -> void:
	var progress: float = _progress_at(_time)
	var center: Vector2 = rect.get_center()
	# Contorno: la posizione finale del quadrato.
	draw_rect(Rect2(center - Vector2.ONE * BOX_SIZE * 0.5, Vector2.ONE * BOX_SIZE), GRID_COLOR, false, 1.0)

	var offset: Vector2 = transition.slide_offset * (1.0 - progress)
	var box_scale: Vector2 = transition.start_scale.lerp(Vector2.ONE, progress)
	var alpha: float = clampf(progress, 0.0, 1.0) if transition.fade else 1.0
	var box_size: Vector2 = Vector2.ONE * BOX_SIZE * box_scale
	var color: Color = BOX_COLOR
	color.a = alpha
	draw_rect(Rect2(center + offset - box_size * 0.5, box_size), color)
