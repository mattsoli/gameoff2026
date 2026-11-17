class_name CombatResult
extends RefCounted
## Esito finale di un combattimento (output del sistema di combattimento).

var damage_to_enemy: int = 0
var damage_to_player: int = 0
## False se il nemico è morto prima di poter rispondere.
var enemy_responded: bool = false
var player_hp: int = 0
var enemy_hp: int = 0


func is_player_alive() -> bool:
	return player_hp > 0


func is_enemy_alive() -> bool:
	return enemy_hp > 0
