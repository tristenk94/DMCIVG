extends Node2D

#THIS IS THE MAIN FUNCTION HANDLING GAME EVENTS, DOOR SPAWNS, AND ENEMY SPAWNS

var score = 0 #keep track of player's score
##breakdown for score
#pickup...
#	keys = 1000
#	potions = 100
#
#actions...
#	opening doors = 100
#	solving puzzle = 500
#	solving lamp room 1 = 1000
#	solving lamp room 2 = 3000
#
#defeating...
#	boss = 10000
#	ballbot = 5000
#	skeleton = 2500
#	grunt = 1500
#	merchant = 1000


# NOTE REGARDING LOCTATIONS:
# You can find positions by instancing object, go to transform and its there, use this as reference
# CORDS ARE ALWAYS [X, Y], referencing the topmost left pixel of the object
# probabbly set an ENUM type for locations later...

# DOORS
export var door_locations = [[-749.31, 9177.36], [2962.38, 9175.7], #opens 2nd area Left to Right 
[4816.309, 9171.123], #locked from first key, unlocks switch for puzzle room
[2961.735, 8021.72], #puzzle room door 1
[3025.664, 6101.44], #puzzle room door 2
[-685.559, 6102.016], #boss room door
[81.701, 2645.641], #safe room door 


]
export var unlocked_doors = [1, 0, 1, 1, 1, 1, 1] #array to hold info if doors are locked/unlocked, 0 = unlocked, 1 = locked

var unlocked_door_scene = preload("res://scenes/shared/props/door/door_open.tscn")
var locked_door_scene = preload("res://scenes/shared/props/door/door_locked.tscn")

# KEYS 
export var key_locations = [[5396.495, 9949.679, 2], #opens puzzle room
[1813.271, 7903.707, 5], #opens boss room door

 ] 
# then third index keeps track of index of door in the door array its associated with
var keys_collected = 0 #counter of keys
var key_scene = preload("res://scenes/shared/props/key/key.tscn")

# PUZZLES
export var puzzle_locations = [[-3254.879, 9237.282]]
var solved_puzzles = 0 # counter of solved puzzles

var puzzle_scene = preload("res://scenes/shared/props/box_and_pit/box_and_pit_puzzle.tscn")

#POTION
#x , y,  0/1 (charges or no charges)
export var potion_locations = [
#health	
[-1536.482, 6240.099, 0], [-3197.72, 7494.503, 0], [3579.771, 10803.899, 0],

#charges
[1294.402, 7375.842, 1], [2963.175, 8654.292, 1], [5265.514, 9361.4, 1], [1186.923, 0996.231, 1],

#speed boost
[-1770.941, 8117.495, 2]]
var potion_scene = preload("res://scenes/shared/props/potion/potion.tscn")

#SWORD
export var sword_locations=[[3025.342,5151.644,0]] #in puzzle room 2
var sword_collected = 0
var sword_scene = preload("res://scenes/shared/props/sword/sword.tscn")


var player_reference
var player_in_area_4 = false


# LAMPS
#always in [x, y]
export var lamp_locations = [[5385.729, 8216.284], #first locked room (unlock for puzzle room)
[3983.133, 6296.445], #puzzle room 
[-625.062, 25.832] #safe room
]
var lamp_scene = preload("res://scenes/shared/props/switch_and_lamp/lamp.tscn")
var solved_lamps = 0
# SWITCHES
#always in [x, y, current_color, target_color, lamp associated with], -1 if not associated with anything
export var switch_locations = [
	#empty switches
	[-2926.011,10648.677, "red", "green", -1], [-2926.011, 11160.457, "red", "green", -1], [3729.29, 9369.192, "red", "green", -1], 
[-1774.359, 7832.737, "red", "green", -1], [1301.022, 7834.3, "red", "green", -1], [-2418.371, 6297.391, "red", "green", -1], 
[-2030.939, 6298.391, "red", "green", -1], [1167.756, 10520.992, "red", "green", -1],

#TODO - LINK THESE TO LAMPS

#this switch locks the door to puzzle room
[4756.68, 8473.017, "yellow", "green", 0],

#these switches are for the puzzle room
[2323.183, 6297.441, "yellow", "red", 1], [2964.63, 7320.756, "red", "green", 1],[3471.661, 6296.569, "green", "yellow", 1],

#this is the final switch - after boss room
[-1006.52, 24.905, "red", "green", 2],
]
var switch_scene = preload("res://scenes/shared/props/switch_and_lamp/switch.tscn")

# ENEMIES
# [x, y, enemy type] 
var enemy_spawns = [
[247.355, 9551.71, "grunt"], [669.604, 9510.438, "skeleton"], #by door to room 2
[3936, 10472, "grunt"], #first encounter f1, grunt

[2303.499, 7570.036, "skeleton"], #skeleton in puzzle room f2
[-3104, 6536, "ballbot"], #ballbot top left under boss room, f2
[32.01, 7163.202, "ballbot"], [1099.948, 8443.033, "ballbot"], #ballbots in center of f2
[-2410.591, 8385.951, "merchant"], #merchant in f2

[4334.592, 8956.769, "merchant"], #merchant in first puzzle room f1 

[-127.312, 5845.804, "skeleton"], [-136.826, 5522.341, "skeleton"], # skeletons in boss room

[-735.206, 3775.714, "boss"]#boss in boss room
]
var boss_slain = false

var grunt_scene = preload("res://characters/enemies/grunt/grunt.tscn")
var merchant_scene = preload("res://characters/enemies/merchant/merchant.tscn")
var skeleton_scene = preload("res://characters/enemies/skeleton/skeleton.tscn")
var ballbot_scene = preload("res://characters/enemies/ballbot/ballbot.tscn")
var boss_scene = preload("res://characters/enemies/boss/boss.tscn")

# Particles
onready var key_particles = get_node("KeyParticles")
var particle_timer = 3000 #timer to keep particles going

# Signals
signal victory #we won the game


# READY FUNCTION WILL ALWAYS SPAWN IN THIS ORDER
# - DOORS
# - KEYS
# - PUZZLES
# - LAMPS
# - SWITCHES
# - ENEMIES
# - POTIONS
# - SWORD
# MAIN SCRIPT
func _ready():
	#load doors
	for i in range(door_locations.size()): #load doors based on above configurations
		load_doors(door_locations[i], unlocked_doors[i])
		#print("door loaded : ", door_locations[i], " at ", unlocked_doors[i])
		
	#load keys
	for i in range(key_locations.size()):
		load_keys(key_locations[i])
		#print("key loaded: ", key_locations[i])
		
	#load puzzles
	for i in range(puzzle_locations.size()): #load puzzles, for now just box and pits
		load_puzzles(puzzle_locations[i])
		#print("puzzle loaded: ", puzzle_locations[i])
		
	#load lamps
	for i in range(lamp_locations.size()):
		load_lamps(lamp_locations[i])
		#print("lamp loaded: ", lamp_locations[i])
	
	#load switches
	for i in range(switch_locations.size()):
		load_switches(switch_locations[i])
		#print("switch loaded: ", switch_locations[i])
	
	#load enemies
	for i in range(enemy_spawns.size()):
		load_spawn(enemy_spawns[i])
		#print("enemy spawned: ", enemy_spawns[i])
	
		#load potions(need load potion function)
	for i in range(potion_locations.size()):
		load_potion(potion_locations[i])
		print("potion spawned: ", potion_locations[i])
		
	for i in range(sword_locations.size()):
		load_sword(sword_locations[i])
		print("sword spawned: ", sword_locations[i])
		
	player_reference = get_tree().root.get_node("Main/Background/player")


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
	elif(type == "boss"):
		enemy = boss_scene.instance()
	elif(type == "merchant"):
		enemy = merchant_scene.instance()
	else: #unrecognized uses merchant
		enemy = merchant_scene.instance()
		
	enemy.position.x = enemy_spawn[0]
	enemy.position.y = enemy_spawn[1]
	
	#enemy.connect("")

	get_tree().root.get_node("Main/Background").add_child(enemy)

	if(type == "grunt"):
		enemy.add_to_group("grunt")#record the instance of grunt
	elif(type == "ballbot"):
		enemy.add_to_group("ballbot")#record the instance of ballbot
	elif(type == "skeleton"):
		enemy.add_to_group("skeleton")#record the instance of skeleton
	elif(type == "boss"):
		enemy.add_to_group("boss")#record the instance of boss
		print("boss added")
	elif(type == "merchant"):
		enemy.add_to_group("merchant")#record the instance of merchant

func load_switches(switch_location):
	var switch = switch_scene.instance()
	
	switch.position.x = switch_location[0]
	switch.position.y = switch_location[1]
	switch.current_color = switch_location[2]
	switch.target_color = switch_location[3]
	switch.lamp_association = switch_location[4]
	
	get_tree().root.get_node("Main/Background").add_child(switch)
	switch.add_to_group("switches")

func load_lamps(lamp_location):
	var lamp = lamp_scene.instance()
	
	lamp.position.x = lamp_location[0]
	lamp.position.y = lamp_location[1]
	
	get_tree().root.get_node("Main/Background").add_child(lamp)
	lamp.add_to_group("lamps")


func load_puzzles(puzzle_location):
	var puzzle = puzzle_scene.instance()
	
	puzzle.position.x = puzzle_location[0]
	puzzle.position.y = puzzle_location[1]
	
	get_tree().root.get_node("Main/Background").add_child(puzzle)
	puzzle.add_to_group("puzzles")

func load_keys(key_location):
	var key = key_scene.instance()
	
	key.position.x = key_location[0]
	key.position.y = key_location[1]
	
	key.door_association = key_location[2]
	
	get_tree().root.get_node("Main/Background").add_child(key)
	key.add_to_group("keys")
	
	key_particles.position.x = key_location[0] - 35 #the key vs particles if offscale, this fixes it
	key_particles.position.y = key_location[1]
	key_particles.set_emitting(true)
	key_particles.show()

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

	get_tree().root.get_node("Main/Background").add_child(door)
	
	if(unlocked_door == 1): #lock the door once initialized
		door.lock()

#potion
func load_potion(potion_location):
	var potion = potion_scene.instance()
	
	potion.position.x = potion_location[0]
	potion.position.y = potion_location[1]
	potion.potion_type = potion_location[2]
	
	
	get_tree().root.get_node("Main/Background").add_child(potion)
	potion.add_to_group("potions")
	
	if(potion.potion_type == 0):
		potion.switch_health()
	elif(potion.potion_type == 1):
		potion.switch_charge()
	elif(potion.potion_type ==2):
		potion.switch_speed()

#sword
func load_sword(sword_location):
	var sword = sword_scene.instance()
	sword.position.x = sword_location[0]
	sword.position.y = sword_location[1]
	
	get_tree().root.get_node("Main/Background").add_child(sword)
	sword.add_to_group("swords")

#### PROCESSING FUNCTIONS
func _process(delta):
	check_key_collection()
	
	check_switches()
	
	check_puzzles_solved() 
	
	check_potions_collection()
	
	check_sword_collection()
	
	if !boss_slain: #if the boss hasnt been slain, check
		check_boss()


	
func check_boss():#check if the boss has been slain or not
	var theboss = get_tree().get_nodes_in_group("boss")
	#print("the boss recieved", theboss)
	if(theboss.size() == 0): #if he has been removed + defeated, 
		#also added time check to prevent it from running onload
		#print("boss defeated")
		load_keys([-757.649, 4054.487, 6]) #spanws a key to open safe room door
		#sound fx for unlocking the safe room?
		boss_slain = true #boss has been slain, used to short circuit this funct
		score += 10000
		
#		# BOSS IS DEAD NOW KILL ALL ENEMIES
#		var all_enemies = get_tree().get_nodes_in_group("grunts")
#
#		for grunt in all_enemies:
#			get_tree().queue_delete(grunt)
#
#		all_enemies = get_tree().get_nodes_in_group("ballbot")
#
#		for ballbot in all_enemies:
#			get_tree().queue_delete(ballbot)
#
#		all_enemies = get_tree().get_nodes_in_group("skeleton")
#
#		for skeleton in all_enemies:
#			get_tree().queue_delete(skeleton)
#
#		all_enemies = get_tree().get_nodes_in_group("merchant")
#
#		for merchant in all_enemies:
#			get_tree().queue_delete(merchant)
			
		

func check_puzzles_solved():
	var all_puzzles = get_tree().get_nodes_in_group("puzzles")
	
	for puzzle in all_puzzles:
		if puzzle.puzzle_solved:
			#print("puzzles: ", puzzle, " solved!")
			solved_puzzles += 1
			get_tree().queue_delete(puzzle)
			
			#spawn item/key in place of puzzle? #add/hardcode a door check?
			load_keys([-2284.317, 9306.183, 0]) #opens first door puzzle
			score += 500
		
func update_lamp(lamp_spot, target_color):
	var all_lamps = get_tree().get_nodes_in_group("lamps")
	if(target_color == "green"):
		all_lamps[lamp_spot].lampGreen()
	elif(target_color == "yellow"):
		all_lamps[lamp_spot].lampYellow()
	else: #target was probabbly red/all else fails handler
		all_lamps[lamp_spot].lampRed()
	
	all_lamps[lamp_spot].lamp_solved == true #once target reached no reset, keep at green
	solved_lamps+=1
	
	if solved_lamps == 1: #if we solved 1 lamp, the first puzzle room, open key to 2nd puzzle room
		load_keys([5389.245, 9053.236, 3]) #opens first door puzzle key
		score += 1000
	if solved_lamps == 4: #if we solved 4 lamps, or completed the puzzle sidequest, we can unlock the prize!
		load_keys([3592.301, 6617.383, 4]) #opens second door puzzle key
		score += 3000
		
	if player_in_area_4:
		emit_signal("victory") #solving a lamp while in area 4 will end the game
		#print("victory")


func check_switches():
	var all_switches = get_tree().get_nodes_in_group("switches")
	
	for switch in all_switches:
		if switch.lamp_association != -1 && switch.current_color == switch.target_color: #if at the right color
			#print(switch, " switch at right color: ",switch.current_color, " == ", switch.target_color)
			update_lamp(switch.lamp_association, switch.target_color)
			switch.lamp_association = -1 #remove the association once solved to not double count
			#sound fx for a switch here

func open_door(door_spot):
	var all_doors = get_tree().get_nodes_in_group("doors")
	all_doors[door_spot].unlock()
	score += 100

func check_key_collection(): #connect this to an timer to not spam?
	var all_keys = get_tree().get_nodes_in_group("keys")
	
	for keys in all_keys:
		if keys.collected:
			#print("key collected at ", keys)
			keys_collected += 1
			open_door(keys.door_association)
			get_tree().queue_delete(keys)
			#sound fx for key pickup here
			score += 1000
			

#check potion collection
func check_potions_collection(): #connect this to an timer to not spam?
	var all_potions = get_tree().get_nodes_in_group("potions")
	
	for potions in all_potions:
		if potions.collected:
			if potions.potion_type == 0:
				player_reference.health += 20
				$"Potion Sounds/SoundHealth".play()
				#print("health potion collected")
			elif potions.potion_type == 1:
				player_reference.charges_remaining += 1
				$"Potion Sounds/SoundCharge".play()
				#print("charge potion collected")
			elif potions.potion_type == 2:
				player_reference.speed += 100
				$"Potion Sounds/SoundSpeed".play()
				#print("speed potion collected")
				player_reference.speedPickup = true
			#print("potion deleted")
			get_tree().queue_delete(potions)
			


#check sword collection
func check_sword_collection(): #connect this to an timer to not spam?
	var all_swords = get_tree().get_nodes_in_group("swords")
	
	for sword in all_swords:
		if sword.collected:
			sword_collected += 1
			player_reference.stab_attack_damage += 20
			player_reference.slash_attack_damage += 20
			player_reference.swordPickup = true
			$"Potion Sounds/SoundSpeed".play() #reusing speed potion for sword pickup
			get_tree().queue_delete(sword)

func _on_GUI_player_in_area_4(response): #receives signal from gui
	player_in_area_4 = response
	print("player in area 4", player_in_area_4, response)

