extends Button

@export var collapse : CollapsibleContainer
@export var folded : bool
@export var iconToSwap : FontAwesome
@export var foldedIcon : String
@export var unfoldedIcon : String

func _ready() -> void:
	folded = !collapse.starts_opened
	if iconToSwap != null:
		_swap_icon()

func _swap_icon():
	iconToSwap.icon_name = foldedIcon if folded else unfoldedIcon

func _on_collapse_open():
	collapse.open_tween()
	folded = false
	
func _on_collapse_close():
	collapse.close_tween()
	folded = true
	
func _toggle_collapse():
	if folded:
		collapse.open_tween()
		folded = false
	else:
		collapse.close_tween()
		folded = true
	if iconToSwap != null:
		_swap_icon()
