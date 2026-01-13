extends Button


@export var SecretLineEdit : LineEdit
@export var SwapIcon : FontAwesome
@export var visibleIcon : String
@export var hiddenIcon : String

@export var SecretShown : bool

func _ready() -> void:
	SecretShown = SecretLineEdit.secret

func toggle_secret():
	SecretShown = !SecretShown
	SwapIcon.icon_name = visibleIcon if SecretShown else hiddenIcon
	SecretLineEdit.secret = SecretShown


func _on_pressed() -> void:
	toggle_secret()
