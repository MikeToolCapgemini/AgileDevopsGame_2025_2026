class_name Pawn
extends Node3D

@export var CameraObject : Camera3D
@export var WorldObject : Node3D
@export var CollisionObject : CollisionShape3D
@export var OutlineMaterial : Material

@export var ObjectToColor : MeshInstance3D
@export var TargetMaterial : StandardMaterial3D
@export var TargetColor : Color

var InitialPosition: Vector3
var hover = false
var selected = false
var HasBeenSet = false

func _ready():
	CameraObject = self.get_parent_node_3d().CameraObject
	WorldObject = self.get_parent_node_3d().WorldObject
	HasBeenSet = true
	
	var newMaterial = StandardMaterial3D.new()
	newMaterial.albedo_color = TargetColor
	ObjectToColor.material_override = TargetMaterial
	InitialPosition = position

func _process(_delta):
	if HasBeenSet:
		_update_pawn_outline()
		if selected:
			_update_pawn_position()
			_sync_position.rpc(position)

func _update_pawn_position():
	#var spaceState = get_world_3d().direct_space_state
	var mouse = get_viewport().get_mouse_position()
	var from = CameraObject.project_ray_origin(mouse)
	var to = from + CameraObject.project_ray_normal(mouse) * 2000
	
	var newIntersection = PhysicsRayQueryParameters3D.create(from, to)
	var intersection = get_world_3d().direct_space_state.intersect_ray(newIntersection)
	
	if !intersection.is_empty():
		set_position(intersection.position) # this line if for debugging purposes.

func _update_pawn_outline():
	if hover or selected:
		ObjectToColor.material_overlay = OutlineMaterial #enables the outline via enabling the material shader
	else:
		ObjectToColor.material_overlay = null #Likewise this disables the outline via the same methode.

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		if hover && !selected:
			selected = true;
			CollisionObject.disabled = true
		elif selected:
			selected = false; 
			CollisionObject.disabled = false

func _on_static_body_3d_mouse_entered():
	hover = true

func _on_static_body_3d_mouse_exited():
	hover = false

func _on_reset_pawn_position_button_pressed():
	position = InitialPosition
	_sync_position.rpc(position)
	print("Position Reset")

@rpc("any_peer")
func _sync_position(newPosition: Vector3):
	position = newPosition
