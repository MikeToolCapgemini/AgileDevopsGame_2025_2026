class_name PawnManager
extends Node
 
@export var CameraObject : Camera3D
@export var WorldObject : Node3D

@export var pawns : Array[Pawn]

# Returns a snapshot of the pawn state
func get_state() -> Dictionary:
	var state = {}
	state["pawns"] = []
	var index := 0
	for pawn in pawns:
		state["pawns"].append({
			"id": index, # unique id for matching
			"position": pawn.global_position,
			"rotation": pawn.global_rotation
		})
		print("Pawn " + str(index) + " has been set to position " + str(pawn.global_position))
		index += 1
	return state

# Applies a snapshot to this manager
func apply_state(state: Dictionary):
	for pawn_data in state.get("pawns", []):
		var pawn = pawns[pawn_data["id"]]
		if pawn:
			pawn.global_position = pawn_data["position"]
			pawn.global_rotation = pawn_data["rotation"]
			print("Setting Pawn " + str(pawn_data["id"]) + " to position " + str(pawn_data["position"]))


func _on_reset_pawn_position_button_pressed() -> void:
	for pawn in pawns:
		pawn._on_reset_pawn_position_button_pressed()
