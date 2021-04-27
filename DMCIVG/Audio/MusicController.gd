# --- Music Controller ---
extends Node
var socket

## --- Pure Data global variables
var masterVol = 100 setget setMasterVol
var bpm = MIN_BPM setget setBPM
var scaleSelect = 1 # 0 - 4
var pitch = 0 setget setPitch, getPitch
var swingPercent = 50 setget setSwingPercent # 0 - 100%
var triggerProb = 1 # 0 - 4; probability that beat occurs (rhythm prob); select probability array 
var loopDensity = 50 # 0 - 100
var loopLen= 16 # 16 - 32; number of beats per measure
var noteProb1 = 50 # 0 - 100; probability that 1, 2, or 3 notes played simultaneously
var noteProb2 = 50
var noteProb3 = 50

# select array of probabilities that note in scale will be played during measure 
var noteProbArr = 0 # 0 -> 2, --> increasing probability 

# select array containing instruments' note length values 
var noteLenArr = 0 # 0 -> 3, --> decreasing note length 

# select array of instruments' volumes
var volArr = 0 # 0 -> 2, --> increasing volume

var bpmSelect = 0 setget setBPMSelect # 1 = change bpm, 0 = don't change bpm.

## -- Global constants
enum {LOW, MEDIUM, HIGH}
enum NoteLength {LONGEST, LONG, SHORT, SHORTEST} # tension/staccato
enum Scales {HANG, HANG_DEEP, MAJOR_PENT, MINOR_PENT, PHRYGIAN, PHRYG_DOM, PERSIAN, LYDIAN, MIXOLYDIAN}
enum TriggerProb {MIN_TENSION, LESS_TENSION, NORMAL_TENSION, MORE_TENSION, MAX_TENSION}

const MAX_MASTER_VOLUME = 108 # since volArr values never exceeds 0.5
const MIN_MASTER_VOLUME = 95
const MAX_BPM = 215
const MIN_BPM = 80
const MAX_PITCH = 4
const MIN_PITCH = -3
const DEFAULT_PITCH = 0
const DEFAULT_LOOPLENGTH = 16 # 4 quarters per measure
const TRIPLE_TIME_LOOPLENGTH = 12 # 3 quarters per measure
const MEDIAN_VALUE = 50

# Level object variables
var area1_visited = false 
var area2_visited = false 
var area3_visited = false 
var in_boss_room = false
var enemy_count = 0 setget setEnemyCount
var dangerZone_enemy_count = 0 setget setDangerZoneCount
var player

# Other variables
var rng = RandomNumberGenerator.new()
var format_message = "%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s;" # 15 parameters

## --- Functions
func sendMessage():
	var message = format_message % [masterVol, bpm, scaleSelect, pitch, swingPercent, triggerProb, loopDensity, 
		loopLen, noteProb1, noteProb2, noteProb3, noteProbArr, noteLenArr, volArr, bpmSelect]
	socket.put_data(message.to_ascii())
	# print(message)

func _ready():
	# Connect to Pure Data
	socket = StreamPeerTCP.new()
	print("connecting to Pure Data...")
	socket.connect_to_host("127.0.0.1", 4242)
	sendMessage()
	
	# Initialize variables
	player = get_node("../Background/player")



func setMessage(var0, var1, var2, var3, var4, var5, var6, var7, var8, var9, var10, var11, var12, var13, var14):
	masterVol = var0
	bpm = var1
	scaleSelect = var2
	pitch = var3
	swingPercent = var4
	triggerProb = var5
	loopDensity = var6
	loopLen = var7
	noteProb1 = var8
	noteProb2 = var9
	noteProb3 = var10
	noteProbArr = var11
	noteLenArr = var12
	volArr = var13
	bpmSelect = var14

# --------- Pure Data Setters ---------
func setMasterVol(new_masterVol):
	if new_masterVol >= MIN_MASTER_VOLUME && new_masterVol <= MAX_MASTER_VOLUME:
		masterVol = new_masterVol
	else: 
		print("master vol not valid.")

func setBPM(new_bpm):
	if new_bpm >= MIN_BPM && new_bpm <= MAX_BPM:
		bpm = new_bpm
	else: 
		print("bpm not valid.")

func setScale(new_scale):
	scaleSelect = new_scale

func setPitch(new_pitch):
	if new_pitch >= MIN_PITCH && new_pitch <= MAX_PITCH: 
		pitch = new_pitch
	else: 
		print("transpose pitch is not valid.")

func setSwingPercent(new_swing):
	if new_swing >= 0 && new_swing <= 100: 
		swingPercent = new_swing

func setTriggerProb(new_triggerProb):
	triggerProb = new_triggerProb

func setLoopDensity(new_density):
	loopDensity = new_density

func setLoopLen(new_len):
	loopLen = new_len

func setNoteProb(prob1, prob2, prob3):
	noteProb1 = prob1
	noteProb2 = prob2
	noteProb3 = prob3

func setNoteProbArr(new_arr):
	noteProbArr = new_arr

func setNoteLenArr(new_arr):
	noteLenArr = new_arr

func setVolArr(new_arr):
	volArr = new_arr
	
func setBPMSelect(set):
	if (set == 0 || set == 1):
		bpmSelect = set

# --------------------

## Other setters
# Enemy Count affects scale selection.
func setEnemyCount(increment):
	enemy_count += increment
	if enemy_count == 0: # 0 enemies detected
		# set instrument volumes (volArr)
		pass
	if enemy_count == 1: 
		pass
	if enemy_count == 2:
		pass
	if enemy_count >= 3:
		pass


func setDangerZoneCount(increment):
	dangerZone_enemy_count += increment

func setRandomScale():
	rng.randomize()
	setScale(rng.randi_range(Scales.HANG, Scales.MIXOLYDIAN))

# gradually increase bpm until threshold reached
func inc_bpm(limit):
	pass

# gradually increase volume until threshold reached
func inc_vol(limit): 
	pass

## Getters
func getPitch():
	return pitch


## --- Signals --- ##

## Main Screen
#	setMasterVol(100)
#	setBPM(90)
#	setScale(Scales.MINOR_PENT)
#	setPitch(-2)
#	setSwingPercent(10)
#	setTriggerProb(TriggerProb.LEAST_TENSION)
#	setLoopDensity(MEDIAN_VALUE)
#	setLoopLen(TRIPLE_TIME_LOOPLENGTH)
#	setNoteProb(10, 10, 10)
#	setNoteProbArr(LOW)
#	setNoteLenArr(NoteLength.LONGEST)
#	setVolArr(MEDIUM)
#	sendMessage()

## Pause Menu

## Game Over Menu

## Areas
func _on_Area1_body_entered(body):
	if body != null:
		if body.name == "player":
			print("Area1 entered.")
			setMasterVol(MAX_MASTER_VOLUME)
			setBPM(150)
			setScale(Scales.PHRYGIAN)
			if area1_visited == false:
				setPitch(DEFAULT_PITCH)
				area1_visited = true
			setSwingPercent(MEDIAN_VALUE)
			setTriggerProb(TriggerProb.NORMAL_TENSION)
			setLoopDensity(MEDIAN_VALUE)
			setLoopLen(DEFAULT_LOOPLENGTH)
			setNoteProb(10, 10, 10)
			setNoteProbArr(LOW)
			setNoteLenArr(NoteLength.LONGEST)
			setVolArr(MEDIUM)
			setBPMSelect(1) # IMPORTANT: Only change BPM for areas/menus (otherwise "stuttering" occurs often).
			sendMessage()
			setBPMSelect(0) # Remember to turn off BPM change


func _on_Area2_body_entered(body):
	if body != null:
		if body.name == "player":
			print("Area2 entered.")
			if area2_visited == false:
				area2_visited = true
			setMasterVol(MAX_MASTER_VOLUME)
			setBPM(180)
			setScale(Scales.PHRYG_DOM)
			#setPitch(DEFAULT_PITCH) # pitch is based on health
			setSwingPercent(MEDIAN_VALUE)
			setTriggerProb(TriggerProb.MORE_TENSION)
			setLoopDensity(MEDIAN_VALUE)
			setLoopLen(DEFAULT_LOOPLENGTH)
			setNoteProb(50, 50, 50)
			setNoteProbArr(MEDIUM)
			setNoteLenArr(NoteLength.LONGEST)
			setVolArr(MEDIUM)
			setBPMSelect(1)
			sendMessage()
			setBPMSelect(0) # Turn off BPM change


func _on_Area3_body_entered(body):
	in_boss_room = true
	if body != null:
		if body.name == "player":
			print("Area3 entered.")
			if area3_visited == false:
				area3_visited = true
			setMasterVol(MAX_MASTER_VOLUME)
			setBPM(MAX_BPM)
			setScale(Scales.PERSIAN)
			#setPitch(DEFAULT_PITCH) # pitch is based on health
			setSwingPercent(MEDIAN_VALUE)
			setTriggerProb(TriggerProb.MAX_TENSION)
			setLoopDensity(MEDIAN_VALUE)
			setLoopLen(DEFAULT_LOOPLENGTH)
			setNoteProb(70, 70, 80)
			setNoteProbArr(MEDIUM)
			setNoteLenArr(NoteLength.SHORT) # note length is always short/shortest in bossroom
			setVolArr(HIGH)
			setBPMSelect(1)
			sendMessage()
			setBPMSelect(0) # Turn off BPM change
			
func _on_Area3_body_exited(body):
	in_boss_room = false
	print("Area3 exited.")
	

## Health Levels 0 - 4 
#  80 <= health <= 100
func _on_100_Health_health_max():
	print("Health: 80 ~ 100.")
	# play sound effect 

#  50 <= health <= 79
func _on_79_Health_health_1():
	print("Health: 50 ~ 79.")
	setPitch(DEFAULT_PITCH + 1)
	sendMessage()

#  20 <= health <= 49
func _on_49_Health_health_2():
	print("Health: 20 ~ 49.")
	setPitch(DEFAULT_PITCH + 2)
	sendMessage()

# 1 <= health <= 19
func _on_19_Health_health_3():
	print("Health: 1 ~ 19.")
	setPitch(DEFAULT_PITCH + 3)
	sendMessage()

# 0 health
func _on_0__Health_health_min():
	print("Playing Game Over music...")
	setMasterVol(100)
	setBPM(100)
	setScale(Scales.MINOR_PENT)
	setPitch(-2)
	setSwingPercent(10)
	setTriggerProb(TriggerProb.LESS_TENSION)
	setLoopDensity(MEDIAN_VALUE)
	setLoopLen(DEFAULT_LOOPLENGTH)
	setNoteProb(10, 10, 10)
	setNoteProbArr(LOW)
	setNoteLenArr(NoteLength.LONGEST)
	setVolArr(MEDIUM)
	sendMessage()


## Threat Levels 0 - 4 
func _on_Threat_Level_0_threat_0():
	pass # Replace with function body.


func _on_Threat_Level_1_threat_1():
	pass # Replace with function body.


func _on_Threat_Level_2_threat_2():
	pass # Replace with function body.


func _on_Threat_Level_3_threat_3():
	pass # Replace with function body.


func _on_Threat_Level_4_threat_4():
	pass # Replace with function body.


func _on_PlayerDetectionArea_body_entered(body):
	if body.name == "boss":
		print("boss detected.")
		
	if body.name == "merchant":
		print("merchant detected.")
		
	if body.name != "player" && body.name != "merchant" && body.get_class() == "KinematicBody2D": # TODO: would be better to implement "Enemy" class
		setEnemyCount(1)
		sendMessage()
		print("%d enemy(s) detected." % enemy_count) # (debug statements)
		print("%s detected" % body.name)


func _on_PlayerDetectionArea_body_exited(body):
	if body.name == "boss":
		print("boss detected.")
		
	if body.name == "merchant":
		print("merchant detected.")
		
	if body.name != "player" && body.name != "merchant" && body.get_class() == "KinematicBody2D":
		setEnemyCount(-1)
		sendMessage()
		print("%d enemy(s) detected." % enemy_count)
		print("%s exited" % body.name)



func _on_DangerZone1_body_entered(body):
	if body.name != "player" && body.name != "merchant" && body.get_class() == "KinematicBody2D":
		setDangerZoneCount(1)
		if dangerZone_enemy_count >= 1:
			if (in_boss_room):
				setNoteLenArr(NoteLength.SHORTEST)
			else:
				setNoteLenArr(NoteLength.SHORT)
			print("danger zone.")
			sendMessage()


func _on_DangerZone1_body_exited(body):
	if body.name != "player" && body.name != "merchant" && body.get_class() == "KinematicBody2D":
		setDangerZoneCount(-1)
		if dangerZone_enemy_count == 0:
			if (in_boss_room):
				setNoteLenArr(NoteLength.SHORT)
			else:
				setNoteLenArr(NoteLength.LONG)
			print("danger zone exited.")
			sendMessage()
