extends Node
@export var TimerObject : Node
@export var InterruptUIFac : Node

@rpc("any_peer", "call_local")
func _on_pressed():
	TimerObject.reset_speed()
	TimerObject.currentTime += 300
	TimerObject._start_animation(TimerObject.currentTime)
	InterruptUIFac.visible = false
