class_name CombatantPanel
extends VBoxContainer
## Pannello di un combattente: nome, sprite, valore di attacco (ben in evidenza) e slot arma.

@export var attack_format: String = "ATK %d"
@export var weapon_format: String = "Weapon: %s"
@export var no_weapon_text: String = "-"
## Se false nasconde lo slot arma (es. per i nemici).
@export var show_weapon: bool = true

@onready var _name_label: Label = %NameLabel
@onready var _body: ColorRect = %Body
@onready var _art: TextureRect = %Art
@onready var _attack_label: Label = %AttackLabel
@onready var _weapon_label: Label = %WeaponLabel

var _body_rest_position: Vector2


func setup(combatant: Combatant) -> void:
	_name_label.text = combatant.display_name
	_body.color = combatant.color
	_body.modulate = Color.WHITE
	_body.scale = Vector2.ONE
	_art.texture = combatant.texture
	_body_rest_position = _body.position
	_attack_label.text = attack_format % combatant.attack
	_weapon_label.visible = show_weapon
	var weapon: String = no_weapon_text if combatant.weapon_name.is_empty() else combatant.weapon_name
	_weapon_label.text = weapon_format % weapon


## Scatto in avanti dello sprite. direction_sign: +1 verso destra, -1 verso sinistra.
func play_attack(direction_sign: float, duration: float) -> void:
	var lunge: Vector2 = _body_rest_position + Vector2(_body.size.x * 0.4 * direction_sign, 0.0)
	var tween: Tween = create_tween()
	tween.tween_property(_body, "position", lunge, duration * 0.4).set_ease(Tween.EASE_OUT)
	tween.tween_property(_body, "position", _body_rest_position, duration * 0.6).set_ease(Tween.EASE_IN)
	await tween.finished


## Il combattente più debole subisce il colpo: lampeggia di rosso, si rimpicciolisce e sbiadisce.
func play_defeat(duration: float) -> void:
	_body.modulate = Color(1.0, 0.35, 0.35)
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(_body, "scale", Vector2.ONE * 0.7, duration)
	tween.tween_property(_body, "modulate", Color(1.0, 1.0, 1.0, 0.2), duration)
	await tween.finished
