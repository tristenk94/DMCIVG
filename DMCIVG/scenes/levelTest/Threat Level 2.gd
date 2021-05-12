extends Node

const DEBUG = false
signal threat_2

var fsm: Minor_Event_Stat_Machine
var new_state
#func that runs as soon as this state is determined, sends signal to music interpeter
func enter():
	if DEBUG:
		print("Threat Level 2")
	emit_signal("threat_2")

func exit(next_state):
	fsm.change_to(next_state)


