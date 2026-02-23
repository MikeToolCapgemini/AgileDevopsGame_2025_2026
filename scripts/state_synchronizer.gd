extends Node

@export var pawnManager : PawnManager
@export var cardManager : CardManager
@export var diceManager : Dice
@export var timeManager : Hourglass
@export var interruptManager : Interrupt
@export var playerList : PlayerList

var managers: Array = []

func _ready() -> void:
	managers = [pawnManager,cardManager,diceManager,timeManager,interruptManager]


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_IN:
		if multiplayer.has_multiplayer_peer():
			rpc_id(1,"request_state")
			playerList.update_player_list()
			print("player has focused in")
	elif what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		print("player has focused out")
		

@rpc("any_peer")
func request_state():
	if not multiplayer.is_server():
		return
	var peer_id := multiplayer.get_remote_sender_id()
	send_state_to_peer(peer_id)
	PlayerSettings.request_all_colors.rpc_id(peer_id)

# Called when someone reconnects or someone joins in late
func send_state_to_peer(peer_id: int):
	GlobalSettings.sync_self_to_clients()
	print("sending state to " + str(peer_id))
	if not multiplayer.is_server():
		return
	
	
	var index: int = 0
	for m in managers:
		if m:
			var state = m.get_state()
			rpc_id(peer_id, "apply_state", index,state)
		index += 1

@rpc("any_peer")
func apply_state(manager_id: int, state : Dictionary):
	# Client applies the state
	print("Applying states")
	var m = managers[manager_id]
	if m:
		m.apply_state(state)
