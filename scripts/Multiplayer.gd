class_name Multiplayer
extends Node

# Basic Server Information
@export var GameScene : PackedScene
@export var Adress = "srv1161281.hstgr.cloud"
#@export var Adress = "localhost"
@export var Port = 8081
@export var MaxPlayers = 12
var peer = ENetMultiplayerPeer.new()
var webPeer = WebSocketMultiplayerPeer.new()

var started : bool = false

@export var connect_panel : Control
@export var disconnect_panel : Control
@export var disconnect_server_panel : Control

func _ready():
	GameManager.multiplayer_manager = self
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	multiplayer.server_disconnected.connect(on_server_disconnected)
	if OS.has_feature("dedicated_server"):
		print("Starting dedicated server...")
		host_game()

func _process(_delta):
	if OS.has_feature("dedicated_server"):
		print(webPeer.get_connection_status())

func peer_connected(id):
	if id != 1:
		connect_panel.edit_text("Player Connected: " + str(id))
		connect_panel.show()
	print("Player Connected: " + str(id))
	if started:
		rpc_id(id, "join_running_game")
		var state_sync = get_tree().root.get_node("Main/StateSynchronizer")
		state_sync.call_deferred("send_state_to_peer",id)

func peer_disconnected(id):
	if GameManager.Players.has(id):
		var pName = GameManager.Players[id].name
		disconnect_panel.edit_text("Player: " + str(pName) + " Disconnected!" )
		disconnect_panel.show()
		GameManager.Players.erase(id)
		update_text_field()
	print("Player Disconnected: " + str(id))

func connected_to_server():
	connect_panel.edit_text("Connected to server")
	connect_panel.show()
	print("Connected to server")
	send_player_information.rpc_id(1, $"Debug Interface/NameField".text, multiplayer.get_unique_id())

func connection_failed():
	disconnect_panel.edit_text("Connection Failed")
	disconnect_panel.show()
	print("Connection Failed")
	
func on_server_disconnected():
	disconnect_server_panel.edit_text("Disconnected from server")
	disconnect_server_panel.show()
	print("Disconnected from server")

# Sends information about the player and updates/synchronizes the Players dict in GameManager
@rpc("any_peer")
func send_player_information(playername, id):
	# check if given client ID is already registered. If not, add
	if !GameManager.Players.has(id):
		GameManager.Players[id] = {
			"name" : playername,
			"id" : id
		}
	# calls update for player information to all connected clients if current client = server.
	if multiplayer.is_server():
		for p in GameManager.Players:
			send_player_information.rpc(GameManager.Players[p].name, p)
		
	update_text_field()

@rpc("any_peer","call_local")
func request_start_game():
	if multiplayer.is_server() and not started:
		start_game()

@rpc("authority")
func start_game():
	var scene = GameScene.instantiate()
	get_tree().root.add_child(scene) # connects Main to Multiplayer as child.
	call_deferred("hide_multiplayer_ui")
	started = true
	GameManager.set_manager(scene)
	# Tell all connected clients to join
	for peer_id in multiplayer.get_peers():
		if peer_id != multiplayer.get_unique_id(): # skip host if already done
			rpc_id(peer_id, "join_running_game")

func reset_server_session():
	# Kick any remaining peers (usually none)
	for peer_id in multiplayer.get_peers():
		rpc_id(peer_id, "server_resetting")
		multiplayer.disconnect_peer(peer_id)

	# Reset game state
	started = false

	GameManager.Players.clear()
	update_text_field()

	# Remove game scene if it exists
	if get_tree().root.has_node("Main"):
		get_tree().root.get_node("Main").queue_free()

	# Return to lobby state
	show_multiplayer_ui()
	disconnect_server_panel.hide()

@rpc("authority")
func request_server_reset():
	# Optional: only allow certain players to trigger it
	#if not is_player_allowed_to_reset(get_tree().get_rpc_sender_id()):
		#return
	
	reset_server_session()


@rpc("authority")
func server_resetting():
	ErrorLabel.show_error("Server session ended, Server is resetting")

func _on_stop_game_button_pressed():
	# Tell the server to reset the session
	rpc_id(1, "request_server_reset") # assuming host ID is 1


@rpc("authority")
func join_running_game():

	var scene = GameScene.instantiate()
	get_tree().root.add_child(scene)

	call_deferred("hide_multiplayer_ui")
	GameManager.set_manager(scene)
	


func show_multiplayer_ui():
	$"Debug Interface".visible = true

func hide_multiplayer_ui():
	$"Debug Interface".visible = false



# Toggles the connection interface on/off.
func toggle_interface():
	if $"Debug Interface".visible:
		$"Debug Interface".visible = false
	else:
		$"Debug Interface".visible = true

# Updates TextField which displays a list of clients that are connected.
func update_text_field():
	var newText = ""
	for player in GameManager.Players:
		newText += GameManager.Players[player].name + "\n"
	$"Debug Interface/TextField".text = newText

func host_game():
	var serverCert = load("res://Fullchain.crt")
	var serverKey = load("res://DevopsPrivate.key")
	var web_error = webPeer.create_server(Port)
	#var error = webPeer.create_server(Port, "*", TLSOptions.server(serverKey, serverCert))
	#var error = peer.create_server(Port)
	if web_error != OK:
		push_error("WebSocket server failed: " + str(web_error))
		return
	#if error != OK:
		#push_error("Peer server connection failed: " + str(web_error))
		#return
	multiplayer.set_multiplayer_peer(webPeer)
	GameManager.You = multiplayer.get_unique_id()
	print("Waiting for players")
	if OS.has_feature("dedicated_server"):
		send_player_information("Dedicated Server:", multiplayer.get_unique_id())
	else :
		send_player_information($"Debug Interface/NameField".text, multiplayer.get_unique_id())

func join_game():
	var clientCAS = load("res://Fullchain.crt")
	#webPeer.create_client("wss://" + Adress + ":" + str(Port),TLSOptions.client_unsafe(clientCAS))
	#peer.create_client(Adress,Port)
	var err = webPeer.create_client("wss://" + Adress + ":" + str(Port))
	if err != OK:
		print("Failed to start WebSocket client:", err)
	multiplayer.set_multiplayer_peer(webPeer)
	GameManager.You = multiplayer.get_unique_id()
	GameManager.last_address = Adress
	GameManager.last_port = Port

## Interface Functions ##
func _on_start_button_pressed():
	request_start_game.rpc_id(1)

func _on_host_button_pressed():
	host_game()

func _on_join_button_pressed():
	join_game()

func _on_debug_button_pressed():
	for p in GameManager.Players:
		print(GameManager.Players[p].name)

func _on_toggle_button_pressed():
	toggle_interface()


## Multiplayer live data transmission test
@export var incrementValue = 0

func _on_plus_button_button_up():
	incrementTheValue.rpc(1)

func _on_minus_button_button_up():
	incrementTheValue.rpc(-1)
	
@rpc("any_peer")
func incrementTheValue(v):
	print(incrementValue)
	incrementValue += v
	$"Debug Interface/ValueText".text = str(incrementValue)


func _on_ip_field_text_changed():
	Adress = $"Debug Interface/IPField".text

func cleanup_multiplayer():
	show_multiplayer_ui()
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null

	started = false
	GameManager.Players.clear()
	update_text_field()

	# Remove game scene if it exists
	if get_tree().root.has_node("Main"):
		get_tree().root.get_node("Main").queue_free()
	disconnect_server_panel.hide()


func _on_reconnect_pressed():
	if GameManager.last_address.is_empty():
		return

	disconnect_server_panel.edit_text("Reconnecting...")
	disconnect_server_panel.show()

	# FULL cleanup
	cleanup_multiplayer()

	await get_tree().process_frame

	# NEW peer instance (critical)
	peer = ENetMultiplayerPeer.new()
	peer.create_client(GameManager.last_address, GameManager.last_port)
	multiplayer.multiplayer_peer = peer


func _on_home_pressed() -> void:
	cleanup_multiplayer()
	
