class_name Interrupt

extends Node
@export var InterruptUIPlayers : Node
@export var InterruptUIFac : Node
var interupt_active : bool

func get_state() -> Dictionary:
	
	return {
		"interupt_active" : interupt_active
	}

func apply_state(state: Dictionary) -> void:
	interupt_active = state["interupt_active"]
	if interupt_active:
		show_interrupt()

func _on_pressed():
	show_interrupt.rpc()
	pass # Replace with function body.

@rpc("any_peer","call_local")
func show_interrupt():
	interupt_active = true
	InterruptUIPlayers.visible = true
	InterruptUIFac.visible = false
