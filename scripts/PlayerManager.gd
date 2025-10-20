extends Node

@export var players = [ ]

func _ready():
	for each in self.get_children():
		players.append(each)
	for p in GameManager.Players:
		create_player(GameManager.Players[p].name, p)
	
	print(players)

func create_player(playername, id):
	#var newPlayer = PlayerPrefab.instantiate()
	#self.add_child.call_deferred(newPlayer)
	
	#newPlayer.set_player_info(id, name)
	print(str(playername) + str(id) + " created")
