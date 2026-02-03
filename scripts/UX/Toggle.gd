extends Button

@export var QuestionsType : String
@onready var ImportData = get_node("/root/ImportData")

func _ready() -> void:
	refresh()
		

func _process(delta: float) -> void:
	refresh()

func refresh():
	if QuestionsType == "basic":
		button_pressed = GlobalSettings.QuestionsBasic
	if QuestionsType == "pro":
		button_pressed = GlobalSettings.QuestionsPro

func _on_pressed():
	if QuestionsType == "basic":
		GlobalSettings.QuestionsBasic = button_pressed
		print(GlobalSettings.QuestionsBasic)
	if QuestionsType == "pro":
		GlobalSettings.QuestionsPro = button_pressed
		print(GlobalSettings.QuestionsPro)


func _on_toggled(toggled_on: bool) -> void:
	if QuestionsType == "basic":
		GlobalSettings.QuestionsBasic = toggled_on
		print(GlobalSettings.QuestionsBasic)
	if QuestionsType == "pro":
		GlobalSettings.QuestionsPro = toggled_on
		print(GlobalSettings.QuestionsPro)
	ImportData.sort_data.rpc()
	
