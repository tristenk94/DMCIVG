extends Node2D

# Nodes references
var tilemap
var tree_tilemap

# Spawner variables
export var spawn_area : Rect2 = Rect2(50, 150, 100, 100) #made this 100 x 100
export var max_ballbots = 4
export var start_ballbots = 2
var ballbot_count = 0
var ballbot_scene = preload("res://characters/enemies/ballbot/ballbot.tscn")

# Random number generator
var rng = RandomNumberGenerator.new()

func _ready():
	# Get tilemaps references
#	tilemap = get_tree().root.get_node("Root/TileMap")
#	tree_tilemap = get_tree().root.get_node("Root/Tree TileMap")
	
	# Initialize random number generator
	rng.randomize()
	
	# Create ballbots
	for i in range(start_ballbots):
		instance_ballbot()
	ballbot_count = start_ballbots

func instance_ballbot():
	# Instance the ballbot scene and add it to the scene tree
	var ballbot = ballbot_scene.instance()
	add_child(ballbot)
	
	# Connect ballbot's death signal to the spawner
	ballbot.connect("death", self, "_on_Ballbot_death")
	
	# Place the ballbot in a valid position
	var valid_position = false
	while not valid_position:
		ballbot.position.x = spawn_area.position.x + rng.randf_range(0, spawn_area.size.x)
		ballbot.position.y = spawn_area.position.y + rng.randf_range(0, spawn_area.size.y)
		valid_position = true #test_position(ballbot.position)

	# Play ballbot's birth animation
	ballbot.arise()
	
func test_position(position : Vector2):
	# Check if the cell type in this position is grass or sand
	var cell_coord = tilemap.world_to_map(position)
	var cell_type_id = tilemap.get_cellv(cell_coord)
	var grass_or_sand = (cell_type_id == tilemap.tile_set.find_tile_by_name("Grass")) || (cell_type_id == tilemap.tile_set.find_tile_by_name("Sand"))
	
	# Check if there's a tree in this position
	cell_coord = tree_tilemap.world_to_map(position)
	cell_type_id = tree_tilemap.get_cellv(cell_coord)
	var no_trees = (cell_type_id != tilemap.tile_set.find_tile_by_name("Tree"))
	
	# If the two conditions are true, the position is valid
	return grass_or_sand and no_trees


func _on_Timer_timeout():
	# Every second, check if we need to instantiate a ballbot
	if ballbot_count < max_ballbots:
		instance_ballbot()
		ballbot_count = ballbot_count + 1
		
func _on_ballbot_death():
	ballbot_count = ballbot_count - 1
