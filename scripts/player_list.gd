extends Node


@export var PlayerVbox : VBoxContainer
@export var PlayerLabel : RichTextLabel

func _ready() -> void:
	PlayerLabel.name = "_TemplatePlayerLabel"
	PlayerLabel.visible = false
	GameManager.players_updated.connect(update_player_list)
	update_player_list() # initial populate



func clear_list():
	for child in PlayerVbox.get_children():
		if child.name != "_TemplatePlayerLabel":
			child.queue_free()

func update_player_list():
	clear_list()
	for id in GameManager.Players:
		var player_data = GameManager.Players[id]
		
		var new_label := PlayerLabel.duplicate()
		new_label.text = player_data["name"]
		new_label.visible = true
		set_player_color(new_label,id)
		PlayerVbox.add_child(new_label)


func set_player_color(label: RichTextLabel, peer_id: int):
	var team_color_str = PlayerSettings.PlayersColors.get(peer_id, "")
	var team_color = Color.WHITE
	if team_color_str != "" and GlobalColors.TeamColors.has(team_color_str):
		team_color = GlobalColors.TeamColors[team_color_str]

	label.bbcode_enabled = true
	var color_hex = "#%02x%02x%02x" % [team_color.r8, team_color.g8, team_color.b8]
	label.bbcode_text = "[color=%s]%s[/color]" % [color_hex, label.text]



	
