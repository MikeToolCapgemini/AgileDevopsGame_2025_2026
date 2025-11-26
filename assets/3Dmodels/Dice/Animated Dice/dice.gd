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

signal roll_finished(value)

#outline variables
@export var OutlineMaterial : Material
@export var ObjectToColor : MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_pos = global_position
	start_y_rot = global_rotation.y


func _process(delta: float) -> void:
	_update_dice_outline()
	if hover && Input.is_action_just_pressed("mouse_left_click") && !is_rolling:
		if !is_rolling:
			roll()

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
