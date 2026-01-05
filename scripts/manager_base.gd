extends Node

class_name Manager


func get_state() -> Dictionary:
	push_error("get_state() must be implemented in subclass")
	return {}

func apply_state(state: Dictionary) -> void:
	push_error("apply_state() must be implemented in subclass")
