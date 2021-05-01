extends Area2D

onready var door_sprite = $AnimatedSprite

#automatically lock the door when this locked sprite is used
func _ready():
	lock()
	
#helper funct to lock the door
func lock():
	door_sprite.play("lock")
	$StaticBody2D/CollisionShape2D.disabled = false #renable collision

#helper funct to unlock the door
func unlock():
	door_sprite.play("unlock")
	$StaticBody2D/CollisionShape2D.disabled = true #disable collision
