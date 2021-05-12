extends Node

class_name Major_Event_Stat_Machine

const DEBUG = false



var state: Object
#Varibles to store current states of other state machine
var history = []
var state_value = 0
#starting function  always starts at first state
func _ready():
	# Will start at Threat Level 0
	var threat_value = 0
	state = get_child(0)
	#_enter_state()
	#print(state)
#func to change to a given node by name, calls enter state function
func change_to(new_state):
	history.append(state.name)
	state = get_node(new_state)
	_enter_state()
#not used but uses the history array and can be used to revert to previous node in history
func back():
	if history.size() > 0:
		state = get_node(history.pop_back())
		_enter_state()

#func that enters a given state by node location
func _enter_state():
	if DEBUG:
		print("Entering state: ", state.name)
	state.fsm = self
	state.enter()
