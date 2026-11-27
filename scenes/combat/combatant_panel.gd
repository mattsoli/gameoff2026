class_name CombatantPanel
extends StageActor
## Un combattente in scena (vedi StageActor). Sotto al riquadro: nome e valore di attacco.

@export var attack_format: String = "ATK %d"
@export var weapon_format: String = "Weapon: %s"
@export var no_weapon_text: String = "-"
## Se false nasconde nome, attacco e arma sotto al combattente.
@export var show_info: bool = true
## Se false nasconde lo slot arma (es. per i nemici).
@export var show_weapon: bool = true

@onready var _info: Control = %Info
@onready var _name_label: Label = %NameLabel
@onready var _attack_label: Label = %AttackLabel
@onready var _weapon_label: Label = %WeaponLabel


func setup(combatant: Combatant, settings: CombatSettings) -> void:
	setup_actor(combatant.scene, combatant.texture, combatant.color, settings.scene_reference_size)
	_info.visible = show_info
	_name_label.text = combatant.display_name
	_attack_label.text = attack_format % combatant.attack
	_weapon_label.visible = show_weapon
	var weapon: String = no_weapon_text if combatant.weapon_name.is_empty() else combatant.weapon_name
	_weapon_label.text = weapon_format % weapon


## Scatto in avanti e ritorno. direction_sign: +1 verso destra, -1 verso sinistra.
## In parallelo parte l'animazione "attack" della scena; si attende la più lunga delle due.
func play_attack(direction_sign: float, settings: CombatSettings) -> void:
	var started: int = Time.get_ticks_msec()
	var scene_length: float = play_one_shot(SceneVisual.ATTACK)
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
	var scene_length: float = play_one_shot(SceneVisual.DEFEAT)
	if settings.defeat_blink_count > 0:
		var tween: Tween = create_tween()
		for i: int in settings.defeat_blink_count:
			UiAnimation.tween_property(tween, _body, "modulate", settings.defeat_blink_color, settings.defeat_blink)
			UiAnimation.tween_property(tween, _body, "modulate", Color.WHITE, settings.defeat_blink)
		await tween.finished
	await SceneVisual.wait_remaining(get_tree(), started, scene_length)
