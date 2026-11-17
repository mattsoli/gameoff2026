class_name CombatResolver
extends RefCounted
## Regole del combattimento, separate dalla schermata che le anima.
## La CombatScreen chiama questi metodi nell'ordine delle fasi.


## Fase "Inizio": effetti che agiscono prima del lancio (es. -1 moneta all'avversario).
static func apply_before_roll_effects(player: Combatant, enemy: Combatant) -> void:
	for effect: CombatEffect in player.effects:
		effect.apply_before_roll(player, enemy)
	for effect: CombatEffect in enemy.effects:
		effect.apply_before_roll(enemy, player)


## Fase "Battaglia": lancia tutte le monete di un combattente.
static func roll(combatant: Combatant, rng: RandomNumberGenerator, sword_chance: float) -> void:
	combatant.rolled_faces.clear()
	for i: int in combatant.coin_count:
		var face: CoinFace.Type = CoinFace.Type.SWORD if rng.randf() < sword_chance else CoinFace.Type.SHIELD
		combatant.rolled_faces.append(face)


## Fase "Battaglia": effetti che agiscono dopo il lancio (es. +1 scudo).
static func apply_after_roll_effects(player: Combatant, enemy: Combatant) -> void:
	for effect: CombatEffect in player.effects:
		effect.apply_after_roll(player, enemy)
	for effect: CombatEffect in enemy.effects:
		effect.apply_after_roll(enemy, player)


## Fase "Risoluzione": attacca sempre prima il giocatore, poi risponde il nemico se è ancora vivo.
## Le spade dell'attaccante vengono confrontate con gli scudi del difensore.
static func resolve(player: Combatant, enemy: Combatant) -> CombatResult:
	var result: CombatResult = CombatResult.new()

	result.damage_to_enemy = compute_damage(player, enemy)
	enemy.take_damage(result.damage_to_enemy)

	result.enemy_responded = enemy.is_alive()
	if result.enemy_responded:
		result.damage_to_player = compute_damage(enemy, player)
		player.take_damage(result.damage_to_player)

	result.player_hp = player.hp
	result.enemy_hp = enemy.hp
	return result


## Formula del danno: un unico punto da modificare se cambiano le regole.
static func compute_damage(attacker: Combatant, defender: Combatant) -> int:
	var swords: int = attacker.count_faces(CoinFace.Type.SWORD)
	var shields: int = defender.count_faces(CoinFace.Type.SHIELD)
	return maxi(swords - shields, 0)
