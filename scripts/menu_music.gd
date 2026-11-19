
extends AudioStreamPlayer

var music: AudioStreamPlayer


func _ready():
	music = AudioStreamPlayer.new()
	music.stream = preload("res://sound/milbela-retro-game-beat-302210.mp3")
	music.volume_db = -5.0

	add_child(music)
	music.play()


func play_music():
	if music and not music.playing:
		music.play()


func stop_music():
	if music:
		music.stop()
