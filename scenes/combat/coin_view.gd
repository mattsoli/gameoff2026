class_name CoinView
extends Control
## Una moneta nella schermata di combattimento: coperta prima del lancio, poi SPADA o SCUDO.

var face: CoinFace.Type = CoinFace.Type.SWORD
var is_revealed: bool = false
var is_bonus: bool = false

var _settings: CombatSettings


func setup(settings: CombatSettings, p_is_bonus: bool) -> void:
	_settings = settings
	is_bonus = p_is_bonus
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2.ONE * settings.coin_size
	pivot_offset = size * 0.5
	queue_redraw()


## Mostra subito una faccia (usato per le monete bonus).
func reveal_instantly(p_face: CoinFace.Type) -> void:
	face = p_face
	is_revealed = true
	queue_redraw()


## Animazione di lancio: la moneta si "gira" (scala X a 0) e mostra la faccia.
func play_flip(p_face: CoinFace.Type, duration: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale:x", 0.0, duration * 0.5)
	tween.tween_callback(reveal_instantly.bind(p_face))
	tween.tween_property(self, "scale:x", 1.0, duration * 0.5)
	await tween.finished


func play_pop_in(duration: float) -> void:
	scale = Vector2.ZERO
	var tween: Tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, duration)
	await tween.finished


func _draw() -> void:
	if _settings == null:
		return
	var center: Vector2 = size * 0.5
	var radius: float = size.x * 0.5
	var texture: Texture2D = _get_texture()
	if texture != null:
		draw_texture_rect(texture, Rect2(Vector2.ZERO, size), false)
	else:
		draw_circle(center, radius, _get_color(), true, -1.0, true)
		draw_circle(center, radius * 0.82, _get_color().darkened(0.2), false, 3.0, true)
		var font: Font = ThemeDB.fallback_font
		var font_size: int = int(radius * 0.6)
		var baseline: float = center.y + (font.get_ascent(font_size) - font.get_descent(font_size)) * 0.5
		draw_string(font, Vector2(0.0, baseline), _get_label(), HORIZONTAL_ALIGNMENT_CENTER, size.x, font_size, Color.WHITE)
	if is_bonus:
		draw_circle(center, radius - 2.0, _settings.bonus_outline_color, false, 4.0, true)


func _get_color() -> Color:
	if not is_revealed:
		return _settings.hidden_color
	return _settings.sword_color if face == CoinFace.Type.SWORD else _settings.shield_color


func _get_label() -> String:
	if not is_revealed:
		return _settings.hidden_label
	return _settings.sword_label if face == CoinFace.Type.SWORD else _settings.shield_label


func _get_texture() -> Texture2D:
	if not is_revealed:
		return _settings.hidden_texture
	return _settings.sword_texture if face == CoinFace.Type.SWORD else _settings.shield_texture
