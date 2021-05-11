extends Popup

signal pause_activated
signal pause_deactivated

func _input(event):
	if event.is_action_pressed("Pause"):
		if not self.is_visible():
			# Pause game
			get_tree().paused = true
			self.popup()
			$VBoxContainer/MarginContainer/VBoxContainer/Continue.grab_focus()
			emit_signal("pause_activated")
		else: 
			resume()
			emit_signal("pause_deactivated")

func resume():
	get_tree().paused = false
	self.hide()
	
func _on_Continue_continue_pressed():
	resume()
