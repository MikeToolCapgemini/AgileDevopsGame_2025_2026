extends Node

var pName
var pID

# setting the object name to the unique multiplayer ID in order to avoid potential conflicts.
# in this case the object name is the id and the object itself has 2 variables:
# x.playerName, which is the name
# x.id, which is the unique ID as well, in order to avoid future confusion
func set_player_info(newID, newName):
	self.name = newName
	pID = newID
	pName = newName
