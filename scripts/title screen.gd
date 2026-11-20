
extends Control

@onready var play = get_node_or_null("play")
@onready var instructions = get_node_or_null("instructions")
@onready var ranking = get_node_or_null("ranking")


func _ready():
	MenuMusic.play_music()

	if play:
		play.pressed.connect(_on_play_pressed)
	else:
		push_warning("No se encontró el botón play.")

	if instructions:
		instructions.pressed.connect(_on_instructions_pressed)
	else:
		push_warning("No se encontró el botón instructions.")

	if ranking:
		ranking.pressed.connect(_on_ranking_pressed)
	else:
		push_warning("No se encontró el botón ranking.")


func _on_play_pressed():
	MenuMusic.stop_music()

	if PlayerData.username.is_empty():
		get_tree().change_scene_to_file("res://escenas/username.tscn")
	else:
		get_tree().change_scene_to_file("res://escenas/main.tscn")


func _on_instructions_pressed():
	if ResourceLoader.exists("res://escenas/instructions.tscn"):
		get_tree().change_scene_to_file("res://escenas/instructions.tscn")
	else:
		push_warning("No existe la escena de instrucciones.")


func _on_ranking_pressed():
	get_tree().change_scene_to_file("res://escenas/leaderboard.scn")
