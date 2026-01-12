class_name Editable_timed_panel
extends DelayedHide


@export var textLabel : RichTextLabel

func edit_text(newtext):
	textLabel.text = newtext
