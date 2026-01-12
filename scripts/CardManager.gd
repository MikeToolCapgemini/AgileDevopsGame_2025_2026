extends Control
class_name CardManager
#@export var QuestionObject : RichTextLabel
#@export var AnswerObject : RichTextLabel
#@export var AnswerBackGround : Panel
#@export var UXTagObject : Panel
@export var CardUIManager: CardUIManager
@onready var ImportData = get_node("/root/ImportData")

var active = false
var answerShown : bool = false
var curType
var curKey
var cardTypeData

# Called when the node enters the scene tree for the first time.
func _ready():
	ImportData.sort_data()
	var ImportDataFull = ImportData.duplicate()
	pass # Replace with function body.

func get_state() -> Dictionary:
	var state = {
		"active" : active,
		"answerShown" : answerShown,
		"type" : curType,
		"curKey" : curKey,
		"curTypeData" : cardTypeData
	}
	print("Getting current card state: " + str(state))
	return state

func apply_state(state: Dictionary) -> void:
	active = state["active"]
	curType = state["type"]
	curKey = state["curKey"]
	answerShown = state["answerShown"]
	cardTypeData = state["curTypeData"]
	if active:
		if curType == "action":
			display_action_card(curKey)
		else:
			set_bg_on_type(curType)
			display_default_card(curKey-1)
	_sync_cardshown(active, CardUIManager.AnswerObject.text, CardUIManager.QuestionObject.text)
	_sync_answershown(answerShown)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

@rpc("any_peer")
func set_bg_color(newStyle : Color):
	if !CardUIManager.UXTagObject.visible:
		CardUIManager.UXTagObject.visible = true
	var currentstylebox = CardUIManager.UXTagObject.get_theme_stylebox("panel").duplicate()
	currentstylebox.bg_color = newStyle
	CardUIManager.UXTagObject.add_theme_stylebox_override("panel",currentstylebox)
	print("set color of "," to ", newStyle)

func draw(type):
	active = true
	visible = true
	CardUIManager.bookmark.visible = false
	_sync_answershown(false)
	_sync_answershown.rpc(false)
	## temp draw card function, seperate function from show_panel later (time!!)
	print("-- card drawn --")
	
	print(type)
	set_bg_on_type(type)
	set_bg_on_type.rpc(type)
	# action cards
	var rng = RandomNumberGenerator.new()
	if rng.randi_range(1, 21) >= 19: #19 is defualt
		var roll = rng.randi_range(1,actionDict.size()-1)
		curType = "action"
		curKey = roll
		display_action_card(roll)
		display_action_card.rpc(roll)
		toggle_top_bar(true)
		toggle_top_bar.rpc(true)
	else:
		var d = randi_range(0, cardTypeData.size() - 1)
		print(d)
		display_default_card(d)
		toggle_top_bar(false)
		toggle_top_bar.rpc(false)
		curType = type
		curKey = d+1
		rpc_id(1,"set_current_vars_for_server",active,curType,curKey)
		card_discard(cardTypeData,cardTypeData, type, d+1)
		card_discard.rpc(cardTypeData,cardTypeData, type, d+1)
	print(curType + str(curKey))
	_sync_cardshown.rpc(visible, CardUIManager.AnswerObject.text, CardUIManager.QuestionObject.text)

@rpc("any_peer")
func set_current_vars_for_server(isactive,type,key):
	active = isactive
	curType = type
	curKey = key
	

@rpc("any_peer")
func set_bg_on_type(type):
	var bgColor = GlobalColors.CapgeminiBlue
	if type == "Plan":
		cardTypeData = ImportData.PlanCardData
		bgColor = GlobalColors.PlanningYellow
		set_bg_color(GlobalColors.PlanningYellow)
		set_bg_color.rpc(GlobalColors.PlanningYellow)
	if type == "Code":
		cardTypeData = ImportData.CodeCardData
		bgColor = GlobalColors.CodeRed
		set_bg_color(GlobalColors.CodeRed)
	if type == "Build":
		cardTypeData = ImportData.BuildCardData
		bgColor = GlobalColors.BuildOrange 
		set_bg_color(GlobalColors.BuildOrange)
	if type == "Test":
		cardTypeData = ImportData.TestCardData
		bgColor = GlobalColors.TestGreen 
		set_bg_color(GlobalColors.TestGreen)
	if type == "Release":
		cardTypeData = ImportData.ReleaseCardData
		bgColor = GlobalColors.ReleasePurple 
		set_bg_color(GlobalColors.ReleasePurple)
	if type == "Deploy":
		cardTypeData = ImportData.DeployCardData
		bgColor = GlobalColors.DeployTeal 
		set_bg_color(GlobalColors.DeployTeal)
	if type == "Operate":
		cardTypeData = ImportData.OperateCardData
		bgColor = GlobalColors.OperateBrown 
		set_bg_color(GlobalColors.OperateBrown)
		set_bg_color.rpc(GlobalColors.OperateBrown)
	if type == "Monitor":
		cardTypeData = ImportData.MonitorCardData
		bgColor = GlobalColors.MonitorBlue 
		set_bg_color(GlobalColors.MonitorBlue)
		set_bg_color.rpc(GlobalColors.MonitorBlue)


@rpc("any_peer")
func toggle_top_bar(isaction: bool):
	if isaction:
		CardUIManager.UXTagObject.visible = false
		CardUIManager.ActionTagObject.visible = true
	else:
		CardUIManager.UXTagObject.visible = true
		CardUIManager.ActionTagObject.visible = false

func display_default_card(d):
	var lType = cardTypeData[d]["Basis / Prof"]
	var cType = cardTypeData[d]["Type"]
	var cSubType = cardTypeData[d]["Subtype"]
	var cQuestion = cardTypeData[d]["Question"]
	var cChoiceA = set_card_choice_string("A. ", cardTypeData[d]["ChoiceA"])
	var cChoiceB = set_card_choice_string("B. ", cardTypeData[d]["ChoiceB"])
	var cChoiceC = set_card_choice_string("C. ", cardTypeData[d]["ChoiceC"])
	var cChoiceD = set_card_choice_string("D. ", cardTypeData[d]["ChoiceD"])
	#var cChoiceE = set_card_choice_string("E. ", cardTypeData[d]["ChoiceE"])
	
	var cAnswer = cardTypeData[d]["Answer"]
	var cExplanation = cardTypeData[d]["Toelichting"]
	
	card_setup(cType,cSubType,d+1, cQuestion, cChoiceA, cChoiceB, cChoiceC, cChoiceD,  cAnswer,cExplanation,lType)
	card_setup.rpc(cType,cSubType,d+1, cQuestion, cChoiceA, cChoiceB, cChoiceC, cChoiceD, cAnswer,cExplanation,lType)

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

@rpc("any_peer")
func display_action_card(roll : int):

	print(actionDict[roll] + str(multiplayer.get_unique_id()))
	card_setup("action", "","", actionDict[roll], "", "", "", "", "","","")
	card_setup.rpc("action", "","", actionDict[roll], "", "", "", "", "","","")

func set_card_choice_string(tag, cardTypeData):
	if cardTypeData == "":
		return ""
	return tag + cardTypeData

@rpc("any_peer")
func card_bookmark():
	if curType != null && curKey != null:
		GlobalSettings.BookmarkedCards.append(curType + "_" + str(curKey))
		print(GlobalSettings.BookmarkedCards)
	#SaveSystem.save_game()
	
@rpc("any_peer")
func card_cancel_bookmark():
	if curType != null && curKey != null:
		GlobalSettings.BookmarkedCards.erase(curType + "_" + str(curKey))
		print(GlobalSettings.BookmarkedCards)
	#SaveSystem.save_game()

@rpc("any_peer")
func card_discard(cardTypeData,cardTypeDataVar, cardTypeString, keyVar):
	cardTypeData.erase(keyVar)
	ImportData.card_pop(cardTypeDataVar, keyVar)
	var DiscardedCard = {"cardTypeString": cardTypeString,"keyVar": keyVar}
	GlobalSettings.DataDiscardedCards.append(DiscardedCard)
	print(GlobalSettings.DataDiscardedCards)
	GlobalSettings.DiscardedCards.append(cardTypeString + "_" + str(keyVar))
	#SaveSystem.save_game()

@rpc("any_peer")
func card_setup(type, subtype, nr, question, choiceA, choiceB, choiceC, choiceD, answer,explanation,level):
	print("####")
	print(type)
	set_card_icon(type)
	set_panel_layout(type)
	CardUIManager.TypeNumberTextObject.text = "#" + str(nr)
	CardUIManager.TypeTextObject.text = type
	CardUIManager.LevelTypeTextObject.text = level.to_upper()
	CardUIManager.SubtypeTextObject.text = subtype
	CardUIManager.QuestionObject.text = question
	CardUIManager.AnswerATextObject.text = choiceA
	CardUIManager.AnswerBTextObject.text = choiceB
	CardUIManager.AnswerCTextObject.text = choiceC
	CardUIManager.AnswerDTextObject.text = choiceD
	if answer != "" || explanation != "":
		CardUIManager.AnswerPanel.visible = true
	else:
		CardUIManager.AnswerPanel.visible = false
		
	CardUIManager.AnswerObject.text = answer
	CardUIManager.AnswerFacilitatorTextObject.text = "Answer: " + answer
	if explanation != "" && answer == "":
		CardUIManager.AnswerFacilitatorTextObject.text = "Possible answers:"
	if explanation == "":
		CardUIManager.AnswerExplanationTextObject.visible = false
	else:
		CardUIManager.AnswerExplanationTextObject.visible = true
	CardUIManager.AnswerExplanationTextObject.text = "Explanation: " + explanation
	

func set_card_icon(type):
	if type == "Discussion":
		CardUIManager.QuestionIcon.visible = false
		CardUIManager.DiscussionIcon.visible = true
	if type == "Question":
		CardUIManager.QuestionIcon.visible = true
		CardUIManager.DiscussionIcon.visible = false

func set_panel_layout(type):
	if type == "Discussion":
		CardUIManager.QuestionPanel.visible = false
		CardUIManager.DiscussionPanel.visible = true
		CardUIManager.QuestionObject = CardUIManager.DiscussionPanelTextObject
	if type == "Question":
		CardUIManager.QuestionPanel.visible = true
		CardUIManager.DiscussionPanel.visible = false
		CardUIManager.QuestionObject = CardUIManager.QuestionPanelTextObject
	if type == "action":
		CardUIManager.QuestionPanel.visible = false
		CardUIManager.DiscussionPanel.visible = true
		CardUIManager.QuestionObject = CardUIManager.DiscussionPanelTextObject

@rpc("any_peer")
func _sync_cardshown(state, answer = "-", question = "-"):
	print("syncing card")
	#var tPanel = $"Panel"
	if !CardUIManager.CardPanel.visible:
		CardUIManager.CardPanel.visible = true
	CardUIManager.QuestionObject.text = question
	CardUIManager.AnswerObject.text = answer
	visible = state
	#set_bg_color(bgColor)

@rpc("any_peer")
func _sync_answershown(state):
	CardUIManager.AnswerObject.visible = state
	CardUIManager.AnswerBackground.visible = state

@rpc("call_local")
func close_answer():
	CardUIManager.BookmarkButton.show()
	CardUIManager.CancelBookmarkButton.hide()
	active = false
	visible = false
	#if !$"Panel".visible:
		#$"Panel".visible = true
	_sync_cardshown.rpc(active, "", "")

func show_answer():
	CardUIManager.AnswerObject.visible = true
	CardUIManager.AnswerBackground.visible = true
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
