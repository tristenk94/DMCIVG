extends Node2D

# Nodes references
var tilemap
var tree_tilemap

# Spawner variables
export var spawn_area : Rect2 = Rect2(50, 150, 100, 100) #made this 100 x 100
export var max_merchants = 4
export var start_merchants = 2
var merchant_count = 0
var merchant_scene = preload("res://characters/enemies/merchant/merchant.tscn")

# Random number generator
var rng = RandomNumberGenerator.new()

# Merchant Spawner Signals
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
	
	# Create merchants
	for i in range(start_merchants):
		instance_merchant()
		emit_signal("spawning_enemies", merchant_count) #returns signal with amt of enemies
	merchant_count = start_merchants

func instance_merchant():
	# Instance the merchant scene and add it to the scene tree
	var merchant = merchant_scene.instance()
	add_child(merchant)
	
	# Connect merchant's death signal to the spawner
	merchant.connect("death", self, "_on_merchant_death")
	
	# Place the merchant in a valid position
	var valid_position = false
	while not valid_position:
		merchant.position.x = spawn_area.position.x + rng.randf_range(0, spawn_area.size.x)
		merchant.position.y = spawn_area.position.y + rng.randf_range(0, spawn_area.size.y)
		valid_position = true #test_position(merchant.position)

	# Play merchant's birth animation
	merchant.arise()
	
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
	# Every second, check if we need to instantiate a merchant
	if merchant_count < max_merchants:
		instance_merchant()
		merchant_count = merchant_count + 1
		
func _on_merchant_death():
	merchant_count = merchant_count - 1
	
####can make a function here to see if x amt of time ran out, player did not kill merchants in time
###using a func _process(delta) check amt of time against amt of merchants
##if didnt complete in time, emit signal puzzle fail

func _process(delta):
	if merchant_count == 0 and delta >= 100:
		emit_signal("all_enemies_defeated")
		#timer connection goes here to also emit the within time signal constraint

