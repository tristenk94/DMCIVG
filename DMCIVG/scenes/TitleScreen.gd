# --- TitleScreen.gd --- #
extends Control

signal title_screen

var scene_path_to_load

var level_path = "res://scenes/Level.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Play is pre-selected
	print("title screen loaded")
	$Menu/CenterRow/Buttons/MarginContainer/VBoxContainer/Play.grab_focus()
	
	# Connect 
	for button in $Menu/CenterRow/Buttons/MarginContainer/VBoxContainer.get_children():
		button.connect("pressed", self, "_on_Button_pressed", [button.scene_to_load])

func _on_Button_pressed(scene_to_load):
	scene_path_to_load = scene_to_load
	if (scene_to_load == level_path):
		$FadeIn.show()
		$FadeIn.fade_in()
	else: 
		print("loading scene: %s" % scene_to_load)
		get_tree().change_scene(scene_to_load)

func _on_MusicController_TCP_connected():
	
	# Wait to receive UDP message from Pure Data
	
	# Make sure Music Controller is loaded first before emitting
	emit_signal("title_screen") # signal for music controller
	


func _on_FadeIn_fade_finished():
	print("loading scene: %s" % scene_path_to_load)
	get_tree().change_scene(scene_path_to_load)
