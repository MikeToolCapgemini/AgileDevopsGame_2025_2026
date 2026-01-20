extends Node

var SavePath = "user://saves/"
var DefaultData = {}
var SaveData = {}
var currentSave : String = ""
@export var SaveNameField : LineEdit
@export var LoadedSavesContainer : VBoxContainer
@export var Pawnmanager : PawnManager
@export var collapsible : CollapsibleContainer
@export var saveNotificationUI : Control
@export var saveNotifText : RichTextLabel

@export var SaveOverWriteInterface : save_overwrite_UI

signal save_completed

func _ready() -> void:
	save_completed.connect(_on_save_completed)

func save_game(saveName: String = ""):
	Pawnmanager.save_pawn_positions()
	if saveName == "":
		saveName = get_save_name()
	SaveData["DataDiscardedCards"] = GlobalSettings.DataDiscardedCards
	SaveData["DiscardedCards"] = GlobalSettings.DiscardedCards
	SaveData["BookmarkedCards"] = GlobalSettings.BookmarkedCards
	SaveData["PawnPositions"] = GlobalSettings.PawnPositions
	if multiplayer.is_server():
		save_game_file(saveName,SaveData)
	else:
		rpc_id(1,"request_saving_game",saveName,SaveData)

func get_save_json() -> String:
	SaveData["DataDiscardedCards"] = GlobalSettings.DataDiscardedCards
	SaveData["DiscardedCards"] = GlobalSettings.DiscardedCards
	SaveData["BookmarkedCards"] = GlobalSettings.BookmarkedCards
	SaveData["PawnPositions"] = GlobalSettings.PawnPositions

	return JSON.stringify(SaveData)


@rpc("any_peer")
func request_saving_game(saveName: String,saveData):
	save_game_file(saveName,saveData)

func save_game_file(saveName : String,saveData, checkname := true):
	check_save_dir()
	var savePath
	savePath = SavePath + saveName + ".json"
	if checkname:
		if check_if_saveName_exists(savePath):
			SaveOverWriteInterface._show_overwrite_UI(self,saveName,saveData)
			return
	
	
		
	#if currentSave != saveName:
		#savePath = SavePath + currentSave + ".json"
	#else:
		#savePath = SavePath + saveName + ".json"
		#currentSave = saveName
	var file = FileAccess.open(savePath, FileAccess.WRITE)
	var json = JSON.stringify(saveData)
	
	file.store_string(json)
	file.close()
	emit_signal("save_completed", saveName)


func _on_save_completed(saveName: String) -> void:
	if saveNotificationUI != null:
		saveNotificationUI.show()
		saveNotifText.text = "Saved game %s!" % saveName
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
		load_game_from_file(saveName,1)
	else:
		rpc_id(1,"request_file_load",saveName,multiplayer.get_unique_id())

@rpc('any_peer')
func request_file_load(saveName: String,sender_id):
	load_game_from_file(saveName,sender_id)

func load_game_from_file(saveName : String,sender_id):
	var save = SavePath + saveName
	var file = FileAccess.open(save, FileAccess.READ)
	if (file == null):
		reset_data()
	var json = file.get_as_text()
	
	var SaveData = JSON.parse_string(json)
	GlobalSettings.DataDiscardedCards = SaveData["DataDiscardedCards"]
	GlobalSettings.DiscardedCards = SaveData["DiscardedCards"]
	GlobalSettings.BookmarkedCards = SaveData["BookmarkedCards"]
	if SaveData.has("PawnPositions"):
		GlobalSettings.PawnPositions = SaveData["PawnPositions"]
		Pawnmanager.apply_state(GlobalSettings.PawnPositions)
		Pawnmanager.apply_state.rpc(GlobalSettings.PawnPositions)
	GlobalSettings.sync_self_to_clients()
	rpc_id(sender_id,"show_loaded_notification",saveName)
	print("Game loaded...")

@rpc("any_peer")
func show_loaded_notification(saveName):
	saveNotificationUI.show()
	saveNotifText.text = "loaded game %s!" % saveName

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

func check_if_saveName_exists(savePath):
	return FileAccess.file_exists(savePath)
	

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
