extends Button





func _on_stop_pressed() -> void:
	print("STOPPING SESSION")
	GameManager.multiplayer_manager._on_stop_game_button_pressed()
