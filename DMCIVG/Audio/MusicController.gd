# --- Music Controller ---
extends Node
var socket

## --- Pure Data global variables
var bpmSelect = 0 setget setBPMSelect # 1 = change bpm, 0 = don't change bpm.
var bpm = MIN_BPM setget setBPM
var masterVol = 95 setget setMasterVol

# 5 instruments: L Top, L Bot, R Top, R Mid, R Bot; ***Lead instrument is R Top (instr2)
var instrumentVol = [0.0, 0.0, 0.0, 0.0, 0.0] setget setInstrumentVolumes 
var instrumentNoteLen = [NoteLength.LONGEST, NoteLength.LONGEST, NoteLength.LONGEST, NoteLength.LONGEST, NoteLength.LONGEST] setget setInstrumentNoteLengths

var scaleSelect = 1 # 0 - 4
var pitch = 0 setget setPitch, getPitch # pitch is based on health
var swingPercent = 50 setget setSwingPercent # 0 - 100%
var triggerProb = 1 # 0 - 4; probability that beat occurs (rhythm prob); select probability array 
var loopDensity = 50 # 0 - 100
var loopLen= 16 # 16 - 32; number of beats per measure
var noteProb1 = 50 # 0 - 100; probability that 1, 2, or 3 notes played simultaneously
var noteProb2 = 50
var noteProb3 = 50
var noteProbArr = 0 # select array of probabilities that note in scale will be played during measure;0 -> 2, --> increasing probability.

## -- Global constants
enum {LOW, MEDIUM, HIGH}
enum NoteLength {SHORTEST = 80, SHORT = 150, LONG = 300, LONGEST = 1000} # shorter = more tension
enum Scales {HANG, HANG_DEEP, MAJOR_PENT, MINOR_PENT, PHRYGIAN, PHRYG_DOM, PERSIAN, LYDIAN, MIXOLYDIAN}
enum TriggerProb {MIN_TENSION, LESS_TENSION, NORMAL_TENSION, MORE_TENSION, MAX_TENSION} # Rhythm Probabilities

# Instrument volumes
const SILENT = 0.0
const QUIET = 0.3
const FULL = 0.5

const MAX_MASTER_VOLUME = 100 # since volArr values never exceeds 0.5
const MIN_MASTER_VOLUME = 95
const MAX_BPM = 215
const MIN_BPM = 80
const MAX_PITCH = 4
const MIN_PITCH = -3
const DEFAULT_PITCH = 0
const DEFAULT_LOOPLENGTH = 16 # 4 quarters per measure
const TRIPLE_TIME_LOOPLENGTH = 12 # 3 quarters per measure
const MEDIAN_VALUE = 50
const NUMBER_OF_INSTRUMENTS = 5

# Level object variables
var area1_visited = false 
var area2_visited = false 
var area3_visited = false
var in_area1 = false
var in_area2 = false 
var in_boss_room = false
var enemy_count = 0 setget setEnemyCount
var dangerZone1_enemyCount = 0 setget setDangerZone1Count
var dangerZone2_enemyCount = 0 setget setDangerZone2Count
var player

# Other variables
var rng = RandomNumberGenerator.new()
var format_message = "%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s;" # 23 parameters

## --- Functions
func sendMessage():
	var message = format_message % [bpmSelect, bpm, masterVol, instrumentVol[0], instrumentVol[1], instrumentVol[2], instrumentVol[3], instrumentVol[4], 
	instrumentNoteLen[0], instrumentNoteLen[1], instrumentNoteLen[2], instrumentNoteLen[3], instrumentNoteLen[4], 
	scaleSelect, pitch, swingPercent, triggerProb, loopDensity, loopLen, noteProb1, noteProb2, noteProb3, noteProbArr]
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


# --------- Pure Data Setters ---------
func setMasterVol(new_masterVol):
	if new_masterVol >= MIN_MASTER_VOLUME && new_masterVol <= MAX_MASTER_VOLUME:
		masterVol = new_masterVol
	else: 
		print("master vol not valid.")

# accepts an array of 5 instrument volumes
func setInstrumentVolumes(new_instrument_volumes):
	var valid_volumes = true 
	
	for volume in new_instrument_volumes: 
		if volume < 0.0 || volume > 0.5:
			valid_volumes = false
			break
	
	if new_instrument_volumes.size() == NUMBER_OF_INSTRUMENTS && valid_volumes:
		instrumentVol = new_instrument_volumes
	

# accepts an array of 5 instrument note lengths
func setInstrumentNoteLengths(new_note_lengths):
	var valid_lengths = true
	
	for noteLen in new_note_lengths:
		if noteLen < 80 || noteLen > 1000:
			valid_lengths = false
			break
	
	if new_note_lengths.size() == NUMBER_OF_INSTRUMENTS && valid_lengths:
		instrumentNoteLen = new_note_lengths

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
	if (prob1 >= 0 && prob1 <= 100):
		noteProb1 = prob1
	if (prob1 >= 0 && prob1 <= 100):
		noteProb2 = prob2
	if (prob1 >= 0 && prob1 <= 100):
		noteProb3 = prob3

func setNoteProbArr(new_arr):
	noteProbArr = new_arr

#func setNoteLenArr(new_arr):
#	noteLenArr = new_arr

#func setVolArr(new_arr):
#	volArr = new_arr
	
func setBPMSelect(set):
	if (set == 0 || set == 1):
		bpmSelect = set

# --------------------

## Other setters
# Enemy Count affects scale selection.
func setEnemyCount(increment):
	enemy_count += increment
	
	if enemy_count == 0: # 0 enemies detected
		if in_area1: 
			setInstrumentVolumes([FULL, SILENT, SILENT, SILENT, SILENT])
		elif in_area2:
			setInstrumentVolumes([FULL, SILENT, FULL, SILENT, SILENT])
	if enemy_count == 1: 
		if in_area1: 
			setInstrumentVolumes([FULL, SILENT, QUIET, SILENT, SILENT])
		elif in_area2:
			setInstrumentVolumes([FULL, QUIET, FULL, SILENT, SILENT])
	if enemy_count == 2:
		if in_area1: 
			setInstrumentVolumes([FULL, QUIET, QUIET, SILENT, SILENT])
		elif in_area2:
			setInstrumentVolumes([FULL, QUIET, FULL, QUIET, SILENT])
	if enemy_count >= 3:
		if in_area1: 
			setInstrumentVolumes([FULL, QUIET, QUIET, QUIET, SILENT])
		elif in_area2:
			setInstrumentVolumes([FULL, QUIET, FULL, QUIET, QUIET])


func setDangerZone1Count(increment):
	dangerZone1_enemyCount += increment

func setDangerZone2Count(increment):
	dangerZone2_enemyCount += increment
	
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
#	setBPMSelect(1)
#	setBPM(90)
#	setMasterVol(100)
#	setInstrumentVolumes([QUIET, QUIET, FULL, QUIET, QUIET])
#	setInstrumentNoteLengths([NoteLength.LONGEST, NoteLength.LONGEST, NoteLength.LONGEST, NoteLength.LONGEST, NoteLength.LONGEST])
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
# 	setBPMSelect(0)

## Pause Menu

## Game Over Menu

## Areas
func _on_Area1_body_entered(body):
	in_area1 = true
	if body != null:
		if body.name == "player":
			print("Area1 entered.")
			if area1_visited == false:
				area1_visited = true
				
			setBPMSelect(1) # IMPORTANT: Only change BPM for areas/menus (otherwise "stuttering" occurs often).
			setBPM(150)
			setMasterVol(MAX_MASTER_VOLUME)
			setInstrumentVolumes([FULL, SILENT, SILENT, SILENT, SILENT])
			setInstrumentNoteLengths([NoteLength.LONGEST, NoteLength.LONGEST, NoteLength.LONGEST, NoteLength.LONGEST, NoteLength.LONGEST])
			setScale(Scales.PHRYG_DOM)
			setPitch(DEFAULT_PITCH)
			setSwingPercent(MEDIAN_VALUE)
			setTriggerProb(TriggerProb.NORMAL_TENSION)
			setLoopDensity(MEDIAN_VALUE)
			setLoopLen(DEFAULT_LOOPLENGTH)
			setNoteProb(10, 10, 10)
			setNoteProbArr(LOW)
			sendMessage()
			
			setBPMSelect(0) # IMPORTANT: Remember to turn off BPM change

func _on_Area1_body_exited(body):
	in_area1 = false

func _on_Area2_body_entered(body):
	in_area2 = true
	if body != null:
		if body.name == "player":
			print("Area2 entered.")
			if area2_visited == false:
				area2_visited = true
				
			setBPMSelect(1)
			setMasterVol(MAX_MASTER_VOLUME)
			setBPM(180)
			setInstrumentVolumes([FULL, SILENT, FULL, SILENT, SILENT])
			setInstrumentNoteLengths([NoteLength.LONG, NoteLength.LONGEST, NoteLength.LONGEST, NoteLength.LONGEST, NoteLength.LONGEST])
			setScale(Scales.PHRYG_DOM)
			#setPitch(DEFAULT_PITCH) 
			setSwingPercent(MEDIAN_VALUE)
			setTriggerProb(TriggerProb.MORE_TENSION)
			setLoopDensity(MEDIAN_VALUE)
			setLoopLen(DEFAULT_LOOPLENGTH)
			setNoteProb(50, 50, 50)
			setNoteProbArr(MEDIUM)
			sendMessage()
			
			setBPMSelect(0) # Turn off BPM change

func _on_Area2_body_exited(body):
	in_area2 = false


func _on_Area3_body_entered(body):
	in_boss_room = true
	if body != null:
		if body.name == "player":
			print("Area3 entered.")
			if area3_visited == false:
				area3_visited = true
				
			setBPMSelect(1)
			setMasterVol(MAX_MASTER_VOLUME)
			setInstrumentVolumes([FULL, FULL, FULL, QUIET, QUIET])
			# note length is always short/shortest in bossroom
			setInstrumentNoteLengths([NoteLength.SHORT, NoteLength.SHORT, NoteLength.SHORT, NoteLength.LONG, NoteLength.LONG])
			setBPM(MAX_BPM)
			setScale(Scales.PERSIAN)
			#setPitch(DEFAULT_PITCH) # pitch is based on health
			setSwingPercent(MEDIAN_VALUE)
			setTriggerProb(TriggerProb.MAX_TENSION)
			setLoopDensity(MEDIAN_VALUE)
			setLoopLen(DEFAULT_LOOPLENGTH)
			setNoteProb(70, 70, 80)
			setNoteProbArr(MEDIUM)
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
	setBPMSelect(1)
	setBPM(100)
	setMasterVol(100)
	setInstrumentVolumes([QUIET, QUIET, FULL, QUIET, QUIET])
	setInstrumentNoteLengths([NoteLength.LONGEST, NoteLength.LONGEST, NoteLength.LONGEST, NoteLength.LONGEST, NoteLength.LONGEST])
	setScale(Scales.MINOR_PENT)
	setPitch(-2)
	setSwingPercent(10)
	setTriggerProb(TriggerProb.LESS_TENSION)
	setLoopDensity(MEDIAN_VALUE)
	setLoopLen(DEFAULT_LOOPLENGTH)
	setNoteProb(10, 10, 10)
	setNoteProbArr(LOW)
	sendMessage()
	
	setBPMSelect(0)


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
		setDangerZone1Count(1)
		if dangerZone1_enemyCount >= 1:
			if (in_boss_room):
				pass
			else:
				setInstrumentNoteLengths([NoteLength.SHORT, NoteLength.SHORT, NoteLength.SHORT, NoteLength.SHORT, NoteLength.SHORT])
			print("danger zone 1.")
			sendMessage()


func _on_DangerZone1_body_exited(body):
	if body.name != "player" && body.name != "merchant" && body.get_class() == "KinematicBody2D":
		setDangerZone1Count(-1)
		if dangerZone1_enemyCount == 0:
			if (in_boss_room):
				pass
			elif (in_area2):
				setInstrumentNoteLengths([NoteLength.LONG, NoteLength.LONGEST, NoteLength.LONGEST, NoteLength.LONGEST, NoteLength.LONGEST])
			elif (in_area1):
				setInstrumentNoteLengths([NoteLength.LONGEST, NoteLength.LONGEST, NoteLength.LONGEST, NoteLength.LONGEST, NoteLength.LONGEST])
			print("danger zone 1 exited.")
			sendMessage()

# Zone closest to player
func _on_DangerZone2_body_entered(body):
	if body.name != "player" && body.name != "merchant" && body.get_class() == "KinematicBody2D":
		setDangerZone2Count(1)
		if dangerZone2_enemyCount >= 1:
			setInstrumentNoteLengths([NoteLength.SHORTEST, NoteLength.SHORTEST, NoteLength.SHORTEST, NoteLength.SHORTEST, NoteLength.SHORTEST])
			print("danger zone 2.")
			sendMessage()

func _on_DangerZone2_body_exited(body):
	if body.name != "player" && body.name != "merchant" && body.get_class() == "KinematicBody2D":
		setDangerZone2Count(-1)
		if dangerZone2_enemyCount == 0:
			if (in_boss_room):
				setInstrumentNoteLengths([NoteLength.SHORT, NoteLength.SHORT, NoteLength.SHORT, NoteLength.SHORT, NoteLength.SHORT])
			print("danger zone 2 exited.")
			sendMessage()

