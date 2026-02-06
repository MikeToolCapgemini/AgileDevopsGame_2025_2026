extends Node

signal data_ready

var PATH_JSON_DATA = "res://Data/csvjson.json"
var WEB_PATH = "Data/csvjson.json"
var jsonLoader = json_loader.new()

var CardData : Array = []
var data_loaded := false

var PlanCardData : Dictionary = {}
var CodeCardData : Dictionary = {}
var BuildCardData : Dictionary = {}
var TestCardData : Dictionary = {}
var ReleaseCardData : Dictionary = {}
var DeployCardData : Dictionary = {}
var OperateCardData : Dictionary = {}
var MonitorCardData : Dictionary = {}

var AllCardData = [
	PlanCardData, CodeCardData, BuildCardData, TestCardData,
	ReleaseCardData, DeployCardData, OperateCardData, MonitorCardData
]


func _ready():
	add_child(jsonLoader)
	jsonLoader.data_ready.connect(_on_cards_loaded)
	jsonLoader.load_json(PATH_JSON_DATA, WEB_PATH)

func _on_cards_loaded(data):
	CardData = data
	import_data()


func import_data():

	for d in AllCardData:
		d.clear()

	for Card in CardData:
		if Card["Type"] != "Question" and Card["Type"] != "Discussion":
			continue

		match Card["Subtype"]:
			"Plan":
				PlanCardData[int(Card["UID"])] = Card

			"Build":
				BuildCardData[int(Card["UID"])] = Card

			"Test":
				TestCardData[int(Card["UID"])] = Card

			"Deploy":
				DeployCardData[int(Card["UID"])] = Card

			"Code":
				CodeCardData[int(Card["UID"])] = Card

			"Release":
				ReleaseCardData[int(Card["UID"])] = Card

			"Operate":
				OperateCardData[int(Card["UID"])] = Card

			"Monitor":
				MonitorCardData[int(Card["UID"])] = Card


@rpc("any_peer","call_local")
func sort_data():
	import_data()

	if !GlobalSettings.QuestionsBasic:
		for cardDict in AllCardData:
			sort_data_on_type("b", cardDict)

	if !GlobalSettings.QuestionsPro:
		for cardDict in AllCardData:
			sort_data_on_type("p", cardDict)

	if GlobalSettings.DataDiscardedCards.size() > 0:
		for entry in GlobalSettings.DataDiscardedCards:
			var type_string = entry.get("cardTypeString", null)
			var dataDict = get_dict_on_subtype(type_string)
			card_pop(dataDict, entry.get("keyVar"))


func get_dict_on_subtype(subtype):
	match subtype:
		"Plan": return PlanCardData
		"Code": return CodeCardData
		"Build": return BuildCardData
		"Test": return TestCardData
		"Release": return ReleaseCardData
		"Deploy": return DeployCardData
		"Operate": return OperateCardData
		"Monitor": return MonitorCardData


func sort_data_on_type(type, dict):
	for key in dict.keys():
		if dict[key]["Basis / Prof"] == type:
			dict.erase(key)


func card_pop(dict, key):
	dict.erase(key)
