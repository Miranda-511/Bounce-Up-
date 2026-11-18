extends Area2D

const SPEED = 300

var direction := 1.0

func _ready():
	body_entered.connect(_on_body_entered)

	# Dirección aleatoria
	if randf() < 0.5:
		direction = -1.0

func _process(delta):
	position.x += SPEED * direction * delta

	# Si sale por un lado, aparece por el otro
	var screen_width = get_viewport_rect().size.x

	if global_position.x < -100:
		global_position.x = screen_width + 100

	elif global_position.x > screen_width + 100:
		global_position.x = -100

func _on_body_entered(body):
	if body.name == "player":
		if body.has_method("show_game_over"):
			body.show_game_over()
