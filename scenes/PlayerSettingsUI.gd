extends Control


@export var RoleTextField : RichTextLabel
@export var ColorTextField : RichTextLabel

func Show_Settings():
	RoleTextField.text = PlayerSettings.role
	ColorTextField.text = PlayerSettings.color
