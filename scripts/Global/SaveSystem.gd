extends Node

var SavePath = "user://saves/"
var DefaultData = {}
var SaveData = {}
var currentSave
@export var SaveNameField : LineEdit

func _ready() -> void:
	var saves = get_save_files()
	if saves.size() > 0:
		print("exsisting saves ", saves)
	else:
		print("No Saves Found")

func save_game():
	check_save_dir()
	var saveName = get_save_name()
	var savePath
	if currentSave != saveName:
		savePath = SavePath + currentSave + ".json"
	else:
		savePath = SavePath + saveName + ".json"
		currentSave = saveName
	var file = FileAccess.open(savePath, FileAccess.WRITE)
	SaveData["DataDiscardedCards"] = GlobalSettings.DataDiscardedCards
	SaveData["DiscardedCards"] = GlobalSettings.DiscardedCards
	SaveData["BookmarkedCards"] = GlobalSettings.BookmarkedCards
	var json = JSON.stringify(SaveData)
	
	file.store_string(json)
	file.close()
	print("Game saved...")
	
func loadSaveGames() :
	pass

func load_game(saveName : String):
	var save = SavePath + saveName + ".json"
	var file = FileAccess.open(save, FileAccess.READ)
	if (file == null):
		reset_data()
	var json = file.get_as_text()
	
	var SaveData = JSON.parse_string(json)
	GlobalSettings.DataDiscardedCards = SaveData["DataDiscardedCards"]
	GlobalSettings.DiscardedCards = SaveData["DiscardedCards"]
	GlobalSettings.BookmarkedCards = SaveData["BookmarkedCards"]
	print("Game loaded...")

func check_save_dir():
	var persist_dir := DirAccess.open("user://")
	if persist_dir:
		if persist_dir.dir_exists("saves"):
			pass
		else:
			persist_dir.make_dir("saves")
	else:
		printerr("An error occurred trying to open persistent user:// directory. Error: ", DirAccess.get_open_error())

func get_save_files() -> Array:
	check_save_dir()
	var dir_path = "user://saves"
	var save_files = []
	var dir = DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if  file_name.ends_with(".json"):
				save_files.append(file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	return save_files

func get_save_name() -> String:
	var saveName
	if SaveNameField.text != "":
		saveName = SaveNameField.text
	else:
		var number = randi()% 100
		saveName = "savegame"+ str(number)
	return saveName

func reset_data():
	SaveData = DefaultData.duplicate(true)

func _on_load_game_button_pressed():
	loadSaveGames()


func _on_save_game_button_pressed() -> void:
	save_game()
