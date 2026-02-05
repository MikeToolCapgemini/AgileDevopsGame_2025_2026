extends Button

@export var mainPanel : Control
@export var cardManager : CardManager
@export var cardTypeTextEdit : LineEdit
@export var numberTextEdit : LineEdit
var cardType : String
var key : int


func getTextInfo():
	cardType = cardTypeTextEdit.text
	key = int(numberTextEdit.text)

func _on_pressed() -> void:
	getTextInfo()
	cardManager.active = true
	if cardType == "action":
		cardManager.display_action_card(key)
	else:
		cardManager.set_bg_on_type(cardType)
		cardManager.display_default_card(key)
	mainPanel.hide()
	if cardManager.cardTypeData.has(key):
		cardManager._sync_cardshown(cardManager.active, cardManager.CardUIManager.AnswerObject.text, cardManager.CardUIManager.QuestionObject.text)
		cardManager._sync_cardshown.rpc(cardManager.active, cardManager.CardUIManager.AnswerObject.text, cardManager.CardUIManager.QuestionObject.text)
