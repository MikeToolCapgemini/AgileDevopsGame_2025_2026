extends Node

@export var CardManager : CardManager
@onready var ImportData = get_node("/root/ImportData")

func GetCard(id:int):
	GlobalSettings.BookmarkedCards[id]
	
