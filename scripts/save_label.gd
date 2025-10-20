class_name Save_label
extends Control

func _ready() -> void:
	hide()

func _start_save_visual():
	show()
	%SaveLabelTimer.start()


func _on_save_label_timer_timeout() -> void:
	hide()
