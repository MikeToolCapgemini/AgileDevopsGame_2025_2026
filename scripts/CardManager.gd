extends Control
class_name CardManager
#@export var QuestionObject : RichTextLabel
#@export var AnswerObject : RichTextLabel
#@export var AnswerBackGround : Panel
#@export var UXTagObject : Panel
@export var CardUIManager: CardUIManager
@onready var ImportData = get_node("/root/ImportData")
var actionCardData = ActionCardData.new()

var opened_locally : bool = false
var active = false
var answerShown : bool = false
var curType
var curKey
var cardTypeData
var answerexplanationtext

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(actionCardData)
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
			display_default_card(curKey)
	_sync_cardshown(active, CardUIManager.AnswerObject.text, CardUIManager.QuestionObject.text)

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
		var roll = rng.randi_range(1,actionCardData.actionDict.size())
		curType = "action"
		curKey = roll
		set_current_vars_for_everyone.rpc(active,curType,curKey)
		display_action_card(roll)
		display_action_card.rpc(roll)
		toggle_top_bar(true)
		toggle_top_bar.rpc(true)
	else:
		var keys = cardTypeData.keys()
		if cardTypeData.size() == 0:
			print("No cards left")
			ErrorLabel.show_error("No cards left of this type")
			return
		var d = keys[randi_range(0, keys.size() - 1)]
		#var d = randi_range(0, cardTypeData.size() - 1)
		print(d)
		display_default_card(d)
		toggle_top_bar(false)
		toggle_top_bar.rpc(false)
		curType = type
		curKey = d
		#rpc_id(1,"set_current_vars_for_server",active,curType,curKey)
		set_current_vars_for_everyone.rpc(active,curType,curKey)
		card_discard(cardTypeData,cardTypeData, type, d)
		card_discard.rpc(cardTypeData,cardTypeData, type, d)
	toggle_active.rpc(true)
	visible = true
	print(curType + str(curKey))
	_sync_cardshown.rpc(visible, CardUIManager.AnswerObject.text, CardUIManager.QuestionObject.text)

@rpc("any_peer")
func set_current_vars_for_everyone(isactive,type,key):
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

func display_default_card(d,localonly = false):
	
	if not cardTypeData.has(d):
		ErrorLabel.show_error("no card found for key: %s" % str(d))
		return
	opened_locally = localonly
	
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
	var cQuestionExplanation = cardTypeData[d]["QuestionExplanation"]
	var cAnswerExplanation = cardTypeData[d]["AnswerExplanation"]
	
	card_setup(cType,cSubType,d, cQuestion,cQuestionExplanation, cChoiceA, cChoiceB, cChoiceC, cChoiceD,  cAnswer,cAnswerExplanation,lType)
	if !localonly:
		card_setup.rpc(cType,cSubType,d, cQuestion,cQuestionExplanation, cChoiceA, cChoiceB, cChoiceC, cChoiceD, cAnswer,cAnswerExplanation,lType)

func get_action_by_uid(uid: int) -> Dictionary:
	for entry in actionCardData.actionDict:
		if entry["UID"] == uid:
			return entry
	return {}

@rpc("any_peer")
func display_action_card(roll : int,localonly = false):
	CardUIManager.BookmarkButton.hide()
	CardUIManager.CancelBookmarkButton.hide()
	CardUIManager.RevealButton.hide()
	#CardUIManager.SaveActionButton.show()
	opened_locally = localonly
	var action_text = ""
	var action_card = get_action_by_uid(roll)
	if action_card.size() > 0:
		action_text = action_card["action"]
	
		print(action_text + str(multiplayer.get_unique_id()))
		card_setup("action", "",roll, action_text,"", "", "", "", "", "","","")
		if !localonly:
			card_setup.rpc("action", "",roll, action_text,"", "", "", "", "", "","","")

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
func card_setup(type, subtype, nr, question,qexplanation, choiceA, choiceB, choiceC, choiceD, answer,aexplanation,level):
	CardUIManager.bookmark.visible = false
	#if type != "action":
		#CardUIManager.SaveActionButton.hide()
	#else:
		#CardUIManager.SaveActionButton.show()
	print("####")
	print(type)
	curKey = nr
	curType = type
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
	
	
	
	if answer != "" || qexplanation != "" || aexplanation != "":
		CardUIManager.AnswerPanel.visible = true
	else:
		CardUIManager.AnswerPanel.visible = false
		
	if PlayerSettings.role == "player":
		if aexplanation != "" && answerShown:
			CardUIManager.AnswerPanel.visible = true
		elif qexplanation != "":
			print("Question explanation "+qexplanation)
			CardUIManager.AnswerPanel.visible = true
			CardUIManager.AnswerExplanationTextObject.visible = true
			CardUIManager.AnswerExplanationTextObject.text = "Explanation: " + qexplanation
		else:
			CardUIManager.AnswerPanel.visible = false
			
	if aexplanation != "":
		answerexplanationtext = aexplanation
	CardUIManager.AnswerObject.text = answer
	CardUIManager.AnswerFacilitatorTextObject.text = "Answer: " + answer
	#setting the answer explanation
	if PlayerSettings.role == "facilitator":
		if aexplanation != "" && answer == "":
			answerexplanationtext = aexplanation
			CardUIManager.AnswerFacilitatorTextObject.text = "Possible answers:"
		if aexplanation != "":
			answerexplanationtext = aexplanation
			CardUIManager.AnswerExplanationTextObject.visible = true
			CardUIManager.AnswerExplanationTextObject.text = "Explanation: " + aexplanation
		else:
			CardUIManager.AnswerExplanationTextObject.visible = false
	if answerShown:
		_sync_answershown(answerShown)

	

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
	if opened_locally:
		CardUIManager.PlayerCardContainer.visible = true
	else:
		CardUIManager.PlayerCardContainer.visible = false
	if !CardUIManager.CardPanel.visible:
		CardUIManager.CardPanel.visible = true
	CardUIManager.QuestionObject.text = question
	CardUIManager.AnswerObject.text = answer
	visible = state
	#set_bg_color(bgColor)

@rpc("any_peer")
func _sync_answershown(state):
	answerShown = state
	CardUIManager.AnswerObject.visible = state
	CardUIManager.AnswerBackground.visible = state
	if PlayerSettings.role == "player":
		if answerexplanationtext != "" && answerShown:
			CardUIManager.AnswerPanel.visible = true
			CardUIManager.AnswerExplanationTextObject.visible = true
			CardUIManager.AnswerExplanationTextObject.text = "Explanation: " + answerexplanationtext
	
	if answerexplanationtext != "":
		CardUIManager.AnswerPanel.visible = state

@rpc("call_local")
func close_answer():
	CardUIManager.BookmarkButton.show()
	CardUIManager.RevealButton.show()
	CardUIManager.CancelBookmarkButton.hide()
	if !opened_locally:
		toggle_active.rpc(false)
		_sync_cardshown.rpc(active, "", "")
	visible = false
	#if !$"Panel".visible:
		#$"Panel".visible = true
	curType = null
	curKey = null
	active = false

@rpc("any_peer","call_local")
func toggle_active(toggle: bool):
	active = toggle

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


func _on_use_card_pressed() -> void:
	active = true
	if curType == "action":
		display_action_card(int(curKey))
	else:
		set_bg_on_type(curType)
		display_default_card(int(curKey))
	PlayerSettings.remove_action_card.rpc(PlayerSettings.color,int(curKey))
	_sync_cardshown(active, CardUIManager.AnswerObject.text, CardUIManager.QuestionObject.text)
	_sync_cardshown.rpc(active, CardUIManager.AnswerObject.text, CardUIManager.QuestionObject.text)
