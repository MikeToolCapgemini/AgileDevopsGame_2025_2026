extends Button


func _on_pressed() -> void:
	var peer := multiplayer.multiplayer_peer
	if peer:
		peer.close()
