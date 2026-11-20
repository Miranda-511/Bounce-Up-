
extends Node

const SAVE_PATH = "user://player.cfg"

var username: String = ""


func _ready():
	load_username()


func save_username(new_username: String) -> bool:
	var clean_username = new_username.strip_edges()

	if clean_username.is_empty():
		return false

	username = clean_username

	var config = ConfigFile.new()
	config.set_value("player", "username", username)

	var error = config.save(SAVE_PATH)

	if error != OK:
		push_warning("No se pudo guardar el username.")
		return false

	return true


func load_username():
	var config = ConfigFile.new()
	var error = config.load(SAVE_PATH)

	if error == OK:
		username = config.get_value("player", "username", "")
