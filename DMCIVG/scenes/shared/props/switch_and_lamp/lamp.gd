extends StaticBody2D

onready var lamp_sprite = $AnimatedSprite

var lamp_solved = false #lamp isnt in right state

#var current_color #the current value of the lamp
#var target_color #var to hold if lamp is in right state, can be initializad

##automatically set lamp to red on instance
#func _ready():
#	lampRed()
	
# fuct to change color displayed to red
func lampRed():
	lamp_sprite.play("red")
#	current_color = "red"

# fuct to change color displayed to green
func lampGreen():
	lamp_sprite.play("green")
#	current_color = "green"
	
# fuct to change color displayed to yellow
func lampYellow():
	lamp_sprite.play("yellow")
#	current_color = "yellow"
