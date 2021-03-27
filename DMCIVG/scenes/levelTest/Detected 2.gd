extends Node

const DEBUG = false

var fsm: Enemy_Detection_Machine
var new_state

func enter():
	if DEBUG:
		print("enemy detected stage 2")
	yield(get_tree().create_timer(10), "timeout")
	exit("No Enemy")
func exit(next_state):
	fsm.change_to(next_state)

