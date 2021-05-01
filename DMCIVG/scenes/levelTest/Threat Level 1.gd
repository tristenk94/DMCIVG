extends Node

const DEBUG = true

signal scale_trans

var fsm: Minor_Event_Stat_Machine
var new_state
#func that runs as soon as this state is determined, sends signal to music interpeter
func enter():
	if DEBUG:
		print("Threat Level 1")
	#emit_signal("scale_trans", 1)

func exit(next_state):
	fsm.change_to(next_state)
