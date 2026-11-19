class_name CombatResult
extends RefCounted
## Esito di un combattimento: chi sopravvive (output del sistema di combattimento).

var is_player_winner: bool = false
var player_attack: int = 0
var enemy_attack: int = 0


func is_player_alive() -> bool:
	return is_player_winner


func is_enemy_alive() -> bool:
	return not is_player_winner
