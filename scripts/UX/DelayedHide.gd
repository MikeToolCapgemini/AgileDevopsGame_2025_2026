class_name DelayedHide
extends Control
var timerRunning = false
@export var delayTime = 3
var timer

func _ready() -> void:
	timer = delayTime
	if visible:
		timerRunning = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if timerRunning:
		timer -= delta
		if timer <= 0:
			timerRunning = false
			visible = false
		print(timer)

func _on_visibility_changed():
	if visible:
		timerRunning = true
	else:
		timerRunning = false
		timer = delayTime
