extends Area2D

onready var sprite : Sprite = $Sprite #reference to the sprite in case we need to do something with it

var collected = false #mark if key is collected

var door_association

#func _ready():
#	print("key loaded!!")
#

func _on_key_body_entered(body: KinematicBody2D):
	#print("body entered: ", body)
	if body != null:
		if not body.name.find("player") >= 0:
			return
		collected = true #collect the key if player touched it
	#get_tree().queue_delete(self)
		#$Sprite.modulate = Color(0.56, 0.93, 0.56, 1) # light green, it is solved!
