class_name PawnManager
extends Node
 
@export var CameraObject : Camera3D
@export var WorldObject : Node3D

@export var pawns : Array[Pawn]

func save_pawn_positions():
	GlobalSettings.PawnPositions = get_state_for_save()

func get_state_for_save() -> Dictionary:
	var state = {}
	state["pawns"] = []
	var index := 0

	for pawn in pawns:
		state["pawns"].append({
			"id": index,
			"position": vec3_to_dict(pawn.global_position),
			"rotation": vec3_to_dict(pawn.global_rotation)
		})
		index += 1

	return state

func vec3_to_dict(v: Vector3) -> Dictionary:
	return { "x": v.x, "y": v.y, "z": v.z }

func read_vec3(v) -> Vector3:
	if v is Vector3:
		return v
	if v is Dictionary:
		return Vector3(v.x, v.y, v.z)
	return Vector3.ZERO


# Returns a snapshot of the pawn state
func get_state() -> Dictionary:
	var state = {}
	state["pawns"] = []
	var index := 0
	for pawn in pawns:
		state["pawns"].append({
			"id": index, # unique id for matching
			"position": pawn.global_position,
			"target_position": pawn.target_position,
			"rotation": pawn.global_rotation
		})
		print("Pawn " + str(index) + " has been set to position " + str(pawn.global_position))
		index += 1
	return state

@rpc("any_peer")
func apply_state(state: Dictionary):
	if !state.has("pawns"):
		return
	for pawn_data in state.get("pawns", []):
		var pawn = pawns.get(pawn_data["id"])
		if pawn:
			pawn.target_position = read_vec3(pawn_data["target_position"])
			pawn.global_position = read_vec3(pawn_data["position"])
			pawn.global_rotation = read_vec3(pawn_data["rotation"])
			print("Setting Pawn " + str(pawn_data["id"]) + " to position " + str(pawn_data["position"]))
			pawn._sync_position(pawn_data["target_position"])


func _on_reset_pawn_position_button_pressed() -> void:
	for pawn in pawns:
		pawn._on_reset_pawn_position_button_pressed()
