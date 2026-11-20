
extends Node

const SAVE_PATH = "user://player.cfg"

var username: String = ""
var player_id: String = ""


func _ready():
	load_player_data()
	ensure_player_id()


func save_username(new_username: String) -> bool:
	var clean_username = new_username.strip_edges()

	if clean_username.is_empty():
		return false

	username = clean_username

	return save_player_data()


func ensure_player_id():
	if not player_id.is_empty():
		return

	var crypto = Crypto.new()
	var bytes = crypto.generate_random_bytes(16)
	var hex = bytes.hex_encode()

	player_id = "%s-%s-%s-%s-%s" % [
		hex.substr(0, 8),
		hex.substr(8, 4),
		hex.substr(12, 4),
		hex.substr(16, 4),
		hex.substr(20, 12)
	]

	save_player_data()


func save_player_data() -> bool:
	var config = ConfigFile.new()

	config.set_value("player", "username", username)
	config.set_value("player", "player_id", player_id)

	var error = config.save(SAVE_PATH)

	if error != OK:
		push_warning("No se pudieron guardar los datos del jugador.")
		return false

	return true


func load_player_data():
	var config = ConfigFile.new()
	var error = config.load(SAVE_PATH)

	if error == OK:
		username = config.get_value("player", "username", "")
		player_id = config.get_value("player", "player_id", "")
