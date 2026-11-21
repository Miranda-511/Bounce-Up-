
extends Node

signal achievement_unlocked(achievement_id: String)

const SAVE_PATH = "user://player.cfg"

var username: String = ""
var player_id: String = ""

# ESTADÍSTICAS
var games_played: int = 0
var best_score: int = 0
var total_score: int = 0
var total_play_time: float = 0.0
var aliens_dodged: int = 0
var springs_used: int = 0

# LOGROS
var unlocked_achievements: Array = []


func _ready():
	load_player_data()
	ensure_player_id()


# USERNAME
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


# ESTADÍSTICAS
func record_game(score: int, elapsed_time: float):
	games_played += 1
	total_score += score
	total_play_time += elapsed_time

	if score > best_score:
		best_score = score

	check_achievements(score, elapsed_time)
	save_player_data()


func add_alien_dodged():
	aliens_dodged += 1
	check_special_achievements()
	save_player_data()


func add_spring_used():
	springs_used += 1
	check_special_achievements()
	save_player_data()


# LOGROS
func unlock_achievement(achievement_id: String):
	if unlocked_achievements.has(achievement_id):
		return

	unlocked_achievements.append(achievement_id)
	save_player_data()

	achievement_unlocked.emit(achievement_id)

	print("¡Logro desbloqueado!: ", achievement_id)


# COMPROBAR LOGROS DURANTE LA PARTIDA
func check_run_achievements(score: int, elapsed_time: float):

	if score >= 500:
		unlock_achievement("score_500")

	if score >= 1000:
		unlock_achievement("score_1000")

	if score >= 2500:
		unlock_achievement("score_2500")

	if score >= 500 and elapsed_time < 60.0:
		unlock_achievement("speedster")

	check_special_achievements()


# COMPROBAR LOGROS AL TERMINAR LA PARTIDA
func check_achievements(score: int, elapsed_time: float):

	if games_played >= 1:
		unlock_achievement("first_game")

	if games_played >= 25:
		unlock_achievement("veteran")

	check_run_achievements(score, elapsed_time)


func check_special_achievements():

	if aliens_dodged >= 10:
		unlock_achievement("survivor")

	if springs_used >= 20:
		unlock_achievement("professional_bouncer")


# GUARDAR DATOS
func save_player_data() -> bool:
	var config = ConfigFile.new()

	config.set_value("player", "username", username)
	config.set_value("player", "player_id", player_id)

	config.set_value("stats", "games_played", games_played)
	config.set_value("stats", "best_score", best_score)
	config.set_value("stats", "total_score", total_score)
	config.set_value("stats", "total_play_time", total_play_time)
	config.set_value("stats", "aliens_dodged", aliens_dodged)
	config.set_value("stats", "springs_used", springs_used)

	config.set_value("achievements", "unlocked", unlocked_achievements)

	var error = config.save(SAVE_PATH)

	if error != OK:
		push_warning("No se pudieron guardar los datos del jugador.")
		return false

	return true


# CARGAR DATOS
func load_player_data():
	var config = ConfigFile.new()
	var error = config.load(SAVE_PATH)

	if error == OK:
		username = config.get_value("player", "username", "")
		player_id = config.get_value("player", "player_id", "")

		games_played = config.get_value("stats", "games_played", 0)
		best_score = config.get_value("stats", "best_score", 0)
		total_score = config.get_value("stats", "total_score", 0)
		total_play_time = config.get_value("stats", "total_play_time", 0.0)
		aliens_dodged = config.get_value("stats", "aliens_dodged", 0)
		springs_used = config.get_value("stats", "springs_used", 0)

		unlocked_achievements = config.get_value("achievements", "unlocked", [])
