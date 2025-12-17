class_name GuideField
extends MarginContainer

var id
@export var Icon : FontAwesome
@export var ColorIcon : PanelContainer
@export var Title : RichTextLabel
@export var Text : RichTextLabel

func _setup_data(icon, color, title, subtext):
	Icon.icon_name = icon
	var stylebox = ColorIcon.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	stylebox.bg_color = color
	ColorIcon.add_theme_stylebox_override("panel",stylebox)
	Title.text = title
	Text.text = subtext
	pass
