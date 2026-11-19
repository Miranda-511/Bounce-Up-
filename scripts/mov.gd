extends CharacterBody2D

const SPEED = 575.0
const JUMP_VELOCITY = -750.0
const SPRING_VELOCITY = -1250.0
const SPRING_IMMUNITY_DURATION = 2.0
const WRAP_MARGIN = 30.0

const CAMERA_SPEED = 0.65
const CAMERA_TRIGGER = 260.0
const DEATH_MARGIN = 100.0

const SAVE_PATH = "user://scores.cfg"
const GAME_OVER_SCENE = preload("res://escenas/gameover.tscn")

@onready var camera: Camera2D = $"../Camera2D"
@onready var score_label: Label = $"../CanvasLayer/ScoreLabel"
@onready var best_score_label: Label = $"../CanvasLayer/BestScoreLabel"
@onready var sprite: Sprite2D = $Sprite2D
@onready var music: AudioStreamPlayer = $"../AudioStreamPlayer"

var start_y: float
var highest_y: float
var best_score: int = 0
var current_score: int = 0
var is_dead: bool = false

var spring_immunity_timer: float = 0.0


func _ready():

	start_y = global_position.y
	highest_y = start_y

	sprite.hframes = 4
	sprite.vframes = 4
	sprite.frame = 0

	load_best_score()


func _physics_process(delta: float) -> void:

	if is_dead:
		return

	# ACTUALIZAR INMUNIDAD
	if spring_immunity_timer > 0.0:
		spring_immunity_timer -= delta

	# GRAVEDAD
	if not is_on_floor():
		velocity += get_gravity() * delta

	# MOVIMIENTO HORIZONTAL
	var direction := Input.get_axis("ui_left", "ui_right")

	if direction:
		velocity.x = direction * SPEED

		# VOLTEAR SPRITE SEGÚN LA DIRECCIÓN
		if direction < 0:
			sprite.flip_h = true
		elif direction > 0:
			sprite.flip_h = false

	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# REBOTE AUTOMÁTICO
	if is_on_floor() and velocity.y >= 0:

		var bounce_force = JUMP_VELOCITY
		var bounced_on_spring = false

		# DETECTAR RESORTE
		for i in range(get_slide_collision_count()):

			var collision = get_slide_collision(i)
			var collider = collision.get_collider()

			if collider is StaticBody2D:
				if collider.is_in_group("spring_platforms"):

					bounce_force = SPRING_VELOCITY
					bounced_on_spring = true
					break

		velocity.y = bounce_force

		# ACTIVAR INMUNIDAD
		if bounced_on_spring:
			spring_immunity_timer = SPRING_IMMUNITY_DURATION

	# ANIMACIÓN
	update_animation()

	# SCREEN WRAPPING
	var screen_width = get_viewport_rect().size.x

	if global_position.x < -WRAP_MARGIN:
		global_position.x = screen_width + WRAP_MARGIN
	elif global_position.x > screen_width + WRAP_MARGIN:
		global_position.x = -WRAP_MARGIN

	# CÁMARA
	if global_position.y < camera.global_position.y - CAMERA_TRIGGER:

		var target_y = global_position.y + CAMERA_TRIGGER

		camera.global_position.y = lerp(
			camera.global_position.y,
			target_y,
			min(CAMERA_SPEED * delta, 1.0)
		)

	# PUNTUACIÓN
	if global_position.y < highest_y:
		highest_y = global_position.y

	current_score = int((start_y - highest_y) / 10.0)
	current_score = max(current_score, 0)

	score_label.text = "Puntuación: " + str(current_score)

	# RÉCORD
	if current_score > best_score:
		best_score = current_score
		best_score_label.text = "Récord: " + str(best_score)
		save_best_score()

	# DETECTAR CAÍDA
	var screen_bottom = camera.get_screen_center_position().y + 324.0

	if sprite.global_position.y > screen_bottom + DEATH_MARGIN:
		show_game_over()


func is_immune_from_aliens() -> bool:
	return spring_immunity_timer > 0.0


func show_game_over():

	if is_dead:
		return

	is_dead = true
	velocity = Vector2.ZERO
	set_physics_process(false)

	# DETENER MÚSICA NORMAL
	music.stop()

	# MOSTRAR GAME OVER
	var layer = CanvasLayer.new()
	layer.layer = 100
	get_tree().current_scene.add_child(layer)

	var game_over = GAME_OVER_SCENE.instantiate()
	layer.add_child(game_over)

	game_over.setup(current_score, best_score)


func update_animation():

	if is_on_floor():
		sprite.frame = 0
	elif velocity.y < -100.0:
		sprite.frame = 4
	elif velocity.y <= 150.0:
		sprite.frame = 8
	else:
		sprite.frame = 12


func load_best_score():

	var config = ConfigFile.new()
	var error = config.load(SAVE_PATH)

	if error == OK:
		best_score = config.get_value("scores", "best_score", 0)

	best_score_label.text = "Récord: " + str(best_score)


func save_best_score():

	var config = ConfigFile.new()
	config.set_value("scores", "best_score", best_score)

	var error = config.save(SAVE_PATH)

	if error != OK:
		push_warning("No se pudo guardar el récord.")
