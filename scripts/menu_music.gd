
extends AudioStreamPlayer

var music: AudioStreamPlayer

var menu_track: AudioStreamMP3 = preload("res://sound/milbela-retro-game-beat-302210.mp3")


func _ready():
	# Activar la repetición de la música
	menu_track.loop = true

	music = AudioStreamPlayer.new()
	music.stream = menu_track
	music.volume_db = -5.0

	add_child(music)
	music.play()


func play_music():
	if music and not music.playing:
		music.play()


func stop_music():
	if music:
		music.stop()
