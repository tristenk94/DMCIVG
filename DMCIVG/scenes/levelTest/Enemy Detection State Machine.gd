
extends Node

class_name Enemy_Detection_Machine

const DEBUG = false

var state: Object
var history = []
# will always start at state 1, no enemies detecting player
func _ready():
	# Will start at state 1
	state = get_child(0)
	_enter_state()
	

func change_to(new_state):
	history.append(state.name)
	state = get_node(new_state)
	_enter_state()

func back():
	if history.size() > 0:
		state = get_node(history.pop_back())
		_enter_state()

func _enter_state():
	if DEBUG:
		print("Entering state: ", state.name)
	state.fsm = self
	state.enter()
