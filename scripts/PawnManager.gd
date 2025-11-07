extends Node
 
@export var CameraObject : Camera3D
@export var WorldObject : Node3D


var index : int = 0
func save_pawn_positions():
	for pawn in  %Pawns.get_children():
		print(pawn.name)
		#GlobalSettings.PawnPositions[index] = pawn.transform
		#index + 1
