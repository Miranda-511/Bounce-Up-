
extends CharacterBody2D

const SPEED = 575.0
const JUMP_VELOCITY = -750.0
const SPRING_VELOCITY = -3500.0
const SPRING_IMMUNITY_DURATION = 2.0

# MARGEN EXTRA PARA EL TELETRANSPORTE LATERAL
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
var last_checked_score: int = 0

var is_dead: bool = false
var spring_immunity_timer: float = 0.0
var run_time: float = 0.0


func _ready():

	start_y = global_position.y
	highest_y = start_y

	sprite.hframes = 4
	sprite.vframes = 4
	sprite.frame = 0

	load_best_score()

	# SINCRONIZAR RÉCORD CON PLAYERDATA
	PlayerData.best_score = max(PlayerData.best_score, best_score)
	PlayerData.save_player_data()

	# PRIMER LOGRO AL COMENZAR LA PRIMERA PARTIDA
	if PlayerData.games_played == 0:
		call_deferred("_check_first_game")


func _check_first_game():

	if PlayerData.games_played == 0:
		PlayerData.unlock_achievement("first_game")


func _physics_process(delta: float) -> void:

	if is_dead:
		return

	# CONTADOR DE TIEMPO
	run_time += delta

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

		for i in range(get_slide_collision_count()):

			var collision = get_slide_collision(i)
			var collider = collision.get_collider()

			if collider is StaticBody2D:
				if collider.is_in_group("spring_platforms"):

					bounce_force = SPRING_VELOCITY
					bounced_on_spring = true
					break

		velocity.y = bounce_force

		if bounced_on_spring:
			spring_immunity_timer = SPRING_IMMUNITY_DURATION

	# ANIMACIÓN
	update_animation()

	# TELETRANSPORTE LATERAL
	var viewport_size := get_viewport_rect().size
	var camera_zoom := camera.zoom

	var visible_world_width := viewport_size.x / camera_zoom.x
	var half_visible_width := visible_world_width * 0.5

	var screen_center_x := camera.get_screen_center_position().x

	var screen_left := screen_center_x - half_visible_width
	var screen_right := screen_center_x + half_visible_width

	if global_position.x < screen_left - WRAP_MARGIN:
		global_position.x = screen_right + WRAP_MARGIN

	elif global_position.x > screen_right + WRAP_MARGIN:
		global_position.x = screen_left - WRAP_MARGIN

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

	# COMPROBAR LOGROS EN TIEMPO REAL
	if current_score > last_checked_score:

		PlayerData.check_run_achievements(
			current_score,
			run_time
		)

		last_checked_score = current_score

	# RÉCORD
	if current_score > best_score:

		best_score = current_score
		best_score_label.text = "Récord: " + str(best_score)
		save_best_score()

	# DETECTAR CAÍDA
	var visible_world_height := viewport_size.y / camera_zoom.y
	var half_visible_height := visible_world_height * 0.5

	var screen_bottom := camera.get_screen_center_position().y + half_visible_height

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

	# REGISTRAR ESTADÍSTICAS DE LA PARTIDA
	PlayerData.record_game(current_score, run_time)

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
