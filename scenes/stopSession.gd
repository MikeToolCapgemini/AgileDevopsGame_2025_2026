extends Button





func _on_stop_pressed() -> void:
	GameManager.multiplayer_manager._on_stop_game_button_pressed()
