class_name StageActor
extends Control
## Un personaggio "sul palco" (combattimento, cut scene di fine livello).
## Il riquadro (posizione e dimensione si decidono trascinandolo nella scena che lo contiene)
## mostra la scena animata del personaggio, scalata a misura; senza scena la texture
## e, in mancanza anche di quella, il colore.
## Il personaggio "poggia" sul bordo inferiore del riquadro: le scene vanno disegnate con
## i piedi in (0, 0), così ogni scala (animazioni e transizioni) parte dai piedi.

## Specchia orizzontalmente scena e texture (es. per far guardare il personaggio verso sinistra).
@export var mirror: bool = false
## Punto da cui scala il personaggio nelle transizioni (comparsa, uscita), in frazione del
## riquadro: (0.5, 1) = al centro del bordo inferiore, sotto i piedi.
@export var scale_pivot: Vector2 = Vector2(0.5, 1.0)

@onready var _body: ColorRect = %Body
@onready var _art: TextureRect = %Art

## Scena animata del personaggio (se assegnata), con i piedi sul bordo inferiore del riquadro.
var _visual: SceneVisual
var _scene_anchor: Node2D
var _body_rest_position: Vector2


func _ready() -> void:
	set_meta(UiAnimator.PIVOT_META, scale_pivot)


## Mostra il personaggio. `reference_size` è il lato del riquadro per cui è disegnata la scena.
func setup_actor(scene: PackedScene, texture: Texture2D, color: Color, reference_size: float) -> void:
	_body.modulate = Color.WHITE
	_body.scale = Vector2.ONE
	_body.pivot_offset = _body.size * scale_pivot
	_body_rest_position = _body.position
	if _visual != null:
		_visual.destroy()
		_visual = null
	if _scene_anchor == null:
		_scene_anchor = Node2D.new()
		_body.add_child(_scene_anchor)
	# Piedi della scena sul bordo inferiore del riquadro.
	_scene_anchor.position = Vector2(_body.size.x * 0.5, _body.size.y)
	_scene_anchor.scale = Vector2(-1.0 if mirror else 1.0, 1.0)
	_visual = SceneVisual.create(scene, _scene_anchor, reference_size, _body.size.x)
	var has_scene: bool = _visual != null
	_body.color = Color.TRANSPARENT if has_scene or texture != null else color
	_art.texture = null if has_scene else texture
	_art.flip_h = mirror


## Avvia un'animazione della scena (se esiste). Restituisce true se è partita.
func play_animation(animation_name: StringName) -> bool:
	return _visual != null and _visual.play(animation_name)


## Avvia un'animazione della scena e restituisce quanto dura (0 se non esiste o è in loop).
func play_one_shot(animation_name: StringName) -> float:
	return _visual.play_one_shot(animation_name) if _visual != null else 0.0
