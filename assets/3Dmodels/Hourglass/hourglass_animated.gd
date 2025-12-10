extends Node3D


@onready var animator  := $Node3D/AnimationPlayer
@onready var SpinTimer := $SpinTimer

var currentTime = 900
var newTime = 900
var timerRunning = false
@export var EditMinObject : TextEdit
@export var EditSecObject : TextEdit
@export var InterruptUI : Node
@export var LabelObject : Label

# Called when the node enters the scene tree for the first time.
func _ready():
	var tempV = 3
	currentTime = tempV
	newTime = tempV
	SpinTimer.wait_time = animator.get_animation("Spin").length
	pass # Replace with function body.


	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if timerRunning:
		if currentTime <= 0:
			setTimerRunning.rpc(false)
		currentTime = currentTime - (1*delta)
	
	
	var minutesText = int(currentTime) / 60
	var secondsText = int(currentTime) % 60
	var coolString = "[" + str(minutesText) + ":" + str(secondsText) + "]"
	LabelObject.text = str(coolString)


var animation_duration : float
@rpc("any_peer", "call_local")
func _start_animation(target_duration : float):
	animator.queue("Spin")
	animation_duration = target_duration
	SpinTimer.start()
	
	animator.queue("SandFlow")
	
@rpc("any_peer", "call_local")
func _stop_animation():
	animator.pause()
	
@rpc("any_peer", "call_local")
func _reset_animation():
	animator.play("RESET")

func _on_start_button_pressed():
	_start_animation.rpc(newTime)

@rpc("any_peer", "call_local")
func reset_speed():
	animator.speed_scale = 1

func _on_reset_button_pressed():
	updateTime.rpc(newTime)
	setTimerRunning.rpc(false)
	reset_speed.rpc()
	_reset_animation.rpc()
	pass # Replace with function body.

func _on_stop_button_pressed():
	setTimerRunning.rpc(false)
	_stop_animation.rpc()
	pass # Replace with function body.

@rpc("any_peer","call_local")
func setTimerRunning(running: bool):
	timerRunning = running

@rpc("any_peer", "call_local")
func updateTime(updatedTime : float):
	newTime = updatedTime
	currentTime = newTime

func _on_set_pressed():
	var minToSec = int(EditMinObject.text) * 60
	updateTime.rpc(int(EditSecObject.text) + minToSec)

func interrupt():
	if PlayerSettings.role == "facilitator":
		InterruptUI.visible = true


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	print(anim_name + " is finished")
	if anim_name == "SandFlow":
		interrupt()


func _on_spin_timer_timeout() -> void:
	setTimerRunning.rpc(true)
	var anim_length = animator.get_animation("SandFlow").length
	if animation_duration == null:
		animation_duration = anim_length
	var speed_scale = anim_length / animation_duration
	animator.speed_scale = speed_scale
