extends Control

signal data_ready

var PATH_JSON_DATA = "res://Data/slideouts.json"
var WEB_PATH = "Data/slideouts.json"
var SlideOutData : Array = []
var data_loaded := false

@export var GuideName : String
@export var GuideGrid : GridContainer

var guideFieldPrefab = preload("res://prefabs/guide_field.tscn")


func ensure_ready():
	if data_loaded:
		return
	await data_ready


func _ready() -> void:
	load_json_data()


func load_json_data():
	if OS.has_feature("web"):
		load_json_web()
	else:
		load_json_local()
		finish_loading()


func finish_loading():
	setup_fields()
	data_loaded = true
	emit_signal("data_ready")


func load_json_local():
	var json_as_text = FileAccess.get_file_as_string(PATH_JSON_DATA)

	if json_as_text == "" or json_as_text == null:
		SlideOutData = []
		return

	var json = JSON.parse_string(json_as_text)

	if json == null:
		SlideOutData = []
		return

	SlideOutData = Array(json)


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

	SlideOutData = Array(json)
	finish_loading()


func setup_fields():
	for guide in GuideGrid.get_children():
		guide.queue_free()

	for SlideOut in SlideOutData:
		if SlideOut["GuideName"] == GuideName:
			var NrOfFields : int = int(SlideOut["NrFields"])
			for i in range(1, NrOfFields + 1):
				var guidefield = guideFieldPrefab.instantiate()
				GuideGrid.add_child(guidefield)
				var GuideFieldManager : GuideField = guidefield as GuideField
				GuideFieldManager.id = i
				var GuideIcon = SlideOut["IconField #%d" % i]
				var GuideColor = SlideOut["ColorIconField #%d" % i]
				var GuideTitle = SlideOut["Title Field #%d" % i]
				var GuideSubtext = SlideOut["Text Field #%d" % i]
				GuideFieldManager._setup_data(GuideIcon, GuideColor, GuideTitle, GuideSubtext)
