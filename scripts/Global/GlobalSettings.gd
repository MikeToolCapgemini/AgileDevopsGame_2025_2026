extends Node

var QuestionsBasic = true
var QuestionsPro = true
var DiscardedCards = []
var DataDiscardedCards = []
var BookmarkedCards = []

# Called when the node enters the scene tree for the first time.
func sync_self_to_clients():
	if multiplayer.is_server():
		var data = serialize_state()
		rpc("receive_sync",data)
		

@rpc("authority")
func receive_sync(data:Dictionary):
	deserialize_state(data)

func serialize_state():
	var data := {}
	for property_name in get_property_list():
		var name = property_name.name
		if name in ["script", "multiplayer"]:
			continue
		data[name] = get(name)
	return data

func deserialize_state(data:Dictionary):
	var properties := {}
	for prop in get_property_list():
		properties[prop.name] = true
	for key in data.keys():
		if properties.has(key):
			set(key, data[key])
