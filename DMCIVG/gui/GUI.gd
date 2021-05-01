extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var bar_red = preload("res://gui/redhp.png")
var bar_green = preload("res://gui/greenhp.png")
var bar_yellow = preload("res://gui/yellowhp.png")
var player

onready var playerhealth = get_node("Health/Bar")

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().root.get_node("Background/player")
	playerhealth.max_value = player.health_max
	playerhealth.value = player.health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	update_healthbar()
	
func update_healthbar():
	var new_hp = player.health
	if new_hp < playerhealth.max_value * 0.5:
		playerhealth.texture_progress = bar_yellow
	if new_hp < playerhealth.max_value * 0.15:
		playerhealth.texture_progress = bar_red
	playerhealth.value = new_hp
