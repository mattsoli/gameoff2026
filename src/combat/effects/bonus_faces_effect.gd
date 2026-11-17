class_name BonusFacesEffect
extends CombatEffect
## Aggiunge facce garantite dopo il lancio (es. "+1 scudo in combattimento").

@export var face: CoinFace.Type = CoinFace.Type.SHIELD
@export_range(1, 99) var amount: int = 1


func apply_after_roll(self_combatant: Combatant, _opponent: Combatant) -> void:
	for i: int in amount:
		self_combatant.bonus_faces.append(face)
