extends Node

var role = "none"
var color = ""
signal players_colors_updated

@rpc("any_peer","call_local")
func get_player_color() -> String:
	print(str(multiplayer.get_unique_id()) + " "+ color)
	return color

var PlayersColors := {} # key: peer_id, value: color string

@rpc("any_peer")
func set_player_color(peer_id: int, color_str: String):
	PlayersColors[peer_id] = color_str
	players_colors_updated.emit()

@rpc("any_peer")
func request_all_colors():
	if not multiplayer.is_server():
		return

	var target := multiplayer.get_remote_sender_id()

	#print("Sending colors to ", target)
	#print(PlayersColors)

	send_all_colors.rpc_id(target, PlayersColors)


@rpc("any_peer")
func send_all_colors(colors: Dictionary):
	PlayersColors = colors
	players_colors_updated.emit()
