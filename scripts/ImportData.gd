extends Node

signal data_ready

var PATH_JSON_DATA = "res://Data/csvjson.json"
var WEB_PATH = "Data/csvjson.json"

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


func ensure_ready():
	if data_loaded:
		return
	await data_ready


func _ready():
	load_json_data()


func load_json_data():
	if OS.has_feature("web"):
		load_json_web()
	else:
		load_json_local()
		finish_loading()


func finish_loading():
	import_data()
	data_loaded = true
	emit_signal("data_ready")


func load_json_local():
	var json_as_text = FileAccess.get_file_as_string(PATH_JSON_DATA)

	if json_as_text == "" or json_as_text == null:
		CardData = []
		return

	var json = JSON.parse_string(json_as_text)

	if json == null:
		CardData = []
		return

	CardData = Array(json)


func get_web_base() -> String:
	var protocol := "http"
	var host := "localhost"

	if OS.has_feature("web"):
		var js := JavaScriptBridge
		protocol = "https" if js.eval("window.location.protocol") == "https:" else "http"
		host = js.eval("window.location.hostname")

	return "%s://%s/" % [protocol, host]


func load_json_web():
	var base = get_web_base()
	var url = base + WEB_PATH + "?t=" + str(Time.get_unix_time_from_system())

	var http = HTTPRequest.new()
	add_child(http)

	http.request_completed.connect(_on_web_json_loaded)

	if http.request(url) != OK:
		load_json_local()
		finish_loading()


func _on_web_json_loaded(result, response_code, headers, body):

	var text = body.get_string_from_utf8()

	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		load_json_local()
		finish_loading()
		return

	var json = JSON.parse_string(text)

	if json == null:
		load_json_local()
		finish_loading()
		return

	CardData = Array(json)
	finish_loading()


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
