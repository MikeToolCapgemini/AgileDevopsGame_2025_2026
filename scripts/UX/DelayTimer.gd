extends Node
@export var TimerObject : Node
@export var InterruptUIFac : Node

@rpc("any_peer", "call_local")
func _on_pressed():
	TimerObject.reset_speed.rpc()
	TimerObject.updateTime.rpc(300)
	TimerObject._start_animation.rpc(TimerObject.currentTime)
	InterruptUIFac.visible = false
