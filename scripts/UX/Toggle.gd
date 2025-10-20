extends Button

@export var QuestionsType : String

func _on_pressed():
	if QuestionsType == "basic":
		GlobalSettings.QuestionsBasic = button_pressed
		print(GlobalSettings.QuestionsBasic)
	if QuestionsType == "pro":
		GlobalSettings.QuestionsPro = button_pressed
		print(GlobalSettings.QuestionsPro)
