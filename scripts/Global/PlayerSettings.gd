extends Node

var role = "none"
var color = ""

@rpc("any_peer","call_local")
func get_player_color() -> String:
	print(str(multiplayer.get_unique_id()) + " "+ color)
	return color



@rpc("any_peer","call_local")
func notify_players_updated():
	# This will run on all clients
	GameManager.players_updated.emit()
