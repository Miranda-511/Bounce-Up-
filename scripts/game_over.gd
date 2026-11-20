
extends Control

@onready var game_over_audio: AudioStreamPlayer = $GameOverAudio

var score_submitted := false


func _ready():
	game_over_audio.play()


func setup(final_score: int, best_score: int):

	var score_label = find_child("ScoreLabel", true, false)
	var best_score_label = find_child("BestScoreLabel", true, false)

	if score_label:
		score_label.text = "Puntuación: " + str(final_score)

	if best_score_label:
		best_score_label.text = "Récord: " + str(best_score)

	if not score_submitted:
		score_submitted = true
		Leaderboard.submit_score(final_score)
