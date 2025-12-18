extends Node

var SavePath = "user://saves/"
var DefaultData = {}
var SaveData = {}
var currentSave : String = ""
@export var SaveNameField : LineEdit
@export var LoadedSavesContainer : VBoxContainer
@export var pawns_path: NodePath
@export var collapsible : CollapsibleContainer

signal save_requested

func save_game():
	var saveName = get_save_name()
	SaveData["DataDiscardedCards"] = GlobalSettings.DataDiscardedCards
	SaveData["DiscardedCards"] = GlobalSettings.DiscardedCards
	SaveData["BookmarkedCards"] = GlobalSettings.BookmarkedCards
	#SaveData["PawnPositions"] = GlobalSettings.PawnPositions
	if multiplayer.is_server():
		save_game_file(saveName,SaveData)
	else:
		rpc_id(1,"request_saving_game",saveName,SaveData)



@rpc("any_peer")
func request_saving_game(saveName: String,saveData):
	save_game_file(saveName,saveData)

func save_game_file(saveName : String,saveData):
	check_save_dir()
	var savePath
	savePath = SavePath + saveName + ".json"
		
	#if currentSave != saveName:
		#savePath = SavePath + currentSave + ".json"
	#else:
		#savePath = SavePath + saveName + ".json"
		#currentSave = saveName
	var file = FileAccess.open(savePath, FileAccess.WRITE)
	var json = JSON.stringify(saveData)
	
	file.store_string(json)
	file.close()
	print("Game saved...")
	
func loadSaveGames() :
	for btn in %LoadedSaves.get_children():
		btn.queue_free()
	collapsible.open_tween()
	if multiplayer.is_server():
		var saves = get_save_files()
		if saves.size() > 0:
			LoadSaveButtons(saves)
		else:
			print("No Saves Found")
	else:
		rpc_id(1,"request_save_files")



func LoadSaveButtons(saves: Array):
		for save in saves:
			print(save)
			var Loadbutton := Button.new()
			var SaveName: String = save.replace('.json','')
			Loadbutton.text = SaveName
			Loadbutton.pressed.connect(func():
				load_game(save))
			%LoadedSaves.add_child(Loadbutton)

func load_game(saveName : String):
	SaveNameField.text = saveName.replace('.json','')
	if multiplayer.is_server():
		load_game_from_file(saveName)
	else:
		rpc_id(1,"request_file_load",saveName)

@rpc('any_peer')
func request_file_load(saveName: String):
	load_game_from_file(saveName)

func load_game_from_file(saveName : String):
	var save = SavePath + saveName
	var file = FileAccess.open(save, FileAccess.READ)
	if (file == null):
		reset_data()
	var json = file.get_as_text()
	
	var SaveData = JSON.parse_string(json)
	GlobalSettings.DataDiscardedCards = SaveData["DataDiscardedCards"]
	GlobalSettings.DiscardedCards = SaveData["DiscardedCards"]
	GlobalSettings.BookmarkedCards = SaveData["BookmarkedCards"]
	GlobalSettings.sync_self_to_clients()
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

@rpc("any_peer")
func request_save_files():
	var sender_id = multiplayer.get_remote_sender_id()
	var saves = get_save_files()
	rpc_id(sender_id, "receive_save_files", saves)

@rpc("authority")
func receive_save_files(saves:Array):
	LoadSaveButtons(saves)

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


func _on_hide_savedgames_pressed() -> void:
	collapsible.close_tween()
