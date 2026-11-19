
extends Control

@onready var play = get_node_or_null("play")
@onready var instructions = get_node_or_null("instructions")
@onready var quit = get_node_or_null("quit")


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

	if quit:
		quit.pressed.connect(_on_quit_pressed)
	else:
		push_warning("No se encontró el botón quit.")


func _on_play_pressed():
	MenuMusic.stop_music()
	get_tree().change_scene_to_file("res://escenas/main.tscn")


func _on_instructions_pressed():
	if ResourceLoader.exists("res://escenas/instructions.tscn"):
		get_tree().change_scene_to_file("res://escenas/instructions.tscn")
	else:
		push_warning("No existe la escena de instrucciones.")


func _on_quit_pressed():
	get_tree().quit()
