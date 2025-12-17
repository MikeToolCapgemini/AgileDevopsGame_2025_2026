extends Control

var PATH_JSON_DATA = "res://Data/slideouts.json"
var SlideOutData : Array

@export var GuideName : String
@export var GuideGrid : GridContainer

var guideFieldPrefab = preload("res://prefabs/guide_field.tscn")

func _ready() -> void:
	setup_fields()

func load_json_data():
	#Find the json file
	var file = PATH_JSON_DATA
	#Read the json file and parse it as a string
	var json_as_text = FileAccess.get_file_as_string(file)
	var json = JSON.parse_string(json_as_text)
	#Set the json string as an array
	SlideOutData = Array(json)
	

func setup_fields():
	load_json_data()
	for guide in GuideGrid.get_children():
		guide.queue_free()
	for SlideOut in SlideOutData:
		if SlideOut["GuideName"] == GuideName:
			print("Found: " + GuideName)
			var NrOfFields : int = int(SlideOut["NrFields"])
			for i  in range(1,NrOfFields+1):
				print("Making Field #" + str(i))
				var guidefield = guideFieldPrefab.instantiate()
				GuideGrid.add_child(guidefield)
				var GuideFieldManager : GuideField = guidefield as GuideField
				GuideFieldManager.id = i
				var GuideIcon = SlideOut["IconField #%d" % i]
				var GuideColor = SlideOut["ColorIconField #%d" % i]
				var GuideTitle = SlideOut["Title Field #%d" % i]
				var GuideSubtext = SlideOut["Text Field #%d" % i]
				GuideFieldManager._setup_data(GuideIcon,GuideColor,GuideTitle,GuideSubtext)
