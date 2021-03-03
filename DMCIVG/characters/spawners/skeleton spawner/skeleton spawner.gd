extends Node2D

# Nodes references
var tilemap
var tree_tilemap

# Spawner variables
export var spawn_area : Rect2 = Rect2(50, 150, 100, 100) #made this 100 x 100
export var max_skeletons = 4
export var start_skeletons = 2
var skeleton_count = 0
var skeleton_scene = preload("res://characters/enemies/skeleton/skeleton.tscn")

# Random number generator
var rng = RandomNumberGenerator.new()

# Skeleton Spawner Signals
signal spawning_enemies
signal all_enemies_defeated

signal enemies_not_killed_in_time #come back to this signal later...attach a timer timeout to this 
#this is for a special puzzle room

func _ready():
	# Get tilemaps references
#	tilemap = get_tree().root.get_node("Root/TileMap")
#	tree_tilemap = get_tree().root.get_node("Root/Tree TileMap")
	
	# Initialize random number generator
	rng.randomize()
	
	# Create skeleton
	for i in range(start_skeletons):
		instance_skeleton()
		emit_signal("spawning_enemies", skeleton_count) #returns signal with amt of enemies
	skeleton_count = start_skeletons

func instance_skeleton():
	# Instance the skeleton scene and add it to the scene tree
	var skeleton = skeleton_scene.instance()
	add_child(skeleton)
	
	# Connect Skeleton's death signal to the spawner
	skeleton.connect("death", self, "_on_Skeleton_death")
	
	# Place the skeleton in a valid position
	var valid_position = false
	while not valid_position:
		skeleton.position.x = spawn_area.position.x + rng.randf_range(0, spawn_area.size.x)
		skeleton.position.y = spawn_area.position.y + rng.randf_range(0, spawn_area.size.y)
		valid_position = true #test_position(skeleton.position)

	# Play skeleton's birth animation
	skeleton.arise()
	
func test_position(position : Vector2): #redefine this function to ensure in bounds, can rename with tiles (the ones that ahrin used here)
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
	# Every second, check if we need to instantiate a skeleton
	if skeleton_count < max_skeletons:
		instance_skeleton()
		skeleton_count = skeleton_count + 1
		
func _on_Skeleton_death():
	skeleton_count = skeleton_count - 1


##can make a function here, once all skeletons are killed, emit a signal, room cleared or something
#using func _process(delta) and skeleton_count == 0
func _process(delta):
	if skeleton_count == 0 and delta >= 100:
		emit_signal("all_enemies_defeated")
		#timer connection goes here to also emit the within time signal constraint
