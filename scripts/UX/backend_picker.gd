extends OptionButton

@onready var dropdown: OptionButton = self
@export var login_manager: Login_Manager

func _ready():
	fill_backend_dropdown(dropdown)
	dropdown.item_selected.connect(_on_backend_selected)

func fill_backend_dropdown(option: OptionButton):
	option.clear()

	for key in VPSAuthManager.Backend.keys():
		option.add_item(key, VPSAuthManager.Backend[key])

	option.select(login_manager.auth.backend)

func _on_backend_selected(index):
	login_manager.auth.backend = index as VPSAuthManager.Backend
