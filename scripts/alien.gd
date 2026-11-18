
extends Area2D

const SPEED = 300

var direction := 1.0


func _ready():

	body_entered.connect(_on_body_entered)

	if randf() < 0.5:
		direction = -1.0


func _process(delta):

	position.x += SPEED * direction * delta

	var screen_width = get_viewport_rect().size.x

	if global_position.x < -100:
		global_position.x = screen_width + 100

	elif global_position.x > screen_width + 100:
		global_position.x = -100


func _on_body_entered(body):

	if body.name != "player":
		return

	# COMPROBAR INMUNIDAD
	if body.has_method("is_immune_from_aliens"):

		if body.is_immune_from_aliens():
			return

	# EL JUGADOR NO ES INMUNE
	if body.has_method("show_game_over"):
		body.show_game_over()
