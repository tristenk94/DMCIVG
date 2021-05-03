extends Node

class_name Minor_Event_Stat_Machine

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
	_enter_state()
	#print(state)
	#function to determine state, parameter det_state is an integer which will be added to state_value and then 
	#basically takes into account how many enemies are currently avilbale to attack the player. 
	#This is upclose danger, if being chased handles by area 2d node on Tomo's end
func _determine_state(var det_state):
	state_value = state_value + det_state
	print(state_value)
	if DEBUG:
		print("Determining state...")
	#Functions to pull current states will place a threat value based on what 
	# the other fsms 
	
	#bunch of if else to determine what state the FSM should point at
	if(state_value>= 10):
		state = get_child(5)
		_enter_state()
	elif(state_value >=9):
		state = get_child(4)
		_enter_state()
	elif(state_value >=6):
		state = get_child(3)
		_enter_state()
	elif(state_value >=3):
		state = get_child(2)
		_enter_state()
	elif(state_value>=1):
		state = get_child(1)
		_enter_state()
	elif(state_value<1): 
		state = get_child(0)
		_enter_state()
	
	
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
func _on_detected_player(threat_value):
	_determine_state(threat_value)
	
func _on_undetected_player(threat_value):
	_determine_state(threat_value)
