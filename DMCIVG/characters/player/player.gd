extends KinematicBody2D

# Player movement speed
export var speed = 400

var attack_playing = false
var last_direction = "left"

# Player stats
var health = 100
var health_max = 100
var health_regeneration = 1

# Attack variables
var attack_cooldown_time = 1000 #this equals 5s cooldown
var next_attack_time = 0
var attack_damage = 50

func _physics_process(delta):
	# Get player input
	var direction: Vector2
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	# If input is digital, normalize it for diagonal movement
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized()
	
	# Apply movement
	var movement = speed * direction * delta
	move_and_collide(movement)
	
	# Animate player based on direction
	if not attack_playing:
		animates_player(direction)
		#emit signal movement
		
	if attack_playing:
		movement = 0.3 * movement
		#emit signal player attacking
		
	# Turn RayCast2D toward movement direction
	if direction != Vector2.ZERO:
		$RayCast2D.cast_to = direction.normalized() * 30
	
	
func animates_player(direction: Vector2):
	if direction != Vector2.ZERO:
		#choose direction of sprite 
		var norm_direction = direction.normalized()
		if norm_direction.x <= -0.707:
			get_node( "pivot/AnimatedSprite" ).set_flip_h( true )
			last_direction = "left"
		elif norm_direction.x >= 0.707:
			get_node( "pivot/AnimatedSprite" ).set_flip_h( false )
			last_direction = "right"
			
		# Play walk animation
		$pivot/AnimatedSprite.play("run")
	else:
		# Play idle animation
		$pivot/AnimatedSprite.play("default")
		
func _input(event):
	if event.is_action_pressed("attack"):
		#print("attack pressed")
		# Check if player can attack
		var now = OS.get_ticks_msec()
		if now >= next_attack_time:
			# What's the target?
			var target = $RayCast2D.get_collider()
			#print(target.name)
			if target != null: #seperated into if's in case we want to send specific sfx or states to sequencer
				if target.name.find("skeleton") >= 0:
					# Skeleton hit!
					target.hit(attack_damage)
				elif target.name.find("grunt") >= 0:
					# Grunt hit!
					target.hit(attack_damage)
				elif target.name.find("merchant") >= 0:
					# Merchant hit!
					target.hit(attack_damage)
				elif target.name.find("ballbot") >= 0:
					# Ballbot hit!
					target.hit(attack_damage)
#				elif target.name.find("KinematicBody2D") >= 0:
#					# Ballbot hit!
#					target.hit(attack_damage)
			# Play attack animation
			attack_playing = true

			if last_direction == "left": 
				get_node( "pivot/AnimatedSprite" ).set_flip_h( true )
			elif last_direction == "right":
				get_node( "pivot/AnimatedSprite" ).set_flip_h( false )

			$pivot/AnimatedSprite.play("attack")
		
			# Add cooldown time to current time
			next_attack_time = now + attack_cooldown_time
		
	

func hit(damage):
	health -= damage
	#emit_signal("player_stats_changed", self) #connect this to health bar
	if health <= 0:
		pass
		#emit signal death
	else:
		$AnimationPlayer.play("hit")
		#emit signal ouch

func _on_AnimatedSprite_animation_finished():
	attack_playing = false

#func _ready(): #connect this to health bar
#	emit_signal("player_stats_changed", self)
	
func _process(delta):
	
	# Regenerates health
	var new_health = min(health + health_regeneration * delta, health_max)
	if new_health != health:
		health = new_health
		#emit_signal("player_stats_changed", self) #connect this to health bar, send strength to fsm?
