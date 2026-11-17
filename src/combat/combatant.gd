class_name Combatant
extends RefCounted
## Un partecipante a un singolo combattimento. È una copia "usa e getta": gli effetti
## possono modificarla liberamente senza toccare PlayerState o EnemyEntity.
## A fine combattimento LevelSession riporta gli HP sullo stato persistente.

var display_name: String = ""
var max_hp: int = 1
var hp: int = 1
var coin_count: int = 0
var effects: Array[CombatEffect] = []
## Facce uscite dal lancio.
var rolled_faces: Array[CoinFace.Type] = []
## Facce aggiunte dagli effetti dopo il lancio (es. +1 scudo).
var bonus_faces: Array[CoinFace.Type] = []

# Dati per la presentazione.
var color: Color = Color.WHITE
var texture: Texture2D
var equipment_names: PackedStringArray = PackedStringArray()


static func from_player(state: PlayerState) -> Combatant:
	var combatant: Combatant = Combatant.new()
	combatant.display_name = state.definition.display_name
	combatant.max_hp = state.max_hp
	combatant.hp = state.hp
	combatant.coin_count = state.get_total_coin_count()
	combatant.effects = state.get_combat_effects()
	combatant.color = state.definition.color
	combatant.texture = state.definition.combat_texture
	for item: EquipmentDefinition in state.get_equipment():
		combatant.equipment_names.append(item.display_name)
	return combatant


static func from_enemy(enemy: EnemyEntity) -> Combatant:
	var definition: EnemyDefinition = enemy.get_enemy_definition()
	var combatant: Combatant = Combatant.new()
	combatant.display_name = definition.display_name
	combatant.max_hp = definition.max_hp
	combatant.hp = enemy.hp
	combatant.coin_count = definition.coin_count
	combatant.effects = definition.effects.duplicate()
	combatant.color = definition.color
	combatant.texture = definition.combat_texture
	return combatant


func get_all_faces() -> Array[CoinFace.Type]:
	var faces: Array[CoinFace.Type] = rolled_faces.duplicate()
	faces.append_array(bonus_faces)
	return faces


func count_faces(face: CoinFace.Type) -> int:
	return get_all_faces().count(face)


func take_damage(amount: int) -> void:
	hp = maxi(hp - amount, 0)


func is_alive() -> bool:
	return hp > 0


func get_effect_descriptions() -> PackedStringArray:
	var lines: PackedStringArray = PackedStringArray()
	for effect: CombatEffect in effects:
		if not effect.description.is_empty():
			lines.append(effect.description)
	return lines
