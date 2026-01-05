extends Node

func _input(event):
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		_check_children(get_tree().get_root(), event)

func _check_children(node: Node, event):
	for child in node.get_children():
		if child is Control and child.visible and child.mouse_filter != Control.MOUSE_FILTER_IGNORE:
			var rect = child.get_global_rect()
			if rect.has_point(get_viewport().get_mouse_position()):
				print("Mouse blocked by:", child.name, " within ")
		_check_children(child, event)
