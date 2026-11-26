@tool
class_name ScreenBackground
extends Resource
## Sfondo di una schermata: un colore pieno e, sopra, un'immagine opzionale.

@export var color: Color = Color(0.06, 0.07, 0.09)
@export var texture: Texture2D
## Come l'immagine riempie lo schermo: KEEP_ASPECT_COVERED copre tutto senza deformare
## (tagliando i bordi), SCALE deforma, TILE ripete, KEEP_ASPECT_CENTERED lascia bande.
@export var stretch_mode: TextureRect.StretchMode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
## Tinta e trasparenza dell'immagine (bianco = colori originali).
@export var texture_modulate: Color = Color.WHITE


static func create(p_color: Color, p_texture: Texture2D = null) -> ScreenBackground:
	var background: ScreenBackground = ScreenBackground.new()
	background.color = p_color
	background.texture = p_texture
	return background


func apply(color_rect: ColorRect, texture_rect: TextureRect) -> void:
	color_rect.color = color
	texture_rect.texture = texture
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = stretch_mode
	texture_rect.modulate = texture_modulate
