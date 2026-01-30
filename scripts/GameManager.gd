extends Node

var Players = {}
var You
var Main : Node
var multiplayer_manager : Multiplayer
signal players_updated

var last_address: String
var last_port: int

func _init():
	print("GameManager Created")

func set_manager(newMain):
	Main = newMain
