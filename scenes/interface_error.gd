extends CanvasLayer


@export var error_label : Error_Label

func show_error(err : String):
		error_label.edit_text("err")
		error_label.show()
