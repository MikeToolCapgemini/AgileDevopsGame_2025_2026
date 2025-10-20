extends Node

var SavePath = "user://savegame.json"
var DefaultData = {}
var SaveData = {}

func save_game():
	var file = FileAccess.open(SavePath, FileAccess.WRITE)
	SaveData["DataDiscardedCards"] = GlobalSettings.DataDiscardedCards
	SaveData["DiscardedCards"] = GlobalSettings.DiscardedCards
	SaveData["BookmarkedCards"] = GlobalSettings.BookmarkedCards
	var json = JSON.stringify(SaveData)
	
	file.store_string(json)
	file.close()
	print("Game saved...")

func load_game():
	var file = FileAccess.open(SavePath, FileAccess.READ)
	if (file == null):
		reset_data()
	var json = file.get_as_text()
	
	var SaveData = JSON.parse_string(json)
	GlobalSettings.DataDiscardedCards = SaveData["DataDiscardedCards"]
	GlobalSettings.DiscardedCards = SaveData["DiscardedCards"]
	GlobalSettings.BookmarkedCards = SaveData["BookmarkedCards"]
	print("Game loaded...")

func reset_data():
	SaveData = DefaultData.duplicate(true)

func _on_load_game_button_pressed():
	load_game()


func _on_save_game_button_pressed() -> void:
	save_game()
