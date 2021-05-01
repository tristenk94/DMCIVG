extends Area2D

onready var sprite : Sprite = $Sprite #reference to the sprite in case we need to do something with it

var puzzle_completed = false

#func _ready():
#	print("puzzle loaded")
#

func _on_pit_body_entered(body: RigidBody2D):
	print("body entered: ", body)
	if body != null:
		if not body.name.find("box") >= 0:
			return
		puzzle_completed = true
		$Sprite.modulate = Color(0.56, 0.93, 0.56, 1) # light green, it is solved!



func _on_pit_body_exited(body: RigidBody2D):
	print("body exited: ", body)
	if body != null:
		if not body.name.find("box") >= 0:
			return
		puzzle_completed = false
		$Sprite.modulate = Color(1, 1, 1) # reset to default
