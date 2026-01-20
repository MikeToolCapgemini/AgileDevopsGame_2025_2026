extends Node

var Players = {}
var You
var Main : Node
var multiplayer_manager : Multiplayer

var last_address: String
var last_port: int

func _init():
	print("GameManager Created")

func set_manager(newMain):
	Main = newMain
