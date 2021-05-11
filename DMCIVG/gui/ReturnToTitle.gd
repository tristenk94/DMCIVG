extends Control


func _on_Back_pressed():
	get_tree().change_scene("res://scenes/TitleScreen.tscn")


func _on_Main_pressed():
	get_tree().paused = false # un-pause!
	get_tree().change_scene("res://scenes/Main.tscn")
