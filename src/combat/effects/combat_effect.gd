@tool
class_name CombatEffect
extends Resource
## Classe base per gli effetti aggiuntivi (categoria di nemico o equipaggiamento).
## Per un nuovo effetto: crea uno script che estende CombatEffect, sovrascrivi uno
## dei due metodi e crea un .tres da assegnare a EnemyDefinition / EquipmentDefinition.

## Testo mostrato nella schermata di combattimento.
@export_multiline var description: String = ""


## Chiamato prima del lancio delle monete.
func apply_before_roll(_self_combatant: Combatant, _opponent: Combatant) -> void:
	pass


## Chiamato dopo il lancio, prima della risoluzione.
func apply_after_roll(_self_combatant: Combatant, _opponent: Combatant) -> void:
	pass
