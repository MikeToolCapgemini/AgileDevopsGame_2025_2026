extends RigidBody3D

@onready var raycasts = $Raycasts.get_children()

var hover = false

var start_pos
@export var roll_strength = 30
var is_rolling := false
@export var returnTimer : Timer
@export var returnSpeed : float = .5

signal roll_finished(value)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_pos = global_position


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		if !is_rolling:
			roll()

func _on_roll_finished(value):
	print(value)

#func _input(event):
	#if event is InputEventMouseButton and event.pressed and event.button_index == 1:

			

func _on_body_3d_mouse_entered():
	hover = true
	pass # Replace with function body.


func _on_body_3d_mouse_exited():
	hover = false
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("Launch") && !is_rolling:
		#roll()

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
	
	var thrown_vector = Vector3(randf_range(-1,1),0,randf_range(-1,1)).normalized()
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
				roll()

func _on_return_timer_timeout() -> void:
	var tween = create_tween()
	tween.tween_property(self, "transform:origin", start_pos, returnSpeed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
