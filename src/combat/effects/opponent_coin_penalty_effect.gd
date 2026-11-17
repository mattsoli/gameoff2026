@tool
class_name OpponentCoinPenaltyEffect
extends CombatEffect
## Toglie monete all'avversario prima del lancio (es. "-1 moneta all'avversario").

@export_range(1, 99) var amount: int = 1
## L'avversario non scende mai sotto questo numero di monete.
@export_range(0, 99) var minimum_coins: int = 0


func apply_before_roll(_self_combatant: Combatant, opponent: Combatant) -> void:
	opponent.coin_count = maxi(opponent.coin_count - amount, minimum_coins)
