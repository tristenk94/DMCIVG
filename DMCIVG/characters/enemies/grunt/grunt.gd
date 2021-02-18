extends KinematicBody2D

export(Resource) var attackSprite #i dont think this is correct
export(Resource) var idleSprite #i dont think this is correct

func _ready():
	$AnimationPlayer.play("idle")
	idleSprite.show()
	attackSprite.hide()
	# Replace with function body.

func _process(_delta):
	if Input.is_action_pressed("ui_right"):
		attackSprite.show()
		idleSprite.hide()
		#if sprite collides with player, player reduces health
		$AnimationPlayer.play("attack")
	else:
		$AnimationPlayer.play("idle")
		idleSprite.show()
		attackSprite.hide()
		
	print($AnimationPlayer.get_current_node())


#need an enemy taking damage function
