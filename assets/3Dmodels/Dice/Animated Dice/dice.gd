class_name Dice
extends RigidBody3D

@onready var raycasts = $Raycasts.get_children()

var hover = false
@export var LabelObject : Label
var start_pos
var start_y_rot
@export var roll_strength = 30
var is_rolling := false
@export var returnTimer : Timer
@export var returnSpeed : float = .5

# ---- variables for client interpolation
var target_position : Vector3
var target_rotation : Vector3
var target_lin_vel : Vector3 = Vector3.ZERO
var target_ang_vel : Vector3 = Vector3.ZERO
var interp_speed := 10.0
var lerp_speed := 10.0

@onready var synchronizer := $DiceSynchronizer

signal roll_finished(value)

#outline variables
@export var OutlineMaterial : Material
@export var ObjectToColor : MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if synchronizer:
		synchronizer.connect("synchronized", Callable(self, "_on_synchronizer_synchronized"))
		synchronizer.connect("delta_synchronized", Callable(self, "_on_synchronizer_synchronized"))

	if multiplayer.is_server():
		set_multiplayer_authority(multiplayer.get_unique_id())
	else:
		freeze = true
		sleeping = true
	start_pos = global_position
	start_y_rot = global_rotation.y



func _on_synchronizer_synchronized() -> void:
	target_position = position
	target_rotation = rotation
	target_lin_vel = linear_velocity
	target_ang_vel = angular_velocity

func _process(delta: float) -> void:
	if !multiplayer.is_server():
		global_position = global_position.lerp(target_position, delta * interp_speed)
		global_rotation = global_rotation.lerp(target_rotation, delta * interp_speed)
		
	_update_dice_outline()
	if hover && Input.is_action_just_pressed("mouse_left_click") && !is_rolling:
		if !is_rolling:
			if multiplayer.is_server():
				roll()
			else:
				rpc_id(1, "server_roll")
			#roll()

func _on_roll_finished(value):
	set_label_text(str(value))
	print(value)

func _on_body_3d_mouse_entered():
	hover = true


func _on_body_3d_mouse_exited():
	hover = false

func _update_dice_outline():
	if hover && !is_rolling:
		ObjectToColor.material_overlay = OutlineMaterial #enables the outline via enabling the material shader
	else:
		ObjectToColor.material_overlay = null #Likewise this disables the outline via the same method.

@rpc("any_peer")
func server_roll():
	roll()

func roll():
	sleeping = false
	freeze = false

	transform.origin = start_pos
	transform.origin.y = start_pos.y + .2
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	
	
	transform.basis = Basis(Vector3.RIGHT, randf_range(0,2*PI)) * transform.basis
	transform.basis = Basis(Vector3.UP, randf_range(0,2*PI)) * transform.basis
	transform.basis = Basis(Vector3.FORWARD, randf_range(0,2*PI)) * transform.basis
	
	var thrown_vector = Vector3(randf_range(-1,1),randf_range(-1,1),randf_range(-1,1)).normalized()
	angular_velocity = thrown_vector * roll_strength / 2
	apply_central_impulse(thrown_vector * roll_strength)
	is_rolling = true


func _on_sleeping_state_changed() -> void:
	if is_rolling:
		if sleeping:
			print("dice sleeping")
			var landed_on_side = false
			for raycast in raycasts:
				if raycast.is_colliding():
					roll_finished.emit(raycast.opposite_side)
					is_rolling = false
					landed_on_side = true
					if landed_on_side:
						returnTimer.start()

			if !landed_on_side && is_rolling:
				_tween_return_position()
				_tween_return_rotation()
				roll()

func set_label_text(t):
	LabelObject.text = "[" + t + "]"
	syncDiceCount.rpc(LabelObject.text)

@rpc("any_peer")
func syncDiceCount(t):
	LabelObject.text = t

func _tween_return_position():
	var tween = create_tween()
	tween.tween_property(self, "transform:origin", start_pos, returnSpeed) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)

func _tween_return_rotation():
	var tween = create_tween()
	var target_rotation = global_rotation
	target_rotation.y = start_y_rot
	tween.tween_property(self, "global_rotation", target_rotation, returnSpeed) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)

func _on_return_timer_timeout() -> void:
	_tween_return_position()
	_tween_return_rotation()
	freeze = true
