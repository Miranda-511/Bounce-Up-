extends Node2D

const PLATFORM_SCENE = preload("res://escenas/platform.tscn")
const ROCK_PLATFORM_SCENE = preload("res://escenas/platform_rock.tscn")
const ALIEN_SCENE = preload("res://escenas/alien.tscn")

# DIFICULTAD
const VERTICAL_GAP = 270.0
const MIN_HORIZONTAL_STEP = 140.0
const MAX_HORIZONTAL_STEP = 420.0
const GENERATE_AHEAD = 900.0

# PLATAFORMA
const PLATFORM_CENTER_X = 932.125
const PLATFORM_TOP_OFFSET_Y = 481.0
const PLATFORM_HALF_WIDTH = 140.0

# POSICIÓN INICIAL
const FLOOR_TOP_Y = 582.5
const FIRST_PLATFORM_ABOVE_FLOOR = 110.0
const FIRST_PLATFORM_HORIZONTAL_OFFSET = 200.0

# ALTURA EN LA QUE COMIENZAN LAS PLATAFORMAS ROCOSAS
const ROCK_START_HEIGHT = 20000.0

# ALIENS
const ALIEN_START_HEIGHT = 20000.0
const ALIEN_VERTICAL_GAP = 810.0

@onready var main: Node2D = get_parent()

var player: CharacterBody2D
var start_y: float
var next_platform_y: float
var last_center_x: float
var next_alien_y: float

var recent_positions: Array[float] = []

func _ready():

	for child in main.get_children():
		if child is CharacterBody2D:
			player = child
			break

	if player == null:
		push_error("No se encontró al jugador.")
		set_process(false)
		return

	start_y = player.global_position.y

	var screen_width = get_viewport_rect().size.x

	last_center_x = clamp(
		player.global_position.x + 104.6 + FIRST_PLATFORM_HORIZONTAL_OFFSET,
		PLATFORM_HALF_WIDTH,
		screen_width - PLATFORM_HALF_WIDTH
	)

	recent_positions.append(last_center_x)

	next_platform_y = FLOOR_TOP_Y - FIRST_PLATFORM_ABOVE_FLOOR

	spawn_platform(last_center_x)

	next_platform_y -= VERTICAL_GAP

	# El primer alien aparecerá cuando lleguemos al espacio
	next_alien_y = start_y - ALIEN_START_HEIGHT

	generate_ahead()


func _process(_delta):

	if player == null:
		return

	generate_ahead()


func generate_ahead():

	while next_platform_y > player.global_position.y - GENERATE_AHEAD:
		create_platform()

	# Generar aliens solamente en el espacio
	while next_alien_y > player.global_position.y - GENERATE_AHEAD:
		create_alien()
		next_alien_y -= ALIEN_VERTICAL_GAP


func spawn_platform(center_x: float):

	var height = start_y - next_platform_y

	var new_platform

	# ANTES DEL ESPACIO: TIERRA
	# EN EL ESPACIO: ROCA
	if height >= ROCK_START_HEIGHT:
		new_platform = ROCK_PLATFORM_SCENE.instantiate()
	else:
		new_platform = PLATFORM_SCENE.instantiate()

	new_platform.position = Vector2(
		center_x - PLATFORM_CENTER_X,
		next_platform_y - PLATFORM_TOP_OFFSET_Y
	)

	main.add_child.call_deferred(new_platform)


func create_platform():

	var screen_width = get_viewport_rect().size.x

	var min_x = PLATFORM_HALF_WIDTH
	var max_x = screen_width - PLATFORM_HALF_WIDTH

	var possible_positions: Array[float] = []

	for attempt in range(100):

		var candidate = randf_range(min_x, max_x)

		var distance = abs(candidate - last_center_x)

		if distance < MIN_HORIZONTAL_STEP:
			continue

		if distance > MAX_HORIZONTAL_STEP:
			continue

		var repeated = false

		for i in range(max(0, recent_positions.size() - 2)):

			if abs(candidate - recent_positions[i]) < 170.0:
				repeated = true
				break

		if not repeated:
			possible_positions.append(candidate)

	var new_x = last_center_x

	if possible_positions.size() > 0:

		new_x = possible_positions[
			randi_range(0, possible_positions.size() - 1)
		]

	else:

		var direction = -1.0 if randf() < 0.5 else 1.0

		new_x = clamp(
			last_center_x + direction * randf_range(180.0, 300.0),
			min_x,
			max_x
		)

	spawn_platform(new_x)

	recent_positions.append(new_x)

	if recent_positions.size() > 3:
		recent_positions.pop_front()

	last_center_x = new_x

	next_platform_y -= VERTICAL_GAP


func create_alien():

	var screen_width = get_viewport_rect().size.x

	# Evitamos que aparezca pegado al borde
	var min_x = 100.0
	var max_x = screen_width - 100.0

	var alien_x = randf_range(min_x, max_x)

	var alien = ALIEN_SCENE.instantiate()

	alien.global_position = Vector2(
		alien_x,
		next_alien_y
	)

	main.add_child.call_deferred(alien)
