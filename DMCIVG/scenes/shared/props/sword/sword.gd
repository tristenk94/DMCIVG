extends Area2D

onready var sprite : Sprite = $Sprite #reference to the sprite in case we need to do something with it

var collected = false 

#this is for the sword item
var sword


func _on_sword_body_entered(body: KinematicBody2D):
	print("body entered: ", body)
	if body != null:
		if not body.name.find("player") >= 0:
			return
	collected = true 


#increment the damage
#stab_attack_damage
#slash_attack_damage
