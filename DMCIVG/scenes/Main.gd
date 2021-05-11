# --- Main.gd --- #
extends Node

var exit_code = 1
var output = []
var bash_args = ["-a", "Pd-0.51-1.app", "Audio/Sequencer.pd"]
var win_args = ["Audio\\Sequencer.pd"]

#var LevelScene = "res://scenes/Level.tscn"

# Called when Main node is first created. 
func _init():
	pass
	# TODO: search for correct file name in case Pd versions are different ( current is Pd-0.51-1 )
	# if exit_code == 1:
		# Pure Data file not found
	# if exit_code == 0:
		# Pure Data file found

	# OS.execute(path,  arguments, blocking, shell output): 
	# blocking = true => means pause Godot thread until process terminates, and method returns exit code
	
	## Open PD patch
#	if OS.get_name() == "OSX": 
#		exit_code = OS.execute( "open", PoolStringArray(bash_args), true)
#		print("Opening PD patch in OSX...")
#	if OS.get_name() == "Windows":
#		exit_code = OS.execute("Pd-0.51-1.exe", PoolStringArray(win_args), true)
#		print("Opening PD patch in Windows...")
	


# Called when the node enters the scene tree for the first time.
func _ready():
	if exit_code != 0:
		print("Could not open patch.")
		print("exit code: %d" % [exit_code])
		# TODO: pop-up: "Pure Data and .pd patch needs to be in same folder as the game"

