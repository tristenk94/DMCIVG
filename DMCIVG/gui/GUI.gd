extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var bar_red = preload("res://gui/redhp.png")
var bar_green = preload("res://gui/greenhp.png")
var bar_yellow = preload("res://gui/yellowhp.png")

#references to the game
var player
var background_scene

onready var playerhealth = get_node("Health/Bar")
onready var score_board = get_node("Score Area/Score Label")

#game over menus
onready var game_over_screen = get_node("Game Over Pop-Up") #not ready for use yet

#Area Display popups 
onready var display_area1 = get_node("Area1 Display")
onready var display_area2 = get_node("Area2 Display")
onready var display_area3 = get_node("Area3 Display")

var game_over_selected_menu

# Called when the node enters the scene tree for the first time.
func _ready():
	background_scene = get_tree().root.get_node("Main/Background")
	player = get_tree().root.get_node("Main/Background/player")
	playerhealth.max_value = player.health_max
	playerhealth.value = player.health
	get_tree().paused = false 
	
	#work around so that the area 1 text actually displays 
	#should only run once
	yield(get_tree().create_timer(.5), "timeout")
	display_area1.popup()
	yield(get_tree().create_timer(2.5), "timeout")
	hide_pop()#just in case we have an outlier in pausing/restarting game, unpause the game
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	update_healthbar()
	update_scoreboard()
	
func update_healthbar():
	var new_hp = player.health
	if new_hp < playerhealth.max_value * 0.5:
		playerhealth.texture_progress = bar_yellow
	if new_hp < playerhealth.max_value * 0.15:
		playerhealth.texture_progress = bar_red
	playerhealth.value = new_hp
	
	if playerhealth.value == 0: #end the game if player loses all health
		end_game()


func end_game(): #displays game over scren, shows option to quit or restart along with score
	#_on_Game_Over_PopUp_draw() #dont need to use the pause function
	game_over_screen.popup()
	get_tree().paused = true #pasuses game

func update_scoreboard():
	var to_update = background_scene.score
	score_board.text = str(to_update) #removed the other display, "Score: " + str(to_update)

func _on_Quit__pressed(): # MAKE SURE PROCESS PRIORITY ON THIS NODES ARE SET TO PROCESS NOT INHERIT
	# Quit game
	#print("quit clicked")
	get_tree().paused = false #need to unpause game over screen to continue this command
	get_tree().quit()

func _on_Restart_pressed(): # MAKE SURE PROCESS PRIORITY ON THIS NODES ARE SET TO PROCESS NOT INHERIT
	# Restart game
	#print("restart clicked")
	get_tree().paused = false #need to unpause game over screen to continue this command
	get_tree().change_scene("res://scenes/levelTest/levelTest.tscn")


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

###############################################################################
#Funtion to hide the Area Text when ever triggered 
func hide_pop():
	if get_node("Area1 Display").is_visible():
		get_node("Area1 Display").hide()
	elif get_node("Area2 Display").is_visible():
		get_node("Area2 Display").hide()
	elif get_node("Area3 Display").is_visible():
		get_node("Area3 Display").hide()
