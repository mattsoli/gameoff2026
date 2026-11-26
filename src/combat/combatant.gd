class_name Combatant
extends RefCounted
## Un partecipante a un combattimento: i soli dati che servono alla schermata e alle regole.

var display_name: String = ""
var attack: int = 0
## Nome dell'arma equipaggiata (vuoto per i nemici o se disarmato).
var weapon_name: String = ""

# Dati per la presentazione.
var color: Color = Color.WHITE
var texture: Texture2D
var scene: PackedScene


static func from_player(state: PlayerState) -> Combatant:
	var combatant: Combatant = Combatant.new()
	combatant.display_name = state.definition.display_name
	combatant.attack = state.get_attack()
	combatant.color = state.definition.color
	combatant.texture = state.definition.combat_texture
	combatant.scene = state.definition.combat_scene
	if state.weapon != null:
		combatant.weapon_name = state.weapon.display_name
	return combatant


static func from_enemy(enemy: EnemyEntity) -> Combatant:
	var definition: EnemyDefinition = enemy.get_enemy_definition()
	var combatant: Combatant = Combatant.new()
	combatant.display_name = definition.display_name
	combatant.attack = definition.attack
	combatant.color = definition.color
	combatant.texture = definition.combat_texture
	combatant.scene = definition.combat_scene
	return combatant
