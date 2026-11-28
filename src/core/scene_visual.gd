class_name SceneVisual
extends RefCounted
## Una scena disegnata e animata a mano dai Designer (sprite + AnimationPlayer),
## mostrata al posto del disegno di prova di pedina, nemici, oggetti e caselle.
##
## Il gioco avvia le animazioni per NOME quando succede un evento (vedi le costanti).
## Se la scena non ha un'animazione con quel nome non succede nulla: i Designer
## possono crearne solo alcune. Dopo un'animazione "una tantum" (move, bump, attack)
## si torna da soli a "idle"; dopo "unlock" si passa a "unlocked".

const IDLE: StringName = &"idle"
const MOVE: StringName = &"move"
const BUMP: StringName = &"bump"
const ATTACK: StringName = &"attack"
const DEFEAT: StringName = &"defeat"
const PICKUP: StringName = &"pickup"
const UNLOCK: StringName = &"unlock"
const UNLOCKED: StringName = &"unlocked"
# Cut scene di fine livello.
const RUN: StringName = &"run"
const CATCH: StringName = &"catch"
const CAUGHT: StringName = &"caught"
# Pulsanti.
const HOVER: StringName = &"hover"
const UNHOVER: StringName = &"unhover"
const PRESSED: StringName = &"pressed"
const RELEASED: StringName = &"released"

## Animazioni al termine delle quali si torna automaticamente a IDLE.
const RETURN_TO_IDLE: Array[StringName] = [MOVE, BUMP, ATTACK, UNHOVER]

var root: Node
var _player: AnimationPlayer


## Istanzia `scene` come figlia di `parent`, scalata da `reference_size` (la dimensione per cui
## è stata disegnata) a `target_size`. Restituisce null se la scena non è assegnata.
static func create(scene: PackedScene, parent: Node, reference_size: float, target_size: float) -> SceneVisual:
	if scene == null:
		return null
	var visual: SceneVisual = SceneVisual.new()
	visual.root = scene.instantiate()
	var factor: float = target_size / maxf(reference_size, 1.0)
	if visual.root is Node2D:
		(visual.root as Node2D).scale = Vector2.ONE * factor
	elif visual.root is Control:
		(visual.root as Control).scale = Vector2.ONE * factor
	parent.add_child(visual.root)
	visual._player = _find_animation_player(visual.root)
	visual._chain_animations()
	visual.play(IDLE)
	return visual


func has_animation(animation_name: StringName) -> bool:
	return _player != null and _player.has_animation(animation_name)


## Avvia l'animazione se esiste. Restituisce true se è partita.
func play(animation_name: StringName) -> bool:
	if not has_animation(animation_name):
		return false
	if _player.is_inside_tree():
		_player.play(animation_name)
	else:
		# La scena non è ancora sullo schermo: parte appena entra.
		_player.ready.connect(_player.play.bind(animation_name), CONNECT_ONE_SHOT)
	return true


## Avvia l'animazione e restituisce quanto dura (0 se non esiste o se è in loop).
## Serve a chi deve aspettarla insieme a un'animazione da codice.
func play_one_shot(animation_name: StringName) -> float:
	if not play(animation_name):
		return 0.0
	var clip: Animation = _player.get_animation(animation_name)
	if clip.loop_mode != Animation.LOOP_NONE:
		return 0.0
	return clip.length / maxf(absf(_player.speed_scale), 0.01)


## Avvia l'animazione e attende che finisca.
func play_and_wait(animation_name: StringName) -> void:
	var length: float = play_one_shot(animation_name)
	if length > 0.0 and root.is_inside_tree():
		await root.get_tree().create_timer(length).timeout


func destroy() -> void:
	if is_instance_valid(root):
		root.queue_free()


func _chain_animations() -> void:
	if _player == null:
		return
	if _player.has_animation(IDLE):
		for animation_name: StringName in RETURN_TO_IDLE:
			if _player.has_animation(animation_name):
				_player.animation_set_next(animation_name, IDLE)
	if _player.has_animation(UNLOCK) and _player.has_animation(UNLOCKED):
		_player.animation_set_next(UNLOCK, UNLOCKED)


static func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	var found: Array[Node] = node.find_children("*", "AnimationPlayer", true, false)
	return found[0] as AnimationPlayer if not found.is_empty() else null


## Attende quanto manca perché un'animazione partita a `started_msec` e lunga `length` finisca.
static func wait_remaining(tree: SceneTree, started_msec: int, length: float) -> void:
	var remaining: float = length - float(Time.get_ticks_msec() - started_msec) / 1000.0
	if remaining > 0.0:
		await tree.create_timer(remaining).timeout
