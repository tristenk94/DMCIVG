extends KinematicBody2D

# Skeleton stats
var health = 100
var health_max = 100
var health_regeneration = 1

# Node references
var player

# Random number generator
var rng = RandomNumberGenerator.new()

# Movement variables
export var speed = 425
var direction : Vector2
var last_direction = Vector2(0, 1)
var bounce_countdown = 0

# Attack variables
var attack_damage = 10
var attack_cooldown_time = 1500
var next_attack_time = 0

# Animation variables
var other_animation_playing = false

# Skeleton Signals
signal spawn
signal movement
signal attacking
signal detected_player
signal death

#-------------------------------------------INITIALIZATION FUNCTIONS-------------------------------------------
# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().root.get_node("Background/player") #in the default code
	#player = get_node("../player") # ok for single instance
	#player = get_node("..../player") #reference for spawner use
	
	rng.randomize()


#delta is frames passed
func _process(delta):
	#base health regen
	health = min(health + health_regeneration * delta, health_max)
	#print(health)
	
	# Check if Skeleton can attack
	var now = OS.get_ticks_msec()
	if now >= next_attack_time:
		# What's the target?
		var target = $RayCast2D.get_collider()
		#print(target)
		if target != null and target.name == "player" and player.health > 0: #DETECTED TO STATE MACHINE
			# Play attack animation
			other_animation_playing = true
			
			#print("detected")
			
			var dir = get_animation_direction(last_direction)
			if(dir == "left"): 
				get_node( "AnimatedSprite" ).set_flip_h( true )
			elif(dir == "right"):
				get_node( "AnimatedSprite" ).set_flip_h( false )
				
			#var animation = get_animation_direction(last_direction) + "_attack"
			$AnimatedSprite.play("attack")
			# Add cooldown time to current time
			next_attack_time = now + attack_cooldown_time


func hit(damage):
	health -= damage
	#print("hit called")
	if health > 0:
		$AnimationPlayer.play("hit")
	else:
		$Timer.stop()
		direction = Vector2.ZERO
		set_process(false)
		other_animation_playing = true
		$AnimatedSprite.play("death")
		emit_signal("death")

#-------------------------------------------AI/MOVEMENT FUNCTIONS-------------------------------------------
func _on_Timer_timeout():
	# Calculate the position of the player relative to the skeleton
	var player_relative_position = player.position - position
	emit_signal("detected_player", player_relative_position.length()) #transmitting signal with how close the player is, bigger number means enemy is further away

	if player_relative_position.length() <= 16:
		# If player is near, don't move but turn toward it
		direction = Vector2.ZERO
		last_direction = player_relative_position.normalized()
		
	elif player_relative_position.length() <= 100 and bounce_countdown == 0:
		# If player is within range, move toward it
		direction = player_relative_position.normalized()
		
		
	elif bounce_countdown == 0:
		# If player is too far, randomly decide whether to stand still or where to move
		var random_number = rng.randf()
		if random_number < 0.05:
			direction = Vector2.ZERO
		elif random_number < 0.1:
			direction = Vector2.DOWN.rotated(rng.randf() * 2 * PI)

	# Update bounce countdown
	if bounce_countdown > 0:
		bounce_countdown = bounce_countdown - 1


func _physics_process(delta):
	var movement = direction * speed * delta

	var collision = move_and_collide(movement)

	if collision != null and collision.collider.name != "player":
		direction = direction.rotated(rng.randf_range(PI/4, PI/2))
		bounce_countdown = rng.randi_range(2, 5)
		#print("true", direction)
	#else : 
		#print("nope")
	
	# Animate skeleton based on direction
	if not other_animation_playing:
		animates_monster(direction)
		emit_signal("movement")
		
	# Turn RayCast2D toward movement direction
	if direction != Vector2.ZERO:
		$RayCast2D.cast_to = direction.normalized() * 40


#-------------------------------------------ANIMATION FUNCTIONS-------------------------------------------
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
	

func animates_monster(direction: Vector2):
	var dir = get_animation_direction(last_direction)
	if(dir == "left"): 
		get_node( "AnimatedSprite" ).set_flip_h( true )
	elif(dir == "right"):
		get_node( "AnimatedSprite" ).set_flip_h( false )
		
	if direction != Vector2.ZERO:
		last_direction = direction
		
		# Choose walk animation based on movement direction, add anims for different directions?
			#im 99% sure we can just translate it, just use the same for now
		#var animation = get_animation_direction(last_direction) + "_walk"
		
		var animation = "walk"
		
		# Play the walk animation
		$AnimatedSprite.play(animation)
		#print($AnimatedSprite.is_flipped_h())
		#print("im walking here", direction)
	else:
		# Choose idle animation based on last movement direction and play it
		#var animation = get_animation_direction(last_direction) + "_idle"
		
		#same reasoning as above
		var animation = "idle"
		$AnimatedSprite.play(animation)
		#print($AnimatedSprite.is_flipped_h())
		#print("im standing here", direction)

func arise():
	other_animation_playing = true
	$AnimatedSprite.play("spawn")
	emit_signal("spawn")

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "spawn": 
		$AnimatedSprite.animation = "idle"
		$Timer.start()
	elif $AnimatedSprite.animation == "death": 
		get_tree().queue_delete(self)
	other_animation_playing = false


func _on_AnimatedSprite_frame_changed(): #enemy attacking player
	if $AnimatedSprite.animation.ends_with("attack") and $AnimatedSprite.frame == 7:
		var target = $RayCast2D.get_collider()
		if target != null and target.name == "player" and player.health > 0:
			player.hit(attack_damage)
			emit_signal("attacking")
