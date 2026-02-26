class_name Pawn
extends Node3D

@export var CameraObject : Camera3D
@export var WorldObject : Node3D
@export var CollisionObject : CollisionShape3D
@export var OutlineMaterial : Material

@export var ObjectToColor : MeshInstance3D
@export var TargetMaterial : StandardMaterial3D
@export var TargetColor : Color

@export var AssociatedTeam : String

var InitialPosition: Vector3
var hover = false
var selected = false
var HasBeenSet = false

const SYNC_INTERVAL := 0.05
var sync_timer := 0.0

func _ready():
	CameraObject = self.get_parent_node_3d().CameraObject
	WorldObject = self.get_parent_node_3d().WorldObject
	HasBeenSet = true
	
	var newMaterial = StandardMaterial3D.new()
	newMaterial.albedo_color = TargetColor
	ObjectToColor.material_override = TargetMaterial
	InitialPosition = position
	if target_position == Vector3.ZERO:
		target_position = InitialPosition
	

func _process(_delta):
	if HasBeenSet:
		_update_pawn_outline()
		if selected:
			_update_pawn_position()
			sync_timer += _delta
		if sync_timer >= SYNC_INTERVAL:
			sync_timer = 0
			_sync_position(position)
			_sync_position.rpc(position)
		if not selected:
			position = position.lerp(target_position, 12.0 * _delta)

func _update_pawn_position():
	#var spaceState = get_world_3d().direct_space_state
	var mouse = get_viewport().get_mouse_position()
	var from = CameraObject.project_ray_origin(mouse)
	var to = from + CameraObject.project_ray_normal(mouse) * 2000
	
	var newIntersection = PhysicsRayQueryParameters3D.create(from, to)
	var intersection = get_world_3d().direct_space_state.intersect_ray(newIntersection)
	
	if !intersection.is_empty():
		global_position = intersection.position
		#set_position(intersection.position) # this line if for debugging purposes.



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
	if _is_player_associated():
		hover = true

func _on_static_body_3d_mouse_exited():
	hover = false

func _is_player_associated() -> bool:
	if PlayerSettings.color == AssociatedTeam:
		return true
	if PlayerSettings.color == "": #facilitator has free reign
		return true
	else: return false

func _on_reset_pawn_position_button_pressed():
	_sync_position(InitialPosition)
	_sync_position.rpc(InitialPosition)
	print("Position Reset")

var target_position: Vector3 = Vector3.ZERO

@rpc("any_peer", "call_remote", "unreliable")
func _sync_position(newPosition: Vector3):
	target_position = newPosition
