extends "res://characters/enemies/Enemy.gd"

# boss stats
var health = 500
var health_max = 500
var health_regeneration = 5

# Node references
var player
onready var bossgui = get_tree().root.get_node("Main/Background/player/GUI/boss_hp")
onready var healthbar = get_tree().root.get_node("Main/Background/player/GUI/boss_hp/health")
onready var healthbarnumber = get_tree().root.get_node("Main/Background/player/GUI/boss_hp/health/value")

# Random number generator
var rng = RandomNumberGenerator.new()

# Movement variables
export var speed = 425
var direction : Vector2
var last_direction = Vector2(0, 1)
var bounce_countdown = 0

# Attack variables
var attack_damage = 5 #rework meelee dmg? to like medium 20-30 ish
var attack_cooldown_time = 2000
var next_attack_time = 0

# Fireball variables
#var amount_of_fireballs = 3
var fireball_damage = 5
var next_fireball_time = 0
var fireball_cooldown = 10
var fireball_scene = preload("res://characters/enemies/boss/projectile/fireball.tscn")

# Animation variables
var other_animation_playing = false

# Minimap variables
var mm_icon = "boss"

# boss Signals
signal spawn
signal movement
signal attacking
signal detected_player
signal death

#-------------------------------------------INITIALIZATION FUNCTIONS-------------------------------------------
# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node("../player") #in the default code
	hp_init() #initialize boss healthbar GUI
	#player = get_node("../player") # ok for single instance
	#player = get_node("..../player") #reference for spawner use
	
	rng.randomize()

#delta is frames passed
func _process(delta):
	#base health regen
	health = min(health + health_regeneration * delta, health_max)
	#print(health)
	
	#update boss healthbar
	update_bosshp()
	
	# Check if boss can attack
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
			#print("next_attack_time", next_attack_time)
			#print("done")
			
#		else:
#			print("fail1")
#	else:
#			print("fail2")
	
func hp_init():
	bossgui.hide()
	healthbar.max_value = health_max
	healthbar.value = health

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
		bossgui.hide()
		$AnimatedSprite.play("death")
		emit_signal("death")
		$DIE.play()
		
func update_bosshp():
	var player_relative_position = player.position - position
	
	#show healthbar if player is close
	if player_relative_position.length() <= 1600:
		bossgui.show()
	else:
		bossgui.hide()
	
	#update healthbar gui
	healthbar.value = health
	healthbarnumber.text = str(round((health / health_max) * 100), "%")
	


#-------------------------------------------AI/MOVEMENT FUNCTIONS-------------------------------------------
func _on_Timer_timeout():
	# Calculate the position of the player relative to the boss
	var player_relative_position = player.position - position
	emit_signal("detected_player", player_relative_position.length()) #transmitting signal with how close the player is, bigger number means enemy is further away
	#print("pos: ", player_relative_position, " player.position: ", player.position, "position: ", position)
	#print(player_relative_position.length())
	#print("fireball cooldown: ", fireball_cooldown)
	fireball_cooldown-=1
	
	#add particle effects as the boss is charging up to shoot fireballs
	if(fireball_cooldown <= 20):#here we are repurposing the fireball with no speed just so it makes the particles
		var num_fireballs
		if fireball_cooldown <= 20:
			num_fireballs = 2
		if fireball_cooldown <= 10:
			num_fireballs = 5
		elif fireball_cooldown <= 5: #more particles if we get closer to big cast
			num_fireballs = 10
	
		# Create fireballs
		for i in range(num_fireballs):
			#print("instancing a fireball")
			var fireball = fireball_scene.instance()
			#add_child(fireball)
			fireball.attack_damage = 0
			fireball.direction = (player.position - position).normalized() #towards player
			fireball.position = position + Vector2(rng.randf_range(-200, 200), rng.randf_range(-200, 200)) + last_direction.normalized() * 8 
			# spawn at a random position up at the boss
			fireball.explodeHelper()
			
			fireball.speed = 0
			
			get_node("../").add_child(fireball)

	if player_relative_position.length() <= 500:
		# If player is near, don't move but turn toward it
		direction = Vector2.ZERO
		last_direction = player_relative_position.normalized()
		#possibly add attack cooldown here?
		#print("near")
		
	##based on a certain distance, call fireball function
	elif player_relative_position.length() <= 800 and fireball_cooldown <= 0:
		shootFireballs()
		fireball_cooldown = 50
		
	elif player_relative_position.length() <= 900 and bounce_countdown == 0:
		# If player is within range, move toward it
		#print("in range!")
		direction = player_relative_position.normalized()
		
	
	elif bounce_countdown == 0:
		# If player is too far, randomly decide whether to stand still or where to move
		#print("toofar!")
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
	
	# Animate boss based on direction
	if not other_animation_playing:
		animates_monster(direction)
		emit_signal("movement")
		
	# Turn RayCast2D toward movement direction
	if direction != Vector2.ZERO:
		$RayCast2D.cast_to = direction.normalized() * 50


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


func _on_AnimatedSprite_frame_changed():
	if $AnimatedSprite.animation.ends_with("attack") and  $AnimatedSprite.frame == 5: #modify frames 1-4 to be flash and the fifth hurts the player
		var target = $RayCast2D.get_collider()
		if target != null and target.name == "player" and player.health > 0:
			player.hit(attack_damage)
			emit_signal("attacking")
			$LAND.play()
		
			
func shootFireballs():
	#spawn 1-3 fireballs, they will go in player's last position + or - 100 in precision (trying to predict), after 5s they despawn
	var num_fireballs = rng.randi_range(2, 5)
	#signal fireballs fired?
	#print('instancing numfireballs', num_fireballs)
	# Create fireballs
	for i in range(num_fireballs):
		#print("instancing a fireball")
		var fireball = fireball_scene.instance()
		#add_child(fireball)
		fireball.attack_damage = rng.randi_range(20, 40) #random amt of damage
		fireball.direction = (player.position - position).normalized() #towards player
		fireball.position = position + Vector2(rng.randf_range(-200, 200), rng.randf_range(-200, 200)) + last_direction.normalized() * 8 
		# spawn at arandom position up at the boss
		
		fireball.speed = 600
		
		get_tree().root.get_node("Main/Background").add_child(fireball)
		#emit_signal("spawning_enemies", ballbot_count) #returns signal with amt of enemies
		$LASERS.play()
