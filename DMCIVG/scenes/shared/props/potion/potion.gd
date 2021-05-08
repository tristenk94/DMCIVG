extends Area2D

onready var sprite = $AnimatedSprite #reference to the sprite in case we need to do something with it

var collected = false 

#this is for potion type, health or charge
var potion_type
var potion_value = 20

func _ready():
	self.connect('health_potion',get_tree().root.get_node("Main/Background/player"),'_on_health_potion')

func _on_Potion_body_entered(body: KinematicBody2D):
	#print("body entered: ", body)
	if body != null:
		if not body.name.find("player") >= 0:
			return
	collected = true

#switching potion type
func switch_health():
	sprite.play("health")
	potion_type = 0

func switch_charge():
	sprite.play("charge")
	potion_type = 1

func switch_speed():
	sprite.play("speed")
	potion_type = 2
