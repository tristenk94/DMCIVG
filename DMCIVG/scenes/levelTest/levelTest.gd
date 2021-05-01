extends Node2D

#THIS IS THE MAIN FUNCTION HANDLING GAME EVENTS, DOOR SPAWNS, AND ENEMY SPAWNS

# NOTE REGARDING LOCTATIONS:
# You can find positions by instancing object, go to transform and its there, use this as reference
# CORDS ARE ALWAYS [X, Y], referencing the topmost left pixel of the object
# probabbly set an ENUM type for locations later...

# DOORS
export var door_locations = [[-749.31, 9177.36], [2962.38, 9175.7]]
export var unlocked_doors = [0, 1] #array to hold info if doors are locked/unlocked, 0 = unlocked, 1 = locked

var unlocked_door_scene = preload("res://scenes/shared/props/door/door_open.tscn")
var locked_door_scene = preload("res://scenes/shared/props/door/door_locked.tscn")

# KEYS 
export var key_locations = [[2446.523, 9831.395, 1]] #array of keys
# then third index keeps track of index of door in the door array its associated with
var keys_collected = 0 #counter of keys

var key_scene = preload("res://scenes/shared/props/key/key.tscn")

# PUZZLES
export var puzzle_locations = [[3027.957, 9757.749]]
var solved_puzzles = 0 # counter of solved puzzles

var puzzle_scene = preload("res://scenes/shared/props/box_and_pit/box_and_pit_puzzle.tscn")

#REDEFINE THIS ARRAY TO HAVE LOCATIONS OF BOXES AND PITS FOR A PUZZLE ABSTRACTED, THEN PASS THIS ARRAY TO BE INSTANCED INDIVIDUALLY
#export var box_locations = [[247.355, 9551.71], [669.604, 9510.438]]
#export var pit_locations = [[675.953, 9323.124], [275.928, 672.352]]


# LAMPS
#always in [x, y]
export var lamp_locations = [[1152.877, 11122.68]]
var lamp_scene = preload("res://scenes/shared/props/switch_and_lamp/lamp.tscn")

# SWITCHES
#always in [x, y, current_color, target_color, lamp associated with]
export var switch_locations = [[1169.301, 10520.768, "red", "green", 0]]
var switch_scene = preload("res://scenes/shared/props/switch_and_lamp/switch.tscn")

# ENEMIES
# [x, y, enemy type] 
var enemy_spawns = [[247.355, 9551.71, "grunt"], [669.604, 9510.438, "skeleton"]]
var grunt_scene = preload("res://characters/enemies/grunt/grunt.tscn")
var merchant_scene = preload("res://characters/enemies/merchant/merchant.tscn")
var skeleton_scene = preload("res://characters/enemies/skeleton/skeleton.tscn")
var ballbot_scene = preload("res://characters/enemies/ballbot/ballbot.tscn")

# READY FUNCTION WILL ALWAYS SPAWN IN THIS ORDER
# - DOORS
# - KEYS
# - PUZZLES
# - LAMPS
# - SWITCHES
# - ENEMIES

# MAIN SCRIPT
func _ready():
	#load doors
	for i in range(door_locations.size()): #load doors based on above configurations
		load_doors(door_locations[i], unlocked_doors[i])
		print("door loaded : ", door_locations[i], " at ", unlocked_doors[i])
		
	#load keys
	for i in range(key_locations.size()):
		load_keys(key_locations[i])
		print("key loaded: ", key_locations[i])
		
	#load puzzles
	for i in range(puzzle_locations.size()): #load puzzles, for now just box and pits
		load_puzzles(puzzle_locations[i])
		print("puzzle loaded: ", puzzle_locations[i])
		
	#load lamps
	for i in range(lamp_locations.size()):
		load_lamps(lamp_locations[i])
		print("lamp loaded: ", lamp_locations[i])
	
	#load switches
	for i in range(switch_locations.size()):
		load_switches(switch_locations[i])
		print("switch loaded: ", switch_locations[i])
	
	#load enemies
	for i in range(enemy_spawns.size()):
		load_spawn(enemy_spawns[i])
		print("enemy spawned: ", enemy_spawns[i])

#### LOAD FUNCTIONS
func load_spawn(enemy_spawn):
	var type = enemy_spawn[2]
	var enemy
	
	if(type == "grunt"):
		enemy = grunt_scene.instance()
	elif(type == "ballbot"):
		enemy = ballbot_scene.instance()
	elif(type == "skeleton"):
		enemy = skeleton_scene.instance()
	else: #unrecognized/merchant uses merchant
		enemy = merchant_scene.instance()
		
	enemy.position.x = enemy_spawn[0]
	enemy.position.y = enemy_spawn[1]

	get_tree().root.get_node("Background").add_child(enemy)


func load_switches(switch_location):
	var switch = switch_scene.instance()
	
	switch.position.x = switch_location[0]
	switch.position.y = switch_location[1]
	switch.current_color = switch_location[2]
	switch.target_color = switch_location[3]
	switch.lamp_association = switch_location[4]
	
	get_tree().root.get_node("Background").add_child(switch)
	switch.add_to_group("switches")

func load_lamps(lamp_location):
	var lamp = lamp_scene.instance()
	
	lamp.position.x = lamp_location[0]
	lamp.position.y = lamp_location[1]
	
	get_tree().root.get_node("Background").add_child(lamp)
	lamp.add_to_group("lamps")


func load_puzzles(puzzle_location):
	var puzzle = puzzle_scene.instance()
	
	puzzle.position.x = puzzle_location[0]
	puzzle.position.y = puzzle_location[1]
	
	get_tree().root.get_node("Background").add_child(puzzle)
	puzzle.add_to_group("puzzles")

func load_keys(key_location):
	var key = key_scene.instance()
	
	key.position.x = key_location[0]
	key.position.y = key_location[1]
	
	key.door_association = key_location[2]
	
	get_tree().root.get_node("Background").add_child(key)
	key.add_to_group("keys")

func load_doors(door_location, unlocked_door): #recieve door info and instance it
	var door
	if(unlocked_door == 0): #if the door is unlocked (0), instance the unlocked version
		door = unlocked_door_scene.instance()
	elif(unlocked_door == 1): #otherwise instance the locked version
		door = locked_door_scene.instance()
	else:
		print("something was wrong with the door instance. received", door_locations, " with ", unlocked_door)
	
	door.add_to_group("doors")
	
	door.position.x = door_location[0]
	door.position.y = door_location[1]

	get_tree().root.get_node("Background").add_child(door)
	
	if(unlocked_door == 1): #lock the door once initialized
		door.lock()


#### PROCESSING FUNCTIONS
func _process(delta):
	check_key_collection()
	
	check_switches()
	
	check_puzzles_solved() 
	
	#check_area() ?
	pass

func check_puzzles_solved():
	var all_puzzles = get_tree().get_nodes_in_group("puzzles")
	
	for puzzle in all_puzzles:
		if puzzle.puzzle_solved:
			print("puzzles: ", puzzle, " solved!")
			solved_puzzles += 1
			get_tree().queue_delete(puzzle)
			
			#spawn item/key in place of puzzle? #add/hardcode a door check?
			#load_keys([puzzle.position.x+500, puzzle.position.y+500, 1])
		
func update_lamp(lamp_spot, target_color):
	var all_lamps = get_tree().get_nodes_in_group("lamps")
	if(target_color == "green"):
		all_lamps[lamp_spot].lampGreen()
	elif(target_color == "yellow"):
		all_lamps[lamp_spot].lampYellow()
	else: #target was probabbly red/all else fails handler
		all_lamps[lamp_spot].lampRed()
	
	all_lamps[lamp_spot].lamp_solved == true #once target reached no reset, keep at green


func check_switches():
	var all_switches = get_tree().get_nodes_in_group("switches")
	
	for switch in all_switches:
		if switch.current_color == switch.target_color: #if at the right color
			#print(switch, " switch at right color: ",switch.current_color, " == ", switch.target_color)
			update_lamp(switch.lamp_association, switch.target_color)

func open_door(door_spot):
	var all_doors = get_tree().get_nodes_in_group("doors")
	all_doors[door_spot].unlock()

func check_key_collection(): #connect this to an timer to not spam?
	var all_keys = get_tree().get_nodes_in_group("keys")
	
	for keys in all_keys:
		if keys.collected:
			#print("key collected at ", keys)
			keys_collected += 1
			open_door(keys.door_association)
			get_tree().queue_delete(keys)
			
