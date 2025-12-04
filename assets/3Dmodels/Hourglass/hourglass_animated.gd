extends Node3D


@onready var animator  := $AnimationPlayer

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
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if timerRunning:
		if currentTime <= 0:
			timerRunning = false
			interrupt()
		currentTime = currentTime - (1*delta)
	
	
	var minutesText = int(currentTime) / 60
	var secondsText = int(currentTime) % 60
	var coolString = "[" + str(minutesText) + ":" + str(secondsText) + "]"
	#print(coolString)
	print(LabelObject.text)
	LabelObject.text = str(coolString)


func _start_animation(target_duration : float):
	_reset_animation()
	var anim_length = animator.get_animation("SandFlow").length
	if target_duration == null:
		target_duration = anim_length
	var speed_scale = anim_length / target_duration
	animator.speed_scale = speed_scale
	animator.play("SandFlow")

func _stop_animation():
	_reset_animation()
	animator.stop()

func _reset_animation():
	animator.play("RESET")

func _on_start_button_pressed():
	timerRunning = true
	_start_animation(newTime)
	pass # Replace with function body.

func _on_reset_button_pressed():
	currentTime = newTime
	_reset_animation()
	pass # Replace with function body.

func _on_stop_button_pressed():
	timerRunning = false
	_stop_animation()
	pass # Replace with function body.

func _on_set_pressed():
	var minToSec = int(EditMinObject.text) * 60
	newTime = int(EditSecObject.text) + minToSec
	currentTime = newTime

func interrupt():
	InterruptUI.visible = true
	pass
