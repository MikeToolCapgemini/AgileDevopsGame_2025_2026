extends Node

var role = "none"
var color = ""

@rpc("any_peer","call_local")
func get_player_color() -> String:
	print(str(multiplayer.get_unique_id()) + " "+ color)
	return color

var PlayersColors := {} # key: peer_id, value: color string

@rpc("any_peer")
func set_player_color(peer_id: int, color_str: String):
	PlayersColors[peer_id] = color_str
	GameManager.players_updated.emit()
