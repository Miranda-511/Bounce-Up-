
extends Control

@onready var username_input: LineEdit = $UsernameInput
@onready var confirm_button: Button = $ConfirmButton
@onready var error_label: Label = $ErrorLabel


func _ready():
	confirm_button.pressed.connect(_on_confirm_pressed)
	error_label.text = ""


func _on_confirm_pressed():
	var entered_username = username_input.text.strip_edges()

	var regex = RegEx.new()
	regex.compile("^[A-Za-z0-9_]{3,16}$")

	if regex.search(entered_username) == null:
		error_label.text = "Usa entre 3 y 16 caracteres: letras, números o _"
		return

	if not PlayerData.save_username(entered_username):
		error_label.text = "No se pudo guardar el username."
		return

	# DETENER MÚSICA DEL MENÚ
	MenuMusic.stop_music()

	# IR AL JUEGO
	get_tree().change_scene_to_file("res://escenas/main.tscn")
