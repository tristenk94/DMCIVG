extends CanvasLayer


#health textures
var bar_red = preload("res://gui/redhp.png")
var bar_orange = preload("res://gui/orangehp.png")
var bar_green = preload("res://gui/greenhp.png")
var bar_yellow = preload("res://gui/yellowhp.png")

#references to the game
var player
var boss
var background_scene

onready var playerhealth = get_node("player_hp/Health/Bar")
onready var playerhealthvalue = get_node("player_hp/Health/value")
onready var laservalue = get_node("laser/number")
onready var score_board = get_node("Score Area/Score Label")
onready var level_map = get_node("map")
onready var victory_score_board = get_node("Victory Pop-Up/Blue Screen/Score Area2/Score Label")
onready var game_over_score_board = get_node("Game Over Pop-Up/Red Screen/Score Area2/Score Label")

#game over menus
onready var game_over_screen = get_node("Game Over Pop-Up") 
onready var victory_screen = get_node("Victory Pop-Up")

#Area Display popups 
onready var display_area1 = get_node("Area1 Display")
onready var display_area2 = get_node("Area2 Display")
onready var display_area3 = get_node("Area3 Display")
onready var display_area4 = get_node("Area4 Display")

var game_over_selected_menu

signal player_in_area_4

# Called when the node enters the scene tree for the first time.
func _ready():
	background_scene = get_tree().root.get_node("Main/Background")
	player = get_tree().root.get_node("Main/Background/player")
	playerhealth.max_value = player.health_max
	playerhealth.value = player.health
	get_tree().paused = false 
	level_map.hide() #hide the map on launch so it doesnt come up first thing
	
	#work around so that the area 1 text actually displays 
	#should only run once
#	yield(get_tree().create_timer(.5), "timeout")
#	display_area1.popup()
#	yield(get_tree().create_timer(2.5), "timeout")
	hide_pop()#just in case we have an outlier in pausing/restarting game, unpause the game
	initialize()
	get_tree().paused = false #just in case we have an outlier in pausing/restarting game, unpause the game
	
	
	# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	update_player()
	update_scoreboard()
	
	
# function for initializing health
func initialize():
	playerhealth.max_value = player.health_max
	playerhealth.value = player.health
	
	
func _input(event):
	# display static image of entire map
	# TODO: zoom function
	if event.is_action_pressed("map"):
		if get_tree().paused == false:
			get_tree().paused = true #pause game while map is displayed
			level_map.show()
		elif get_tree().paused == true:
			level_map.hide()
			get_tree().paused = false #unpause game when closing map
	
	
func update_player():
	#player hp
	var healthpercent = (player.health / player.health_max) * 100
	
	if player.health <= playerhealth.max_value * 0.75 and player.health > playerhealth.max_value * 0.5:
		playerhealth.texture_progress = bar_yellow
	elif player.health <= playerhealth.max_value * 0.5 and player.health > playerhealth.max_value * 0.25:
		playerhealth.texture_progress = bar_orange
	elif player.health <= playerhealth.max_value * 0.25:
		playerhealth.texture_progress = bar_red
	else:
		playerhealth.texture_progress = bar_green
	playerhealth.value = player.health
	playerhealthvalue.text = str(round(healthpercent), "%")
	
	if playerhealth.value == 0: #end the game if player loses all health
		end_game()
		
	#player attack charge
	laservalue.text = str("x", player.charges_remaining)


func end_game(): #displays game over scren, shows option to quit or restart along with score
	#_on_Game_Over_PopUp_draw() #dont need to use the pause function
	game_over_screen.popup()
	get_tree().paused = true #pauses game
	score_board.hide()
	
	
func update_scoreboard():
	var to_update = background_scene.score
	score_board.text = str(to_update) #removed the other display, "Score: " + str(to_update)
	game_over_score_board.text = "Your Score: " + str(to_update)
	victory_score_board.text = "Your Score: " + str(to_update)


func _on_Quit__pressed(): # MAKE SURE PROCESS PRIORITY ON THIS NODES ARE SET TO PROCESS NOT INHERIT
	# Quit game
	print("quit clicked")
	get_tree().paused = false #need to unpause game over screen to continue this command
	get_tree().quit()


func _on_Restart_pressed(): # MAKE SURE PROCESS PRIORITY ON THIS NODES ARE SET TO PROCESS NOT INHERIT
	# Restart game
	print("restart clicked")
	get_tree().paused = false #need to unpause game over screen to continue this command
	get_tree().change_scene("res://scenes/Level.tscn")


#Funtions Used in Area text Display ############################################
func _on_Area1_body_entered(body):
	hide_pop()

	if body != null:
		if body.name == "player":
			display_area1.popup()
			yield(get_tree().create_timer(1.5), "timeout")
			hide_pop()


func _on_Area2_body_entered(body):
	hide_pop()
	
	if body != null:
		if body.name == "player":
			display_area2.popup()
			yield(get_tree().create_timer(1.5), "timeout")
			hide_pop()


func _on_Area3_body_entered(body):
	hide_pop()
	
	if body != null:
		if body.name == "player":
			display_area3.popup()
			yield(get_tree().create_timer(1.5), "timeout")
			hide_pop()


func _on_Area4_body_entered(body):
	hide_pop()
	
	if body != null:
		if body.name == "player":
			display_area4.popup()
			yield(get_tree().create_timer(1.5), "timeout")
			hide_pop()
			emit_signal("player_in_area_4", true)


###############################################################################
#Funtion to hide the Area Text when ever triggered 
func hide_pop():
	if get_node("Area1 Display").is_visible():
		get_node("Area1 Display").hide()
	elif get_node("Area2 Display").is_visible():
		get_node("Area2 Display").hide()
	elif get_node("Area3 Display").is_visible():
		get_node("Area3 Display").hide()
	elif get_node("Area4 Display").is_visible():
		get_node("Area4 Display").hide()

###############################################################################
# Winning the game!
func wingame():
	print("victory screen")
	victory_screen.show()
	get_tree().paused = true #pauses game
	score_board.hide()


func _on_Background_victory():
	#print("received victory")
	wingame()


func _on_Victory_Quit_pressed():
	# Quit game
	get_tree().paused = false #need to unpause game over screen to continue this command
	#print("quit clicked")
	get_tree().quit()


func _on_Victory_Restart_pressed():
	# Restart game
	get_tree().paused = false #need to unpause game over screen to continue this command
	#print("restart clicked")
	get_tree().change_scene("res://scenes/levelTest/levelTest.tscn")
