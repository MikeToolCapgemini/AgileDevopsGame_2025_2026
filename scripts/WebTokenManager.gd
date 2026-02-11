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
	context.update(raw.to_utf8_buffer())

	var digest : PackedByteArray = context.finish()
	var token = digest.hex_encode()

	token_data = {
		"token": token,
		"timestamp": timestamp,
		"username": username
	}

	return token_data

func save_token_cookie(token: Dictionary, days: int = 1) -> void:
	if not OS.has_feature("web"):
		return
	var json_string = JSON.stringify(token)

	# Cookie valid for 7 days
	var js_code = """
		var value = '%s';
		var date = new Date();
		date.setTime(date.getTime() + (%d*24*60*60*1000));
		document.cookie = "login_token=" + encodeURIComponent(value) + 
			"; expires=" + date.toUTCString() + "; path=/";
	""" % [json_string,days]

	JavaScriptBridge.eval(js_code)

func load_token_cookie() -> Dictionary:
	if not OS.has_feature("web"):
		return {}

	var js_code = """
	(() => {
		function getCookie(name) {
			let match = document.cookie.match(new RegExp('(^| )' + name + '=([^;]+)'));
			if (match) return decodeURIComponent(match[2]);
			return "";
		}
		return getCookie("login_token");
		})()
	"""

	var json_string = JavaScriptBridge.eval(js_code)

	if json_string == null or json_string == "":
		return {}

	var parsed = JSON.parse_string(json_string)
	token_data = parsed if parsed != null else {}

	token_loaded.emit(token_data)
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


func try_get_valid_token() -> Dictionary:
	# Only works on web
	if not OS.has_feature("web"):
		return { "success": false, "reason": "not_web" }

	var token_info = load_token_cookie()

	if token_info.is_empty():
		return { "success": false, "reason": "no_token" }

	if not is_token_valid():
		clear_token_cookie()
		return { "success": false, "reason": "expired" }

	var username = token_info.get("username", "")
	if username == "":
		clear_token_cookie()
		return { "success": false, "reason": "malformed" }

	return {
		"success": true,
		"username": username,
		"token": token_info.get("token", "")
	}


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

func clear_token_cookie() -> void:
	if not OS.has_feature("web"):
		return
	
	var js_code = """
		document.cookie = "login_token=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";
	"""
	JavaScriptBridge.eval(js_code)
