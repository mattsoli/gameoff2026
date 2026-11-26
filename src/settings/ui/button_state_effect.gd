@tool
class_name ButtonStateEffect
extends Resource
## Come appare un pulsante in uno stato (mouse sopra o premuto), rispetto al suo aspetto normale.
## Gli effetti si combinano: scala + spostamento + rotazione + tinta.

## (1, 1) = dimensione normale; (1.1, 1.1) = più grande del 10%.
@export var scale: Vector2 = Vector2.ONE
## Spostamento in pixel, es. (0, -6) = il pulsante si "solleva".
@export var offset: Vector2 = Vector2.ZERO
## Rotazione in gradi attorno al centro del pulsante.
@export_range(-180.0, 180.0, 0.5, "suffix:°") var rotation_degrees: float = 0.0
## Tinta applicata al pulsante (bianco = colori originali; valori sopra 1 schiariscono).
@export var tint: Color = Color.WHITE


static func create(p_scale: Vector2, p_offset: Vector2 = Vector2.ZERO, p_rotation_degrees: float = 0.0, p_tint: Color = Color.WHITE) -> ButtonStateEffect:
	var effect: ButtonStateEffect = ButtonStateEffect.new()
	effect.scale = p_scale
	effect.offset = p_offset
	effect.rotation_degrees = p_rotation_degrees
	effect.tint = p_tint
	return effect
