extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var bar_red = preload("res://gui/redhp.png")
var bar_green = preload("res://gui/greenhp.png")
var bar_yellow = preload("res://gui/yellowhp.png")

onready var healthbar = $HealthBar

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	if get_parent() and get_parent().get("health_max"):
		healthbar.max_value = get_parent().health_max


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#prevent bar from rotating
	global_rotation = 0

#function to call when unit health changes
func update_healthbar(value):
	healthbar.texture_progress = bar_green
	if value < healthbar.max_value * 0.7:
		healthbar.texture_progress = bar_yellow
	if value < healthbar.max_value * 0.35:
		healthbar.texture_progress = bar_red
	if value < healthbar.max_value:
		show()
	healthbar.value = value
