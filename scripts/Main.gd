extends Node

@export var Cursors : Node3D
@export var World : Node3D
@export var Camera : Camera3D

func _get_world():
	return World

func _get_camera():
	return Camera
