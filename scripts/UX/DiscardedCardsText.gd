extends RichTextLabel

@export var cardType : String #make enum

func update_text():
	var newText = ""
	if cardType == "d":
		for each in GlobalSettings.DiscardedCards:
			newText += each + ", "
		text = newText
	if cardType == "b":
		for each in GlobalSettings.BookmarkedCards:
			newText += each + ", "
		text = newText
