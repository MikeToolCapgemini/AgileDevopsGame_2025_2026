extends Button
class_name CardButton

@export var mainPanel : Control
@export var cardManager : CardManager
@export var cardTypevar : String
@export var cardKey : int

func pressed_using_vars():
	_call_cards_using_vars(cardTypevar,cardKey)

func _call_cards_using_vars(cardtype,cardKey):
	cardManager.active = true
	if cardtype == "action":
		print("Displaying action Card")
		cardManager.display_action_card(cardKey,true)
	else:
		cardManager.set_bg_on_type(cardtype)
		cardManager.display_default_card(cardKey,true)
	mainPanel.hide()
	cardManager.CardUIManager.CardPanel.visible = true 
	cardManager._sync_cardshown(true, cardManager.CardUIManager.AnswerObject.text, cardManager.CardUIManager.QuestionObject.text)
