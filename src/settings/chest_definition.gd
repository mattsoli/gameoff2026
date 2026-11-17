@tool
class_name ChestDefinition
extends EntityDefinition
## Baule: si apre quando la pedina ci entra e assegna la sua ricompensa una sola volta.

@export_group("Ricompensa")
@export_range(0, 99) var reward_coins: int = 0
## Equipaggiamento ottenuto (sostituisce quello nello stesso slot). Opzionale.
@export var reward_equipment: EquipmentDefinition

@export_group("Visual")
## Opacità dell'icona quando il baule è già stato aperto.
@export_range(0.0, 1.0, 0.05) var opened_alpha: float = 0.35


func create_entity() -> BoardEntity:
	return ChestEntity.new(self)
