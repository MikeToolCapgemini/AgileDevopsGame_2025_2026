extends Node
class_name WebTokenManager

# Signals
signal token_loaded(token_data)

# Internal state
var token_data : Dictionary = {}


func generate_token(username: String) -> Dictionary:
	var timestamp = Time.get_unix_time_from_system()
	var raw = "%s:%d" % [username, timestamp]
	var context := HashingContext.new()
	context.start(HashingContext.HASH_MD5)
	context.update(raw.to_utf8())
	var digest : PackedByteArray = context.finish()
	var token = digest.hex_encode()
	token_data = {
		"token": token,
		"timestamp": timestamp,
		"username": username
	}
	return token_data


func save_token(token):
	if not OS.has_feature("web"):
		return
	var js := JavaScriptBridge
	var json_string = JSON.stringify(token)
	js.eval("localStorage.setItem('login_token', '%s');" % json_string)

func load_token() -> Dictionary:
	if not OS.has_feature("web"):
		return {}
	var js := JavaScriptBridge
	var json_string = js.eval("localStorage.getItem('login_token');")
	if json_string == null or json_string == "":
		return {}
	var parsed = JSON.parse_string(json_string)
	token_data = parsed if parsed != null else {}
	emit_signal("token_loaded", token_data)
	return token_data


func is_token_valid(valid_seconds: int = 86400) -> bool:
	if token_data.is_empty():
		return false
	var now = Time.get_unix_time_from_system()
	return now - int(token_data.get("timestamp", 0)) <= valid_seconds


func clear_token():
	token_data = {}
	if OS.has_feature("web"):
		var js := JavaScriptBridge
		js.eval("localStorage.removeItem('login_token');")
