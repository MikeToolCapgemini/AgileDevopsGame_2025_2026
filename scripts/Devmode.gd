extends Node

var DevModeEnabled : bool = false

func _ready():
	get_tree().node_added.connect(_on_node_added)

func _on_node_added(node: Node):
	if node.is_in_group("DevmodeUI"):
		if node is CanvasItem or node is VisualInstance3D:
			node.visible = DevModeEnabled

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("DevMode"):
		set_devmode(!DevModeEnabled)

func set_devmode(enabled: bool):
	if DevModeEnabled == enabled:
		return

	DevModeEnabled = enabled
	toggle_devmode_UI(enabled)

	if enabled:
		show_enable_notif()
	else:
		show_disable_notif()

		

#this is toggling everything you would only want visual when devmode is active
func toggle_devmode_UI(visible : bool):
	for node in get_tree().get_nodes_in_group("DevmodeUI"):
		if node is CanvasItem:
			node.visible = visible
		elif node is VisualInstance3D:
			node.visible = visible
	

func show_enable_notif():
	ErrorLabel.show_error("Devmode Enabled")

func show_disable_notif():
	ErrorLabel.show_error("Devmode Disabled")
