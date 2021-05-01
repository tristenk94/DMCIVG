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

onready var game_over_screen = get_node("Game Over Screen") #not ready for use yet
onready var defeated_label = get_node("Game Over Screen")
onready var game_over = get_node("Game Over Screen")

# Called when the node enters the scene tree for the first time.
func _ready():
	background_scene = get_tree().root.get_node("Background")
	player = get_tree().root.get_node("Background/player")
	playerhealth.max_value = player.health_max
	playerhealth.value = player.health
	


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
	
#	if playerhealth.value == 0: #end the game if player loses all health
#		end_game()

func end_game(): #displays game over scren, shows option to quit or restart along with score
	pass

func update_scoreboard():
	var to_update = background_scene.score
	score_board.text = str(to_update) #removed the other display, "Score: " + str(to_update)
