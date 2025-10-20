extends Node

var Players = {}
var You
var Main : Node

func _init():
	print("GameManager Created")

func set_manager(newMain):
	Main = newMain
