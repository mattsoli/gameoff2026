class_name BoardGenerator
extends RefCounted


static func create_random_tile(pool: Array[TileDefinition], rng: RandomNumberGenerator) -> TileInstance:
	assert(not pool.is_empty(), "Il tile_pool è vuoto")
	var index: int = rng.randi_range(0, pool.size() - 1)
	return TileInstance.new(pool[index])


static func generate(size: Vector2i, pool: Array[TileDefinition], rng: RandomNumberGenerator) -> BoardModel:
	var board: BoardModel = BoardModel.new(size)
	for y: int in size.y:
		for x: int in size.x:
			board.set_tile(Vector2i(x, y), create_random_tile(pool, rng))
	return board
