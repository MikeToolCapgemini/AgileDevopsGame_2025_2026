extends Node
 
@export var CameraObject : Camera3D
@export var WorldObject : Node3D

@export var pawns : Array[Pawn]




func _on_reset_pawn_position_button_pressed() -> void:
	for pawn in pawns:
		pawn._on_reset_pawn_position_button_pressed()
