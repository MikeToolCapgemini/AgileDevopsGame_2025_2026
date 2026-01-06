class_name Hourglass
extends Node3D


@onready var animator  := $Node3D/AnimationPlayer
@onready var SpinTimer := $SpinTimer
var paused : bool = false
var currentTime = 600
var newTime = 600
var timerRunning = false
var spin_in_progress := false
var started_at_unix := 0.0
@export var EditMinObject : TextEdit
@export var EditSecObject : TextEdit
@export var InterruptUI : Node
@export var LabelObject : Label

# Called when the node enters the scene tree for the first time.
func _ready():
	SpinTimer.wait_time = animator.get_animation("Spin").length
	pass # Replace with function body.

func get_state() -> Dictionary:
	var state = {
		"currentTime": currentTime,
		"timerRunning": timerRunning,
		"spin_in_progress": spin_in_progress,
		"paused": paused,
		"started_at": started_at_unix,
		"totalTime": newTime
	}
	print("Getting hourglass state")
	return state

func apply_state(state: Dictionary) -> void:
	print("Applying hourglass state")
	currentTime = state["currentTime"]
	timerRunning = state["timerRunning"]
	spin_in_progress = state["spin_in_progress"]
	paused = state["paused"]
	newTime = state["totalTime"]
	started_at_unix = state["started_at"]
	
	_rebuild_animation()
		

func _rebuild_animation():
	#stop everything beforehand just in case
	animator.stop()
	animator.clear_queue()
	SpinTimer.stop()
	
	if paused:
		animator.play("SandFlow")
		animator.pause()
		return
	if spin_in_progress:
		animator.play("Spin")
		SpinTimer.start()
		return
	
	if timerRunning:
		_play_sandflow_from_time()
	


func _play_sandflow_from_time():
	var elapsed := Time.get_unix_time_from_system() - started_at_unix
	var anim_length = animator.get_animation("SandFlow").length

	var remaining_ratio = currentTime / newTime
	var target_speed = anim_length / newTime
	animator.speed_scale = target_speed

	animator.play("SandFlow")
	animator.seek(anim_length * (1.0 - remaining_ratio), true)


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
	if spin_in_progress:
		return # Ignore double press completely
	if animator.current_animation == "RESET":
		return
	if paused:
		setTimerRunning.rpc(true)
		animator.play()
		paused = false
		spin_in_progress = false
		return
	else:
		_reset_animation()
		reset_speed()
		animator.queue("Spin")
		spin_in_progress = true
		animation_duration = target_duration
		SpinTimer.start()
		
		animator.queue("SandFlow")
	
@rpc("any_peer", "call_local")
func _stop_animation():
	paused = true
	SpinTimer.stop()
	animator.pause()
	
@rpc("any_peer", "call_local")
func _reset_animation():
	paused = false
	SpinTimer.stop()
	animator.stop()
	animator.clear_queue()
	animator.play("RESET")

func _on_start_button_pressed():
	if !timerRunning:
		_start_animation.rpc(newTime)
		

@rpc("any_peer", "call_local")
func reset_speed():
	animator.speed_scale = 1

func _on_reset_button_pressed():
	updateTime.rpc(newTime)
	SpinTimer.stop()
	setTimerRunning.rpc(false)
	reset_speed.rpc()
	_reset_animation.rpc()
	spin_in_progress = false
	paused = false
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
	spin_in_progress = false
	setTimerRunning.rpc(true)
	var anim_length = animator.get_animation("SandFlow").length
	if animation_duration == null:
		animation_duration = anim_length
	var speed_scale = anim_length / animation_duration
	animator.speed_scale = speed_scale
	started_at_unix = Time.get_unix_time_from_system()
