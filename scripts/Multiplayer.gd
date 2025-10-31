extends Node

# Basic Server Information
@export var GameScene : PackedScene
@export var Adress = "localhost"
@export var Port = 8080
@export var MaxPlayers = 12
var peer = ENetMultiplayerPeer.new()


func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	if OS.has_feature("dedicated_server"):
		print("Starting dedicated server...")
		host_game()

func peer_connected(id):
	print("Player Connected: " + str(id))

func peer_disconnected(id):
	print("Player Disconnected: " + str(id))

func connected_to_server():
	print("Connected to server")
	send_player_information.rpc_id(1, $"Debug Interface/NameField".text, multiplayer.get_unique_id())

func connection_failed():
	print("Connection Failed")

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

@rpc("any_peer", "call_local")
func start_game():
	var scene = GameScene.instantiate()
	get_tree().root.add_child(scene) # connects Main to Multiplayer as child.
	toggle_interface() 
	GameManager.set_manager(scene)

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
	#var error = peer.create_server(Port, "*", TLSOptions.server(serverKey, serverCert))
	var error = peer.create_server(Port)
	print("cannot host: " + str(error))
	multiplayer.set_multiplayer_peer(peer)
	GameManager.You = multiplayer.get_unique_id()
	print("Waiting for players")
	print("my id is:" + str(multiplayer.get_unique_id()))
	var playername
	if OS.has_feature("dedicated_server"):
		playername = "dedicated_server"
		
	else:
		playername = $"Debug Interface/NameField".text
	send_player_information(playername, multiplayer.get_unique_id())

func join_game():
	var clientCAS = load("res://Fullchain.crt")
	#peer.create_client("wss://" + Adress + ":" + str(Port),TLSOptions.client_unsafe(clientCAS))
	peer.create_client(Adress,Port)
	multiplayer.set_multiplayer_peer(peer)
	GameManager.You = multiplayer.get_unique_id()
	


## Interface Functions ##
func _on_start_button_pressed():
	start_game.rpc()

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
