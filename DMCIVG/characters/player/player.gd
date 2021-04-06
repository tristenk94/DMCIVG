extends KinematicBody2D

# Player movement speed
export var speed = 400

# Player status helpers
var attack_playing = false
var last_direction = "left"

# Player stats
var health = 100
var health_max = 100
var health_regeneration = 1

# Attack variable
#general vars controlling attacking
var attack_cooldown_time = 1000 #this equals 1s cooldown
var next_attack_time = 0

#primary attacks are stab, (quick low damage attack)
#then if pressed again, we do a slash (heavier high damage attack)

# Stab
var isStabbing = false
var stab_attack_cooldown_time = 500 #this equals .5s cooldown
var stab_next_attack_time = 0
var stab_attack_damage = 20

# Slash
var isSlashing = false
var slash_attack_cooldown_time = 1000 #this equals 1s cooldown #not needed?
var slash_next_attack_time = 0 #not needed?
var slash_attack_damage = 30

# Charge Shot
#you become immobile, but do extreme damage
var isCharging = false
var charge_attack_cooldown_time = 10000 #this equals 10s cooldown
var charge_next_attack_time = 0
var charge_attack_damage = 100
var charges_remaining = 1


# Player Signals
signal player_stats_changed
signal health_amount
signal movement
signal attacking
signal death

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
	
	if attack_playing: #adjust movement speed based on attacking
		#emit signal player attacking
		emit_signal("attacking")
		if isStabbing:
			movement = 0.95 * movement
			#print("isStabbing")
		elif isSlashing:
			movement = 0.7 * movement
			#print("isSlashing")
		elif isCharging: 
			movement = 0 * movement
			#print("isCharging")

	move_and_collide(movement) #move
	
	# Animate player based on direction
	if not attack_playing:
		animates_player(direction)
		#emit signal movement
		emit_signal("movement")
		
	
		
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
	if event.is_action_pressed("primary_attack"):
		#print("attack pressed", " stabbing: ", isStabbing, " slashing: ",isSlashing)
		# Check if player can attack
		var attack_damage
		var now = OS.get_ticks_msec()
		if now >= stab_next_attack_time:
			
#			# Play attack animation
			attack_playing = true #trying to find a case when we are stabbing and the time right after it
			if isStabbing == true:
				#print("stabbing is true")
				isSlashing = true
				$pivot/AnimatedSprite.play("slash")
				isStabbing = false
				attack_damage = slash_attack_damage
				#slash_next_attack_time = now + stab_next_attack_time
			else:
				#print("stabbing is false")
				isStabbing = true
				attack_damage = stab_attack_damage
				$pivot/AnimatedSprite.play("stab")
				
			if last_direction == "left": 
				get_node( "pivot/AnimatedSprite" ).set_flip_h( true )
			elif last_direction == "right":
				get_node( "pivot/AnimatedSprite" ).set_flip_h( false )
				
			# What's the target?, performing this after we figure out what attack we are doing
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
				elif target.name.find("boss") >= 0: #add check for pillars or shield down! here
					# boss hit!
					target.hit(attack_damage)
					
			
			# Add cooldown time to current time
			stab_next_attack_time = now + stab_attack_cooldown_time

		
	elif event.is_action_pressed("secondary_attack"): #if we have secondary attack + charge left, shoot the super laser
		print("secondary attack pressed")
		# Check if player can attack
		var now = OS.get_ticks_msec()
		if charges_remaining >= 1 && now >= next_attack_time:	
			# What's the target?,, calculate target ad do the charge damage since we know this attack is a charge
			print("charges left : ", charges_remaining)
			var target = $RayCast2D.get_collider()
			#print(target.name)
			if target != null: #seperated into if's in case we want to send specific sfx or states to sequencer
				if target.name.find("skeleton") >= 0:
					# Skeleton hit!
					target.hit(charge_attack_damage)
				elif target.name.find("grunt") >= 0:
					# Grunt hit!
					target.hit(charge_attack_damage)
				elif target.name.find("merchant") >= 0:
					# Merchant hit!
					target.hit(charge_attack_damage)
				elif target.name.find("ballbot") >= 0:
					# Ballbot hit!
					target.hit(charge_attack_damage)
				elif target.name.find("boss") >= 0: #add check for pillars or shield down! here
					# boss hit!
					target.hit(charge_attack_damage)
					
			# Play attack animation
			isCharging = true
			attack_playing = true
			charges_remaining -= 1
				
			if last_direction == "left": 
				get_node( "pivot/AnimatedSprite" ).set_flip_h( true )
			elif last_direction == "right":
				get_node( "pivot/AnimatedSprite" ).set_flip_h( false )
				
			$pivot/AnimatedSprite.play("laser")
			# Add cooldown time to current time
			charge_next_attack_time = now + charge_attack_cooldown_time
	

func hit(damage):
	var old_health = health #temp var to hold new to old in case info is needed
	health -= damage
	emit_signal("player_stats_changed", self) #connect this to health bar
	if health <= 0:
		#emit signal death
		emit_signal("death")
	else:
		$AnimationPlayer.play("hit")
		#emit signal getting hit, show health amount
		emit_signal("health_amount", old_health, health)

func _on_AnimatedSprite_animation_finished():
	#print("finish attack anim")
	attack_playing = false
	isCharging = false
	isStabbing = false
	isSlashing = false

func _ready(): #connect this to health bar
	emit_signal("player_stats_changed", self)
	
func _process(delta):
	
	# Regenerates health
	var new_health = min(health + health_regeneration * delta, health_max)
	if new_health != health:
		health = new_health
		emit_signal("player_stats_changed", self) #connect this to health bar, send strength to fsm?, 
		#possibly dupe state of health_amount
