extends Control

@export var cardManager : CardManager
@export var ActiongridList : GridContainer
@export var mainPanel : Control
@export var CardButtonTemplate : CardButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	fillActionCardList()


func _on_visibility_changed():
	if is_visible_in_tree():
		fillActionCardList()
		print("Actioncards list is now visible!")

func fillActionCardList():
	print(PlayerSettings.actionCards)
	for child in ActiongridList.get_children():
		if child != CardButtonTemplate:
			child.queue_free()
	if PlayerSettings.actionCards.size() <= 0:
		CardButtonTemplate.hide()
	for cardData in PlayerSettings.actionCards:
		var button : CardButton
		if ActiongridList.get_child_count() == 0:
			button = CardButtonTemplate
		else:
			button = CardButtonTemplate.duplicate() as CardButton
			ActiongridList.add_child(button)

		button.mainPanel = mainPanel
		button.cardManager = cardManager
		button.text = cardData.type + "_" + str(cardData.key)
		button.cardTypevar = cardData.type
		button.cardKey = cardData.key
		button.show()
