@tool
class_name WeaponDefinition
extends EntityDefinition
## Arma sulla board: la pedina la raccoglie entrando nella casella e la equipaggia
## nel suo unico slot (sostituisce quella che aveva).

@export_group("Statistiche")
## Valore aggiunto all'attacco del giocatore finché l'arma è equipaggiata.
@export_range(0, 999) var attack_bonus: int = 1


func create_entity() -> BoardEntity:
	return WeaponEntity.new(self)
