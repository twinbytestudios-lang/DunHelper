@tool
extends Node2D

@export_group("Dungeon Settings")
@export var iterations := 500      # How many steps the generator takes
@export var tile_id := 0           # The ID of your TileSet source
@export var atlas_coord := Vector2i(0, 0) # The specific tile in your atlas

@export_tool_button("Generate 2D Dungeon")
var gen_button = generate

func generate():
	var layer = get_node_or_null("TileMapLayer")
	if !layer:
		printerr("DungeonGen2D: Please add a TileMapLayer child named 'TileMapLayer'")
		return
	
	layer.clear()
	var pos = Vector2i(0, 0)
	var visited = [pos]
	
	# The Walker Logic
	for i in range(iterations):
		# Pick a random direction (Up, Down, Left, Right)
		var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
		pos += directions.pick_random()
		
		# Set the cell in the TileMapLayer
		layer.set_cell(pos, tile_id, atlas_coord)
		visited.append(pos)

	print("Dungeon Generated with ", iterations, " steps!")
