extends StaticBody2D

onready var switch_sprite = $AnimatedSprite

#var switch_solved = false #switch isnt in right state

var current_color #the current value of the switch
var target_color #var to hold if switch is in right state, can be initializad

var lamp_association

##automatically set switch to red on instance
#func _ready():
#	switchRed()
	
# fuct to change color displayed to red
func switchRed():
	switch_sprite.play("red")
	current_color = "red"

# fuct to change color displayed to green
func switchGreen():
	switch_sprite.play("green")
	current_color = "green"
	
# fuct to change color displayed to yellow
func switchYellow():
	switch_sprite.play("yellow")
	current_color = "yellow"
