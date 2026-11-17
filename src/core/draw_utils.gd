@tool
class_name DrawUtils
extends RefCounted
## Funzioni di disegno condivise tra il gioco (TileView) e il Level Editor,
## così una freccia o un tratteggio hanno lo stesso aspetto ovunque.
## Vanno chiamate dentro il _draw() del CanvasItem passato.

## Freccia che punta a destra, con lunghezza 1 e centrata nell'origine.
const ARROW_SHAPE: PackedVector2Array = [
	Vector2(-0.32, -0.08), Vector2(0.04, -0.08), Vector2(0.04, -0.2), Vector2(0.32, 0.0),
	Vector2(0.04, 0.2), Vector2(0.04, 0.08), Vector2(-0.32, 0.08),
]


## Freccia ruotata nella direzione indicata. `length` è il lato del quadrato che la contiene.
static func draw_arrow(canvas: CanvasItem, center: Vector2, direction: Direction.Type, length: float, color: Color) -> void:
	canvas.draw_set_transform(center, Direction.to_angle(direction), Vector2.ONE * length)
	canvas.draw_colored_polygon(ARROW_SHAPE, color)
	canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Righe diagonali ritagliate dentro il rettangolo.
static func draw_hatch(canvas: CanvasItem, rect: Rect2, spacing: float, color: Color, width: float = 2.0) -> void:
	if spacing <= 0.0:
		return
	var start: float = rect.position.x + rect.position.y
	var end: float = rect.end.x + rect.end.y
	var offset: float = start + spacing
	while offset < end:
		var x_from: float = maxf(rect.position.x, offset - rect.end.y)
		var x_to: float = minf(rect.end.x, offset - rect.position.y)
		canvas.draw_line(Vector2(x_from, offset - x_from), Vector2(x_to, offset - x_to), color, width, true)
		offset += spacing


## Cerchi concentrici del simbolo "obiettivo".
static func draw_goal_rings(canvas: CanvasItem, center: Vector2, radius: float, color: Color, width: float) -> void:
	canvas.draw_arc(center, radius, 0.0, TAU, 48, color, width, true)
	canvas.draw_arc(center, radius * 0.6, 0.0, TAU, 48, color, width, true)
	canvas.draw_circle(center, radius * 0.22, color)


## Testo centrato orizzontalmente e verticalmente su `center`, dentro una larghezza `width`.
static func draw_centered_text(canvas: CanvasItem, text: String, center: Vector2, width: float, font_size: int, color: Color) -> void:
	if text.is_empty():
		return
	var font: Font = ThemeDB.fallback_font
	var baseline: float = center.y + (font.get_ascent(font_size) - font.get_descent(font_size)) * 0.5
	canvas.draw_string(font, Vector2(center.x - width * 0.5, baseline), text, HORIZONTAL_ALIGNMENT_CENTER, width, font_size, color)
