extends Node

const DEBUG = true

var fsm: Enemy_Detection_Machine
var new_state
var attacked = 1
signal enemy_threat

func enter():
	if DEBUG:
		print("Detected by enemy")
	#print(attacked)
	# Exit 2 seconds later
	
	#fsm._determine_state()
	#print(new_state)
	
	


func exit(next_state):
	fsm.change_to(next_state)

func _attacking_2ndStage():
	if(fsm.state.name == "Detected"):
		if(attacked <= 4):
			attacked +=1
			if DEBUG:
				print(attacked)
			emit_signal("enemy_threat", 1)
		elif(attacked > 4 && attacked <= 8):
			attacked +=1
			emit_signal("enemy_threat", 1)
			#print(attacked)
		else:
			exit("Detected2")
