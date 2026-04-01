@tool
extends Node2D

@export_group("Generation Settings")
@export var iterations := 500
@export var clean_previous := true

@export_group("Floor Tiles")
@export var floor_source_id := 0
@export var floor_atlas_coords : Array[Vector2i] = [Vector2i(0, 0)]

@export_group("Outline / Walls")
@export var add_outline := true
@export var wall_source_id := 0
@export var wall_atlas_coord := Vector2i(1, 0)
@export var random_wall_decor := false
@export var wall_decor_coords : Array[Vector2i] = [Vector2i(2, 0)]

@export_group("Spawning")
@export_range(0, 1) var enemy_spawn_chance := 0.05
@export var enemy_types : Array[SpawnData] = []
@export_range(0, 1) var obstacle_spawn_chance := 0.1
@export var obstacle_types : Array[SpawnData] = []

@export_tool_button("Generate 2D Dungeon")
var gen_button = generate

func generate():
	var layer = get_node_or_null("TileMapLayer")
	if !layer:
		printerr("DunHelper: Add a TileMapLayer child named 'TileMapLayer'!")
		return
	
	if clean_previous:
		layer.clear()
		_clear_entities()
		
	var pos = Vector2i.ZERO
	var floor_cells = {} 

	# 1. Generate Floor Map
	for i in range(iterations):
		var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
		pos += directions.pick_random()
		var r_tile = floor_atlas_coords.pick_random() if !floor_atlas_coords.is_empty() else Vector2i.ZERO
		floor_cells[pos] = r_tile

	# 2. Draw Floor
	for cell_pos in floor_cells:
		layer.set_cell(cell_pos, floor_source_id, floor_cells[cell_pos])

	# 3. Draw Walls
	if add_outline:
		_generate_outline(layer, floor_cells)

	# 4. Spawn Entities (Ensuring they stay inside)
	_spawn_entities(layer, floor_cells.keys())

func _generate_outline(layer: TileMapLayer, floor_cells: Dictionary):
	for cell in floor_cells:
		var neighbors = [
			cell+Vector2i.UP, cell+Vector2i.DOWN, cell+Vector2i.LEFT, cell+Vector2i.RIGHT,
			cell+Vector2i(1,1), cell+Vector2i(-1,-1), cell+Vector2i(1,-1), cell+Vector2i(-1,1)
		]
		for n in neighbors:
			if !floor_cells.has(n):
				var wall_tile = wall_atlas_coord
				if random_wall_decor and !wall_decor_coords.is_empty():
					if randf() > 0.8: wall_tile = wall_decor_coords.pick_random()
				layer.set_cell(n, wall_source_id, wall_tile)

func _spawn_entities(layer: TileMapLayer, available_cells: Array):
	var container = _get_or_create_container()
	
	# SYNC: Make the entity container match the TileMap exactly
	container.global_transform = layer.global_transform

	for cell in available_cells:
		# map_to_local gives the center point of the tile
		var tile_center = layer.map_to_local(cell)
		
		if randf() < obstacle_spawn_chance:
			_instance_weighted(obstacle_types, tile_center, container)
			continue
			
		if randf() < enemy_spawn_chance:
			_instance_weighted(enemy_types, tile_center, container)

func _instance_weighted(list: Array[SpawnData], local_pos: Vector2, container: Node2D):
	if list.is_empty(): return
	
	var total_weight = 0.0
	for item in list: total_weight += item.weight
	
	var roll = randf() * total_weight
	var current_weight = 0.0
	
	for item in list:
		current_weight += item.weight
		if roll <= current_weight:
			if item.scene:
				var obj = item.scene.instantiate()
				container.add_child(obj)
				# Use position (local to container) since container is synced
				obj.position = local_pos 
				obj.owner = get_tree().edited_scene_root
			break

func _get_or_create_container() -> Node2D:
	var c = get_node_or_null("Entities")
	if !c:
		c = Node2D.new()
		c.name = "Entities"
		add_child(c)
		c.owner = get_tree().edited_scene_root
	return c

func _clear_entities():
	var c = get_node_or_null("Entities")
	if c:
		for child in c.get_children():
			child.free()
