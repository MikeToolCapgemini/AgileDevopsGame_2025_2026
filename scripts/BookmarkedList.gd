extends Resume
@export var discardedList : RichTextLabel
@export var bookmarkedList : RichTextLabel

func _on_pressed():
	super()
	discardedList.update_text()
	bookmarkedList.update_text()
	
