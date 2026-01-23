extends Node
class_name ServerInfoRequester

var server_address: String = ""
var server_port: int = 0

func _ready():
	var http := HTTPRequest.new()
	add_child(http)

	http.connect("request_completed", Callable(self, "_on_request_completed"))

	# Build dynamic URL based on host
	var protocol := "http"
	var host := "localhost"  # fallback for editor / desktop

	if OS.has_feature("web"):
		var js := Engine.get_singleton("JavaScript")
		protocol = "https" if js.eval("window.location.protocol") == "https:" else "http"
		host = js.eval("window.location.hostname")

	var url := "%s://%s/server-info.json" % [protocol, host]
	print("Fetching server info from: ", url)
	
	var err := http.request(url)
	if err != OK:
		push_error("HTTPRequest failed to start: " + str(err))


func _on_request_completed(result: int, response_code: int, headers: Array, body: PackedByteArray):
	if response_code == 200:
		var parser := JSON.new()
		var json_result = parser.parse_string(body.get_string_from_utf8())

		if json_result.error == OK:
			var data = json_result.result
			server_address = str(data.get("address", ""))
			server_port = int(data.get("port", 0))
			print("Server info received:", server_address, server_port)

			# Now you can connect your WebSocket here
			# connect_to_server()
		else:
			push_error("Failed to parse JSON: " + str(json_result.error_string))
	else:
		push_error("Failed to get server info. HTTP code: " + str(response_code))
