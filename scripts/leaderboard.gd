
extends Node

signal top_players_received(players: Array)

const SUPABASE_URL = "https://tgrvkopyhrnnbxzqaepo.supabase.co"
const SUPABASE_KEY = "sb_publishable_RHREk546QQoYftbpA1m-Bw_ObUo2xUE"

var http: HTTPRequest
var is_requesting := false


func _ready():
	http = HTTPRequest.new()
	add_child(http)

	http.request_completed.connect(_on_request_completed)

	get_top_players()


func get_top_players():
	if is_requesting:
		return

	is_requesting = true

	var url = SUPABASE_URL + "/rest/v1/leaderboard?select=player,score&order=score.desc&limit=10"

	var headers = PackedStringArray([
		"apikey: " + SUPABASE_KEY,
		"Authorization: Bearer " + SUPABASE_KEY
	])

	var error = http.request(
		url,
		headers,
		HTTPClient.METHOD_GET
	)

	if error != OK:
		is_requesting = false
		print("Error al obtener el ranking: ", error)


func submit_score(score: int):
	if PlayerData.username.is_empty() or PlayerData.player_id.is_empty():
		print("Error: faltan los datos del jugador.")
		return

	var url = SUPABASE_URL + "/rest/v1/rpc/submit_score"

	var headers = PackedStringArray([
		"apikey: " + SUPABASE_KEY,
		"Authorization: Bearer " + SUPABASE_KEY,
		"Content-Type: application/json"
	])

	var data = {
		"p_player_id": PlayerData.player_id,
		"p_player": PlayerData.username,
		"p_score": score
	}

	var error = http.request(
		url,
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(data)
	)

	if error != OK:
		print("Error al enviar la puntuación: ", error)


func _on_request_completed(_result, response_code, _headers, body):
	is_requesting = false

	var response_text = body.get_string_from_utf8()

	print("Respuesta de Supabase: ", response_code)
	print("Datos recibidos: ", response_text)

	if response_code == 200:
		var players = JSON.parse_string(response_text)

		if players is Array:
			top_players_received.emit(players)
