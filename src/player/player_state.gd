class_name PlayerState
extends RefCounted
## Stato del giocatore che persiste tra un livello e l'altro (HP, monete, equipaggiamento).

var definition: PlayerDefinition
var max_hp: int
var hp: int
## Monete "base": crescono sconfiggendo i nemici. I bonus dell'equipaggiamento sono a parte.
var coin_count: int
var weapon: EquipmentDefinition
var armor: EquipmentDefinition


static func create(p_definition: PlayerDefinition) -> PlayerState:
	var state: PlayerState = PlayerState.new()
	state.definition = p_definition
	state.max_hp = p_definition.max_hp
	state.hp = p_definition.max_hp
	state.coin_count = p_definition.coin_count
	state.weapon = p_definition.starting_weapon
	state.armor = p_definition.starting_armor
	return state


## Copia usata per salvare lo stato a inizio livello (per il "Riprova").
func copy() -> PlayerState:
	var state: PlayerState = PlayerState.new()
	state.definition = definition
	state.max_hp = max_hp
	state.hp = hp
	state.coin_count = coin_count
	state.weapon = weapon
	state.armor = armor
	return state


func is_alive() -> bool:
	return hp > 0


func heal_full() -> void:
	hp = max_hp


func equip(item: EquipmentDefinition) -> void:
	match item.slot:
		EquipmentDefinition.Slot.WEAPON:
			weapon = item
		EquipmentDefinition.Slot.ARMOR:
			armor = item


func get_equipment() -> Array[EquipmentDefinition]:
	var items: Array[EquipmentDefinition] = []
	if weapon != null:
		items.append(weapon)
	if armor != null:
		items.append(armor)
	return items


## Monete lanciate in combattimento: base + bonus dell'equipaggiamento.
func get_total_coin_count() -> int:
	var total: int = coin_count
	for item: EquipmentDefinition in get_equipment():
		total += item.bonus_coins
	return total


func get_combat_effects() -> Array[CombatEffect]:
	var effects: Array[CombatEffect] = []
	for item: EquipmentDefinition in get_equipment():
		effects.append_array(item.effects)
	return effects
