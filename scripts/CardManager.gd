class_name CardManager
extends Control

@export var QuestionObject : RichTextLabel
@export var AnswerObject : RichTextLabel
@export var AnswerBackGround : Panel
@export var UXTagObject : Panel
@export var DiscardedCardsTextObject : Node
@onready var ImportData = get_node("/root/ImportData")

var active = false
var curType
var curKey
var cardTypeData

# Called when the node enters the scene tree for the first time.
func _ready():
	ImportData.sort_data()
	var ImportDataFull = ImportData.duplicate()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

@rpc("any_peer")
func set_bg_color(newStyle):
	if !UXTagObject.visible:
		UXTagObject.visible = true
	var currentstylebox = UXTagObject.get_theme_stylebox("panel")
	currentstylebox.bg_color = newStyle.bg_color
	print("set color of "," to ", newStyle)

func draw(type):
	active = true
	visible = true
	$"Panel/Answer".visible = false
	$"Panel/AnswerPanelBG".visible = false
	$Panel/bookmark.visible = false
	_sync_answershown.rpc(false)
	## temp draw card function, seperate function from show_panel later (time!!)
	print("-- card drawn --")
	
	print(type)
	var bgColor = GlobalColors.CapgeminiBlue
	if type == "Plan":
		cardTypeData = ImportData.PlanCardData
		bgColor = GlobalColors.PlanningYellowStyle
		set_bg_color(GlobalColors.PlanningYellowStyle)
		set_bg_color.rpc(GlobalColors.PlanningYellowStyle)
	if type == "Code":
		cardTypeData = ImportData.CodeCardData
		bgColor = GlobalColors.CodeRedStyle
		set_bg_color(GlobalColors.CodeRedStyle)
	if type == "Build":
		cardTypeData = ImportData.BuildCardData
		bgColor = GlobalColors.BuildOrangeStyle
		set_bg_color(GlobalColors.BuildOrangeStyle)
	if type == "Test":
		cardTypeData = ImportData.TestCardData
		bgColor = GlobalColors.TestGreenStyle
		set_bg_color(GlobalColors.TestGreenStyle)
	if type == "Release":
		cardTypeData = ImportData.ReleaseCardData
		bgColor = GlobalColors.ReleasePurpleStyle
		set_bg_color(GlobalColors.ReleasePurpleStyle)
	if type == "Deploy":
		cardTypeData = ImportData.DeployCardData
		bgColor = GlobalColors.DeployTealStyle
		set_bg_color(GlobalColors.DeployTealStyle)
	if type == "Operate":
		cardTypeData = ImportData.OperateCardData
		bgColor = GlobalColors.OperateBrownStyle
		set_bg_color(GlobalColors.OperateBrownStyle)
	if type == "Monitor":
		cardTypeData = ImportData.MonitorCardData
		bgColor = GlobalColors.MonitorBlueStyle
		set_bg_color(GlobalColors.MonitorBlueStyle)
		set_bg_color.rpc(GlobalColors.MonitorBlueStyle)
		
	var d = randi_range(0, cardTypeData.size() - 1)
	print(d)
	var cType = cardTypeData[d]["Type"]
	var cQuestion = cardTypeData[d]["Question"]
	var cChoiceA = set_card_choice_string("A. ", cardTypeData[d]["ChoiceA"])
	var cChoiceB = set_card_choice_string("B. ", cardTypeData[d]["ChoiceB"])
	var cChoiceC = set_card_choice_string("C. ", cardTypeData[d]["ChoiceC"])
	var cChoiceD = set_card_choice_string("D. ", cardTypeData[d]["ChoiceD"])
	var cChoiceE = set_card_choice_string("E. ", cardTypeData[d]["ChoiceE"])
	
	var cAnswer = cardTypeData[d]["Answer"]
	
	# action cards
	var rng = RandomNumberGenerator.new()
	var actionRng = rng.randi_range(1, 21)
	if actionRng >= 19:
		var actionDict = [
			"Your delivery does not fit in the release calendar: skip a turn",
			"Synchronization issue: Move your front pawn back to the square where your second pawn is. If you only have one pawn in the game, you can take your second pawn, and place both pawns on your starting space",
			"Fix security issue together: you and the person after you skip this turn",
			"Process joker: you can keep this card and use it when you want someone else to take your turn and assignment on a next turn",
			"Content joker: you can keep this card and use it when skip a question you don't like and take another question",
			"Management: you have to solve a big problem with high priority, your pawn may switch places with the pawn of another player",
			"Blackmail: A user refuses to close an incident unless you give something extra in return, your front pawn will not move this round",
			"Night shift, skip a turn",
			"New Business Requirement: put the next pawn in the starting square",
			"Test: SIT issues, two steps back",
			"Test: The acceptance test is successful, go directly into production (to your finish)",
			"Management: CICD chain no longer works, put all pawns (of all players) back a whole phase"
			]
		var roll = rng.randi_range(1,actionDict.size()-1)
		UXTagObject.visible = false
		card_setup("action", actionDict[roll], "", "", "", "", "", "")
		card_setup.rpc("action", actionDict[roll], "", "", "", "", "", "")
	else:
		print("###")
		print(cQuestion)
		card_setup(cType, cQuestion, cChoiceA, cChoiceB, cChoiceC, cChoiceD, cChoiceE, cAnswer)
		card_setup.rpc(cType, cQuestion, cChoiceA, cChoiceB, cChoiceC, cChoiceD, cChoiceE, cAnswer)

		set_bg_color.rpc(bgColor)
		curType = type
		curKey = d
		card_discard(cardTypeData,type,d)
		card_discard.rpc(cardTypeData, type, d)
	
	_sync_cardshown.rpc(visible, AnswerObject.text, QuestionObject.text)

func set_card_choice_string(tag, cardTypeData):
	if cardTypeData == "":
		return ""
	return tag + cardTypeData

@rpc
func card_bookmark():
	GlobalSettings.BookmarkedCards.append(curType + "_" + str(curKey))
	print(GlobalSettings.BookmarkedCards)
	SaveSystem.save_game()
	
func card_cancel_bookmark():
	GlobalSettings.BookmarkedCards.erase(curType + "_" + str(curKey))
	print(GlobalSettings.BookmarkedCards)
	SaveSystem.save_game()

@rpc
func card_discard(cardTypeDataVar, cardTypeString, keyVar):
	print("Discarded card")
	cardTypeData.erase(keyVar)
	ImportData.card_pop(cardTypeDataVar, keyVar)
	var DiscardedCard = {"cardTypeString": cardTypeString,"keyVar": keyVar}
	GlobalSettings.DataDiscardedCards.append(DiscardedCard)
	print(GlobalSettings.DataDiscardedCards)
	GlobalSettings.DiscardedCards.append(cardTypeString + "_" + str(keyVar))
	DiscardedCardsTextObject.update_text()
	SaveSystem.save_game()

@rpc("any_peer")
func card_setup(type, question, choiceA, choiceB, choiceC, choiceD, choiceE, answer):
	print("####")
	print(type)
	$"Panel/Type".text = type
	$"Panel/Question".text = question
	$"Panel/ChoiceA".text = choiceA
	$"Panel/ChoiceB".text = choiceB
	$"Panel/ChoiceC".text = choiceC
	$"Panel/ChoiceD".text = choiceD
	$"Panel/Answer".text = answer
	$"Panel2/Panel/AnswerF".text = answer

@rpc("any_peer")
func _sync_cardshown(state, answer = "-", question = "-"):
	print("syncing card")
	#var tPanel = $"Panel"
	if !$"Panel".visible:
		$"Panel".visible = true
	QuestionObject.text = question
	AnswerObject.text = answer
	visible = state
	#set_bg_color(bgColor)

@rpc("any_peer")
func _sync_answershown(state):
	$"Panel/Answer".visible = state
	$"Panel/AnswerPanelBG".visible = state

@rpc("call_local")
func close_answer():
	$Panel2/SaveQuestion.show()
	$Panel2/CancelSave.hide()
	active = false
	visible = false
	if !$"Panel".visible:
		$"Panel".visible = true
	_sync_cardshown.rpc(active, "", "")

func show_answer():
	$"Panel/Answer".visible = true
	$"Panel/AnswerPanelBG".visible = true
	_sync_answershown.rpc(true)



func _on_close_button_pressed():
	close_answer()

func _on_reveal_button_pressed():
	show_answer()

# used in case the demo locks up
@rpc("any_peer")
func _refresh_UI():
	close_answer()

func _on_refresh_ui_pressed():
	print("ui refreshed")
	_refresh_UI.rpc()
