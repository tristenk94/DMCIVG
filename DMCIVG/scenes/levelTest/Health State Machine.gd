
extends Node

class_name Health_State_Machine

const DEBUG = false

var state: Object
var history = []
# will always start at state 1, health should be at 100% if starting new
func _ready():
	# Will start at state 1
	state = get_child(0)
	_enter_state()
	
#function to change to a given state 
func change_to(new_state):
	history.append(state.name)
	state = get_node(new_state)
	_enter_state()

#not used but can be used to revert to previous state/node
func back():
	if history.size() > 0:
		state = get_node(history.pop_back())
		_enter_state()

#functionm called in the change_to func that moves to given state
func _enter_state():
	if DEBUG:
		print("Entering state: ", state.name)
	state.fsm = self
	state.enter()

#signal reciever that has two parameters, uses health from player node
#Will determine what node to move to depending on the value set in health
func _on_player_health_amount(old_health, health):
	#print(old_health)
	#print(health)
	
	#if else if determine what state to place the player in, has three conditionals 
	#to ensure that it only changes when when it hits the threshold instead of
	# at every signal recieved 
	if(health<=19 && health>0 && state.name != "19% Health"):
		change_to("19% Health")
	elif(health<=49 && health>19 && state.name != "49% Health"):
		change_to("49% Health")
	elif(health<=79 && health>49 && state.name != "79% Health"):
		change_to("79% Health")
	elif(health>79 && state.name != "100% Health"):
		change_to("100% Health")

#this func tuns when the death signal is recieved will push the fsm to the the 0% node
# music will drastically slow down because you are now dead /:
func _on_player_death():
	change_to("0 % Health") # Replace with function body.
