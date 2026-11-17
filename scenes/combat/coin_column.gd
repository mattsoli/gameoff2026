class_name CoinColumn
extends Control
## Colonna verticale di monete davanti a un combattente.
## Posiziona le monete a mano (non è un Container) per poterle animare quando si riordinano.

var _settings: CombatSettings
var _coins: Array[CoinView] = []


func setup(settings: CombatSettings) -> void:
	_settings = settings
	mouse_filter = Control.MOUSE_FILTER_IGNORE


## Prepara `count` monete coperte, pronte per essere lanciate.
func show_hidden_coins(count: int) -> void:
	for coin: CoinView in _coins:
		coin.queue_free()
	_coins.clear()
	for i: int in count:
		_add_coin(false)
	_snap_to_slots()


## Lancia le monete una dopo l'altra. Restituisce quando l'ultima ha finito.
func reveal(faces: Array[CoinFace.Type]) -> void:
	assert(faces.size() == _coins.size(), "Numero di facce diverso dal numero di monete")
	for i: int in faces.size():
		if i == faces.size() - 1:
			await _coins[i].play_flip(faces[i], _settings.coin_flip_duration)
		else:
			_coins[i].play_flip(faces[i], _settings.coin_flip_duration)
			await get_tree().create_timer(_settings.coin_flip_stagger).timeout


## Aggiunge in fondo le monete bonus date dagli effetti.
func add_bonus_coins(faces: Array[CoinFace.Type]) -> void:
	for face: CoinFace.Type in faces:
		var coin: CoinView = _add_coin(true)
		coin.reveal_instantly(face)
		coin.position = _slot_position(_coins.size() - 1)
		coin.play_pop_in(_settings.coin_arrange_duration)


## Riordina le monete: le facce elencate prima in `order` vanno in alto.
func arrange(order: Array[CoinFace.Type]) -> void:
	var sorted: Array[CoinView] = []
	for face: CoinFace.Type in order:
		for coin: CoinView in _coins:
			if coin.face == face:
				sorted.append(coin)
	_coins = sorted
	if _coins.is_empty():
		return # un Tween senza animazioni non emetterebbe mai "finished"

	var tween: Tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	for i: int in _coins.size():
		tween.tween_property(_coins[i], "position", _slot_position(i), _settings.coin_arrange_duration)
	await tween.finished


## Tempo necessario per lanciare `count` monete (serve ad attendere due colonne in parallelo).
func get_reveal_duration(count: int) -> float:
	if count <= 0:
		return 0.0
	return (count - 1) * _settings.coin_flip_stagger + _settings.coin_flip_duration


func _add_coin(is_bonus: bool) -> CoinView:
	var coin: CoinView = CoinView.new()
	coin.setup(_settings, is_bonus)
	add_child(coin)
	_coins.append(coin)
	_update_minimum_size()
	return coin


func _snap_to_slots() -> void:
	for i: int in _coins.size():
		_coins[i].position = _slot_position(i)


func _slot_position(index: int) -> Vector2:
	return Vector2(0.0, index * (_settings.coin_size + _settings.coin_spacing))


func _update_minimum_size() -> void:
	var count: int = maxi(_coins.size(), 1)
	var height: float = count * _settings.coin_size + (count - 1) * _settings.coin_spacing
	custom_minimum_size = Vector2(_settings.coin_size, height)
