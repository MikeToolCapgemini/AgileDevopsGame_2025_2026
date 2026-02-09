extends Control

signal data_ready

var PATH_JSON_DATA = "res://Data/slideouts.json"
var WEB_PATH = "Data/slideouts.json"
var SlideOutData : Array = []

@onready var jsonLoader = json_loader.new()

@export var GuideName : String
@export var GuideGrid : GridContainer

var guideFieldPrefab = preload("res://prefabs/guide_field.tscn")


func _ready() -> void:
	add_child(jsonLoader)
	jsonLoader.data_ready.connect(_on_guides_loaded)
	jsonLoader.load_json(PATH_JSON_DATA, WEB_PATH)

func _on_guides_loaded(data):
	SlideOutData = data
	setup_fields()


func setup_fields():
	for guide in GuideGrid.get_children():
		guide.queue_free()

	for SlideOut in SlideOutData:
		if SlideOut["GuideName"] == GuideName:
			var NrOfFields : int = int(SlideOut["NrFields"])
			for i in range(1, NrOfFields + 1):
				var guidefield = guideFieldPrefab.instantiate()
				GuideGrid.add_child(guidefield)
				var GuideFieldManager : GuideField = guidefield as GuideField
				GuideFieldManager.id = i
				var GuideIcon = SlideOut["IconField #%d" % i]
				var GuideColor = SlideOut["ColorIconField #%d" % i]
				var GuideTitle = SlideOut["Title Field #%d" % i]
				var GuideSubtext = SlideOut["Text Field #%d" % i]
				GuideFieldManager._setup_data(GuideIcon, GuideColor, GuideTitle, GuideSubtext)
