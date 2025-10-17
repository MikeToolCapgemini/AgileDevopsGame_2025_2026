extends Node
@export var InterruptUIPlayers : Node
@export var InterruptUIFac : Node

func _on_pressed():
	show_interrupt.rpc()
	pass # Replace with function body.

@rpc("any_peer","call_local")
func show_interrupt():
	InterruptUIPlayers.visible = true
	InterruptUIFac.visible = false
