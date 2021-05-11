extends Button

signal continue_pressed

func _on_Continue_pressed():
	emit_signal("continue_pressed")
