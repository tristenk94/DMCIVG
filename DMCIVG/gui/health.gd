extends ColorRect


#CONNECT TO PLAYER STATS CHANGED HERE
func _on_player_player_stats_changed(var player):
	$bar.rect_size.x = 496 * (player.health / player.health_max)

#connected the health_amount signal for testing
#func _on_player_health_amount():
	#pass # Replace with function body.
