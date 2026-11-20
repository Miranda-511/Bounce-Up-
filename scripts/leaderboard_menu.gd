
extends Control

@onready var entries_container: VBoxContainer = $MainContainer/RankingPanel/EntriesContainer
@onready var back_button: TextureButton = $BackButton


func _ready():
	Leaderboard.top_players_received.connect(_on_top_players_received)

	back_button.pressed.connect(_on_back_pressed)

	Leaderboard.get_top_players()


func _on_top_players_received(players: Array):
	for child in entries_container.get_children():
		child.queue_free()

	for i in range(players.size()):
		var player_data = players[i]

		var row = HBoxContainer.new()
		row.custom_minimum_size = Vector2(0, 55)
		row.add_theme_constant_override("separation", 25)

		var position_label = Label.new()
		position_label.text = "#" + str(i + 1)
		position_label.custom_minimum_size.x = 65
		position_label.add_theme_font_size_override("font_size", 28)
		position_label.add_theme_color_override("font_color", Color("#FFE28A"))

		var name_label = Label.new()
		name_label.text = str(player_data.get("player", "Jugador"))
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.add_theme_font_size_override("font_size", 24)
		name_label.add_theme_color_override("font_color", Color.WHITE)

		var score_label = Label.new()
		score_label.text = str(player_data.get("score", 0))
		score_label.add_theme_font_size_override("font_size", 26)
		score_label.add_theme_color_override("font_color", Color("#A9F3FF"))

		row.add_child(position_label)
		row.add_child(name_label)
		row.add_child(score_label)

		entries_container.add_child(row)


func _on_back_pressed():
	get_tree().change_scene_to_file("res://escenas/menu.tscn")
