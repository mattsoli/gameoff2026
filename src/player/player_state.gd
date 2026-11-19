class_name PlayerState
extends RefCounted
## Stato del giocatore durante un livello. Viene ricreato a ogni livello
## (il Game Bible prevede che si riparta sempre senza arma).

var definition: PlayerDefinition
## Unico slot arma (null = disarmato).
var weapon: WeaponDefinition


static func create(p_definition: PlayerDefinition) -> PlayerState:
	var state: PlayerState = PlayerState.new()
	state.definition = p_definition
	return state


## Attacco totale: base + bonus dell'arma equipaggiata.
func get_attack() -> int:
	var attack: int = definition.attack
	if weapon != null:
		attack += weapon.attack_bonus
	return attack


func equip_weapon(new_weapon: WeaponDefinition) -> void:
	weapon = new_weapon
