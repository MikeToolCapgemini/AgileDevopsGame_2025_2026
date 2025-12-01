extends Node

var PATH_JSON_DATA = "res://Data/csvjson.json"
var CardData : Array
#var path = "res://database/Cards.csv"
#var TestPath = "C:/Users/miche/Desktop/PlaytestProject/DevOps_Game_v0.10/DevOps_Game_v0.9/database/Cards.csv"

var PlanCardData : Dictionary
var CodeCardData : Dictionary
var BuildCardData : Dictionary
var TestCardData : Dictionary
var ReleaseCardData : Dictionary
var DeployCardData : Dictionary
var OperateCardData : Dictionary
var MonitorCardData : Dictionary
var AllCardData = [PlanCardData, CodeCardData, BuildCardData, TestCardData, ReleaseCardData, DeployCardData, OperateCardData, MonitorCardData]

func load_json_data():
	#Find the json file
	var file = PATH_JSON_DATA
	#Read the json file and parse it as a string
	var json_as_text = FileAccess.get_file_as_string(file)
	var json = JSON.parse_string(json_as_text)
	#Set the json string as an array
	CardData = Array(json)

func _ready():
	import_data()


func sort_data():
	if !GlobalSettings.QuestionsBasic:
		for each in AllCardData:
			sort_data_pop("b", each)

	if !GlobalSettings.QuestionsPro:
		for each in AllCardData:
			sort_data_pop("p", each)


func sort_data_pop(type, dict):
	for every in dict.keys():
			if dict[every][12] == type:
				dict.erase(every)
	print(dict.keys())


func card_pop(dict, key):
	dict.erase(key)
	print("card popped")
	

func import_data():
	load_json_data()
	
	print("card data created")
	for Card in CardData:
		if Card["Type"] == "Question" or "Discussion":
			if Card["Subtype"] == "Plan":
				PlanCardData[PlanCardData.size()] = Card
	
	for Card in CardData:
		if Card["Type"] == "Question" or "Discussion":
			if Card["Subtype"] == "Build":
				BuildCardData[BuildCardData.size()] = Card
				
	for Card in CardData:
		if Card["Type"] == "Question" or "Discussion":
			if Card["Subtype"] == "Test":
				TestCardData[TestCardData.size()] = Card
				
	for Card in CardData:
		if Card["Type"] == "Discussion":
			if Card["Subtype"] == "Deploy":
				DeployCardData[DeployCardData.size()] = Card
				
	for Card in CardData:
		if Card["Type"] == "Question" or "Discussion":
			if Card["Subtype"] == "Code":
				CodeCardData[CodeCardData.size()] = Card
				
	for Card in CardData:
		if Card["Type"] == "Question" or "Discussion":
			if Card["Subtype"] == "Release":
				ReleaseCardData[ReleaseCardData.size()] = Card
				
	for Card in CardData:
		if Card["Type"] == "Question" or "Discussion":
			if Card["Subtype"] == "Operate":
				OperateCardData[OperateCardData.size()] = Card
				
	for Card in CardData:
		if Card["Type"] == "Question" or "Discussion":
			if Card["Subtype"] == "Monitor":
				MonitorCardData[MonitorCardData.size()] = Card
			
	#for each in CardData:
		#if(CardData[each][1] == "Build"):
			#print(CardData[each])
			
	#print("#### build card data: ####")
	#for each in BuildCardData:
		#print(BuildCardData[each])
		#if(CardData[each][1] == "Build"):
			#print(CardData[each])
		#for every in CardData[each]:
			#print(every[0])
			
	
	print("--")
	#var file = FileAccess.open(path,FileAccess.READ)
	#file.open(path, file.READ)
	#while !file.eof_reached():
		#var data_set = Array(file.get_csv_line())
	#file.close()
