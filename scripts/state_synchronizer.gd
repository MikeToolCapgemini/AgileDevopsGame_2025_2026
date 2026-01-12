extends Node

@export var pawnManager : PawnManager
@export var cardManager : CardManager
@export var diceManager : Dice
@export var timeManager : Hourglass
@export var interruptManager : Interrupt

var managers: Array = []

func _ready() -> void:
	managers = [pawnManager,cardManager,diceManager,timeManager,interruptManager]


# Called when someone reconnects or someone joins in late
func send_state_to_peer(peer_id: int):
	print("sending state to " + str(peer_id))
	if not multiplayer.is_server():
		return
	
	var index: int = 0
	for m in managers:
		if m:
			var state = m.get_state()
			rpc_id(peer_id, "apply_state", index,state)
			index += 1

@rpc("authority")
func apply_state(manager_id: int, state : Dictionary):
	# Client applies the state
	print("Applying states")
	var m = managers[manager_id]
	if m:
		m.apply_state(state)
