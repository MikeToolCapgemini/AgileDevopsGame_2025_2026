extends Node3D

@export var MouseObject : Node3D
@export var CameraObject : Camera3D
@export var WorldObject : Node3D
@export var TrackCursor = false
var HasBeenSet = false

func _ready():
	HasBeenSet = true

func _process(_delta):
	if HasBeenSet && TrackCursor:
		_update_cursor_position()
	
func _update_cursor_position():
	#var spaceState = get_world_3d().direct_space_state
	var mouse = get_viewport().get_mouse_position()
	var from = CameraObject.project_ray_origin(mouse)
	var to = from + CameraObject.project_ray_normal(mouse) * 2000
	
	var newIntersection = PhysicsRayQueryParameters3D.create(from, to)
	var intersection = get_world_3d().direct_space_state.intersect_ray(newIntersection)
	
	if !intersection.is_empty():
		MouseObject.set_position(intersection.position) # this line if for debugging purposes.
