extends Node

const DEBUG = false

var fsm: Enemy_Detection_Machine
var new_state
var detected = false
var attacked
signal threat_up

func enter():
	if DEBUG:
		print("No Enemy")
	attacked = 0
	
	
# still unable to make work
#func on_player_detection():
#	
#	exit("Detected")

func exit(next_state):
	if(detected == true):
		fsm.change_to(next_state)


func enemy_attacking():
	if(fsm.state.name == "No Enemy"):
		attacked += 1
		if(attacked == 1):
			detected = true
			emit_signal("threat_up", attacked)
			exit("Detected")
		else:
			pass
 
