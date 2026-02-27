extends Node
class_name ActionCardData

var PATH_JSON_DATA = "res://Data/actions.json"
var WEB_PATH = "Data/actions.json"
var jsonLoader = json_loader.new()

var actionDict : Array = []


func _ready():
	add_child(jsonLoader)
	jsonLoader.data_ready.connect(_on_cards_loaded)
	jsonLoader.load_json(PATH_JSON_DATA, WEB_PATH)

func _on_cards_loaded(data):
	actionDict = data
