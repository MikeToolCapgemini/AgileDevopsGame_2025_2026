extends Node
class_name json_loader

signal data_ready(data)

var data : Array = []
var data_loaded := false

func load_json(path_local: String, path_web: String) -> void:
	if OS.has_feature("web"):
		load_json_web(path_web)
	else:
		load_json_local(path_local)
		finish_loading()


func finish_loading():
	data_loaded = true
	data_ready.emit(data)


func load_json_local(path: String):
	var text := FileAccess.get_file_as_string(path)
	if text == "" or text == null:
		data = []
		finish_loading()
		return
	var parsed = JSON.parse_string(text)
	data = Array(parsed) if parsed != null else []
	finish_loading()


func get_web_base() -> String:
	var protocol := "http"
	var host := "localhost"
	if OS.has_feature("web"):
		var js := JavaScriptBridge
		protocol = "https" if js.eval("window.location.protocol") == "https:" else "http"
		host = js.eval("window.location.hostname")
	return "%s://%s/" % [protocol, host]


func load_json_web(path_web: String):
	var url = get_web_base() + path_web + "?t=" + str(Time.get_unix_time_from_system())
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_web_loaded)
	if http.request(url) != OK:
		data = []
		finish_loading()


func _on_web_loaded(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		data = []
		finish_loading()
		return
	var text = body.get_string_from_utf8()
	var parsed = JSON.parse_string(text)
	data = Array(parsed) if parsed != null else []
	finish_loading()


func ensure_ready() -> void:
	if data_loaded:
		return
	await data_ready
