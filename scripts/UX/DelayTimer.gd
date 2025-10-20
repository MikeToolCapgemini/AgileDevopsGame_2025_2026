extends Node
@export var TimerObject : Node
@export var InterruptUIFac : Node

@rpc("any_peer", "call_local")
func _on_pressed():
	TimerObject.currentTime += 300
	InterruptUIFac.visible = false
