class_name CombatantPanel
extends Control
## Un combattente in scena: il riquadro (posizione e dimensione si decidono trascinandolo
## in combat_screen.tscn) contiene la scena animata del combattente, scalata a misura.
## Senza scena mostra la texture o, in mancanza, il colore. Sotto, nome e valore di attacco.

@export var attack_format: String = "ATK %d"
@export var weapon_format: String = "Weapon: %s"
@export var no_weapon_text: String = "-"
## Se false nasconde nome, attacco e arma sotto al combattente.
@export var show_info: bool = true
## Se false nasconde lo slot arma (es. per i nemici).
@export var show_weapon: bool = true
## Specchia orizzontalmente scena e texture (es. per far guardare il nemico verso sinistra).
@export var mirror: bool = false

@onready var _body: ColorRect = %Body
@onready var _art: TextureRect = %Art
@onready var _info: Control = %Info
@onready var _name_label: Label = %NameLabel
@onready var _attack_label: Label = %AttackLabel
@onready var _weapon_label: Label = %WeaponLabel

var _body_rest_position: Vector2
## Scena animata del combattente (se assegnata), al centro del riquadro.
var _visual: SceneVisual
var _scene_anchor: Node2D


func setup(combatant: Combatant, settings: CombatSettings) -> void:
	_body.modulate = Color.WHITE
	_body.scale = Vector2.ONE
	_body.pivot_offset = _body.size * 0.5
	_body_rest_position = _body.position
	_setup_visual(combatant, settings)
	_info.visible = show_info
	_name_label.text = combatant.display_name
	_attack_label.text = attack_format % combatant.attack
	_weapon_label.visible = show_weapon
	var weapon: String = no_weapon_text if combatant.weapon_name.is_empty() else combatant.weapon_name
	_weapon_label.text = weapon_format % weapon


## Con una combat_scene il colore e la texture lasciano il posto alla scena.
func _setup_visual(combatant: Combatant, settings: CombatSettings) -> void:
	if _visual != null:
		_visual.destroy()
		_visual = null
	if _scene_anchor == null:
		_scene_anchor = Node2D.new()
		_body.add_child(_scene_anchor)
	_scene_anchor.position = _body.size * 0.5
	_scene_anchor.scale = Vector2(-1.0 if mirror else 1.0, 1.0)
	_visual = SceneVisual.create(combatant.scene, _scene_anchor, settings.scene_reference_size, _body.size.x)
	var has_scene: bool = _visual != null
	_body.color = Color.TRANSPARENT if has_scene or combatant.texture != null else combatant.color
	_art.texture = null if has_scene else combatant.texture
	_art.flip_h = mirror


## Scatto in avanti e ritorno. direction_sign: +1 verso destra, -1 verso sinistra.
## In parallelo parte l'animazione "attack" della scena; si attende la più lunga delle due.
func play_attack(direction_sign: float, settings: CombatSettings) -> void:
	var started: int = Time.get_ticks_msec()
	var scene_length: float = _visual.play_one_shot(SceneVisual.ATTACK) if _visual != null else 0.0
	if settings.attack_distance > 0.0:
		var lunge: Vector2 = _body_rest_position + Vector2(_body.size.x * settings.attack_distance * direction_sign, 0.0)
		var tween: Tween = create_tween()
		UiAnimation.tween_property(tween, _body, "position", lunge, settings.attack)
		UiAnimation.tween_property(tween, _body, "position", _body_rest_position, settings.attack_return)
		await tween.finished
	await SceneVisual.wait_remaining(get_tree(), started, scene_length)


## Lo sconfitto lampeggia mentre la scena esegue l'animazione "defeat";
## si attende la più lunga delle due. Al termine resta nella posa finale di "defeat".
func play_defeat(settings: CombatSettings) -> void:
	var started: int = Time.get_ticks_msec()
	var scene_length: float = _visual.play_one_shot(SceneVisual.DEFEAT) if _visual != null else 0.0
	if settings.defeat_blink_count > 0:
		var tween: Tween = create_tween()
		for i: int in settings.defeat_blink_count:
			UiAnimation.tween_property(tween, _body, "modulate", settings.defeat_blink_color, settings.defeat_blink)
			UiAnimation.tween_property(tween, _body, "modulate", Color.WHITE, settings.defeat_blink)
		await tween.finished
	await SceneVisual.wait_remaining(get_tree(), started, scene_length)
