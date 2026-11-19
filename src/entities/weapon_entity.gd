@tool
class_name WeaponEntity
extends BoardEntity
## Arma sulla board. Quando viene raccolta viene rimossa dalla casella (la freccia resta).


func get_weapon_definition() -> WeaponDefinition:
	return definition as WeaponDefinition
