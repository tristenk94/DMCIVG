extends Area2D

var tilemap
var speed = 800
var direction : Vector2
var attack_damage

# Called when the node enters the scene tree for the first time.
func _ready():
	#tilemap = get_tree().root.get_node("Root/TileMap")
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var dir = get_animation_direction(direction)
	if(dir == "left"): 
		get_node( "AnimatedSprite" ).set_flip_h( true )
	elif(dir == "right"):
		get_node( "AnimatedSprite" ).set_flip_h( false )
	
	position = position + speed * delta * direction


func _on_fireball_body_entered(body):
	# Ignore collision with boss
	if body.name == "boss":
		return
#
#	if body.name == "TileMap":
#		var cell_coord = tilemap.world_to_map(position)
#		var cell_type_id = tilemap.get_cellv(cell_coord)
#		if cell_type_id == tilemap.tile_set.find_tile_by_name("Water"):
#			return
	
	# If the fireball hit a Skeleton, call the hit() function
	if body.name.find("player") >= 0:
		body.hit(attack_damage)
	
	# Stop the movement and explode
	direction = Vector2.ZERO
	$AnimatedSprite.play("explode")


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "explode":
		get_tree().queue_delete(self)


func _on_Timer_timeout():
	$AnimatedSprite.play("explode")
	
func explodeHelper(): #helper func in case you want to explode :), used with boss
	$AnimatedSprite.play("explode")

func get_animation_direction(direction: Vector2):
	var norm_direction = direction.normalized()
	if norm_direction.y >= 0.707:
		return "down"
	elif norm_direction.y <= -0.707:
		return "up"
	elif norm_direction.x <= -0.707:
		return "left"
	elif norm_direction.x >= 0.707:
		return "right"
	return "down"
	
