extends Node

const DEBUG = true

var fsm: Health_State_Machine
var new_state

# this runs whenever the state machine calls this node to be change_to()
# sends signal musi_bpm which will tell the the patch to set bpm to set parameter
func enter():
	if DEBUG:
		print("19% Health")
	emit_signal("music_bpm", 200)
	

func exit(next_state):
	fsm.change_to(next_state)

