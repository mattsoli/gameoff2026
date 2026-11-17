class_name CombatantPanel
extends VBoxContainer
## Pannello di un combattente: nome, sprite, HP, monete, equipaggiamento ed effetti.

@export var hp_format: String = "HP %d / %d"
@export var coins_format: String = "Coins: %d"
@export var equipment_format: String = "Equip: %s"
@export var no_equipment_text: String = "-"
## Se false nasconde la riga dell'equipaggiamento (es. per i nemici).
@export var show_equipment: bool = true

@onready var _name_label: Label = %NameLabel
@onready var _body: ColorRect = %Body
@onready var _art: TextureRect = %Art
@onready var _damage_label: Label = %DamageLabel
@onready var _hp_bar: ProgressBar = %HpBar
@onready var _hp_label: Label = %HpLabel
@onready var _coins_label: Label = %CoinsLabel
@onready var _equipment_label: Label = %EquipmentLabel
@onready var _effects_label: Label = %EffectsLabel

var _combatant: Combatant
var _body_rest_position: Vector2


func setup(combatant: Combatant) -> void:
	_combatant = combatant
	_name_label.text = combatant.display_name
	_body.color = combatant.color
	_art.texture = combatant.texture
	_body_rest_position = _body.position
	_damage_label.visible = false
	_hp_bar.max_value = combatant.max_hp
	_hp_bar.value = combatant.hp

	_equipment_label.visible = show_equipment
	var equipment: String = ", ".join(combatant.equipment_names)
	_equipment_label.text = equipment_format % (no_equipment_text if equipment.is_empty() else equipment)
	var effects: PackedStringArray = combatant.get_effect_descriptions()
	_effects_label.visible = not effects.is_empty()
	_effects_label.text = "\n".join(effects)
	refresh_stats()


func refresh_stats() -> void:
	_hp_label.text = hp_format % [_combatant.hp, _combatant.max_hp]
	_coins_label.text = coins_format % _combatant.coin_count


## Scatto in avanti dello sprite. direction_sign: +1 verso destra, -1 verso sinistra.
func play_attack(direction_sign: float, duration: float) -> void:
	var lunge: Vector2 = _body_rest_position + Vector2(_body.size.x * 0.35 * direction_sign, 0.0)
	var tween: Tween = create_tween()
	tween.tween_property(_body, "position", lunge, duration * 0.4).set_ease(Tween.EASE_OUT)
	tween.tween_property(_body, "position", _body_rest_position, duration * 0.6).set_ease(Tween.EASE_IN)
	await tween.finished


## Mostra il danno ricevuto e aggiorna la barra degli HP (gli HP sono già scalati nel Combatant).
func play_hit(damage: int, duration: float) -> void:
	_damage_label.text = "-%d" % damage if damage > 0 else "0"
	_damage_label.visible = true
	_damage_label.modulate.a = 1.0

	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(_hp_bar, "value", float(_combatant.hp), duration)
	if damage > 0:
		_body.modulate = Color(1.0, 0.4, 0.4)
		tween.tween_property(_body, "modulate", Color.WHITE, duration)
	tween.tween_property(_damage_label, "modulate:a", 0.0, duration).set_delay(duration)
	await tween.finished
	_damage_label.visible = false
	refresh_stats()
