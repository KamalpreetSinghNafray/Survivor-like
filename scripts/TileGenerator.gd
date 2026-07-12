extends Node2D

@export var tile_map_layer: TileMapLayer
@export var player: Node2D
@export var chunk_size: int = 16 # Tiles per chunk

var spawned_chunks: Dictionary = {} # Stores Vector2(chunk_x, chunk_y)

func _physics_process(_delta):
	if not player: return
	
	# Determine which chunk the player is in
	var tile_pos = tile_map_layer.local_to_map(player.global_position)
	var current_chunk = Vector2i(
		floor(float(tile_pos.x) / chunk_size),
		floor(float(tile_pos.y) / chunk_size)
	)
	
	# Check 3x3 grid of chunks around player
	for x in range(-1, 2):
		for y in range(-1, 2):
			var chunk_to_check = current_chunk + Vector2i(x, y)
			if not spawned_chunks.has(chunk_to_check):
				generate_chunk(chunk_to_check)

func generate_chunk(chunk_pos: Vector2i):
	spawned_chunks[chunk_pos] = true
	
	# Loop through the tiles inside this chunk
	for x in range(chunk_size):
		for y in range(chunk_size):
			var cell = Vector2i(
				chunk_pos.x * chunk_size + x,
				chunk_pos.y * chunk_size + y
			)
			# Spawn your tile here!
			tile_map_layer.set_cell(cell, 0, Vector2i(0, 0))
