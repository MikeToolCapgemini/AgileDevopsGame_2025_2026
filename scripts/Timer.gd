extends Node3D

var currentTime = 900
var newTime = 900
var timerRunning = false
@export var LabelObject : Label
@export var EditMinObject : TextEdit
@export var EditSecObject : TextEdit
@export var InterruptUI : Node

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
	
	#var timeTextConvert = "%.2f" % currentTime
	var minutesText = int(currentTime) / 60
	var secondsText = int(currentTime) % 60
	var coolString = "[" + str(minutesText) + ":" + str(secondsText) + "]"
	LabelObject.text = str(coolString)

func _on_start_button_pressed():
	timerRunning = true
	pass # Replace with function body.

func _on_reset_button_pressed():
	currentTime = newTime
	pass # Replace with function body.

func _on_stop_button_pressed():
	timerRunning = false
	pass # Replace with function body.

func _on_set_pressed():
	var minToSec = int(EditMinObject.text) * 60
	newTime = int(EditSecObject.text) + minToSec
	currentTime = newTime

func interrupt():
	InterruptUI.visible = true
	pass
