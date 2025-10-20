extends Control
var timerRunning = false
var delayTime = 3

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if timerRunning:
		delayTime -= delta
		if delayTime <= 0:
			timerRunning = false
			visible = false
		print(delayTime)

func _on_visibility_changed():
	if visible:
		timerRunning = true
	else:
		timerRunning = false
		delayTime = 3
