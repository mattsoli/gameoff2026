class_name CombatResolver
extends RefCounted
## Regola del combattimento deterministico, separata dalla schermata che la anima:
## attacca il personaggio con il valore di attacco più alto, l'altro viene sconfitto.


static func resolve(player: Combatant, enemy: Combatant, player_wins_ties: bool) -> CombatResult:
	var result: CombatResult = CombatResult.new()
	result.player_attack = player.attack
	result.enemy_attack = enemy.attack
	if player.attack == enemy.attack:
		result.is_player_winner = player_wins_ties
	else:
		result.is_player_winner = player.attack > enemy.attack
	return result
