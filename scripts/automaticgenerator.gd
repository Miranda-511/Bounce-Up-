
extends Node2D

const PLATFORM_SCENE = preload("res://escenas/platform.tscn")
const MOVING_PLATFORM_SCENE = preload("res://escenas/platform_moving.tscn")
const DISAPPEARING_PLATFORM_SCENE = preload("res://escenas/platform_disappearing.tscn")
const ROCK_PLATFORM_SCENE = preload("res://escenas/platform_rock.tscn")
const ALIEN_SCENE = preload("res://escenas/alien.tscn")
const SPRING_SCENE = preload("res://escenas/spring.tscn")

# DIFICULTAD Y GENERACIÓN
const VERTICAL_GAP = 220.0
const MIN_HORIZONTAL_STEP = 140.0
const MAX_HORIZONTAL_STEP = 420.0
const GENERATE_AHEAD = 900.0

# GENERACIÓN DE RUTAS
const MIN_PLATFORM_SEPARATION = 310.0
const THREE_PLATFORM_CHANCE = 0.25
const GENERATION_ATTEMPTS = 150

# SEPARACIÓN DE PLATAFORMAS MÓVILES
const MOVING_DISTANCE = 180.0
const MOVING_SAFE_MARGIN = 70.0

# TIPOS DE PLATAFORMAS
const TYPE_NORMAL = 0
const TYPE_MOVING = 1
const TYPE_DISAPPEARING = 2
const TYPE_ROCK = 3

# PROGRESIÓN DE AMBIENTACIÓN
const NORMAL_ONLY_HEIGHT = 1760.0
const SPACE_START_HEIGHT = 20000.0

# PLATAFORMA
const PLATFORM_CENTER_X = 932.125
const PLATFORM_TOP_OFFSET_Y = 481.0
const PLATFORM_HALF_WIDTH = 140.0

# POSICIÓN INICIAL
const FLOOR_TOP_Y = 582.5
const FIRST_PLATFORM_ABOVE_FLOOR = 110.0
const FIRST_PLATFORM_HORIZONTAL_OFFSET = 200.0

# ALIENS
const ALIEN_START_HEIGHT = 20000.0
const ALIEN_VERTICAL_GAP = 810.0

# RESORTES
const SPRING_CHANCE = 0.12
const SPRING_OFFSET_Y = -35.0

@onready var main: Node2D = get_parent()
@onready var camera: Camera2D = $"../Camera2D"

var player: CharacterBody2D

var start_y: float
var next_platform_y: float
var next_alien_y: float

# POSICIONES DEL NIVEL ANTERIOR
var previous_level_positions: Array[float] = []

# HISTORIAL DE POSICIONES
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

	var screen_left = get_visible_world_left()
	var screen_right = get_visible_world_right()

	var min_x = screen_left + PLATFORM_HALF_WIDTH
	var max_x = screen_right - PLATFORM_HALF_WIDTH

	# PRIMERA PLATAFORMA
	var first_x = clamp(
		player.global_position.x + 104.6 + FIRST_PLATFORM_HORIZONTAL_OFFSET,
		min_x,
		max_x
	)

	previous_level_positions.append(first_x)
	recent_positions.append(first_x)

	next_platform_y = FLOOR_TOP_Y - FIRST_PLATFORM_ABOVE_FLOOR

	spawn_platform(first_x, TYPE_NORMAL)

	next_platform_y -= VERTICAL_GAP

	next_alien_y = start_y - ALIEN_START_HEIGHT

	generate_ahead()


func _process(_delta):

	if player == null:
		return

	generate_ahead()


# =========================================================
# LÍMITES VISIBLES DEL MUNDO
# =========================================================

func get_visible_world_width() -> float:

	var viewport_width := get_viewport_rect().size.x
	var zoom_x := camera.zoom.x

	return viewport_width / zoom_x


func get_visible_world_left() -> float:

	var half_width := get_visible_world_width() * 0.5

	return camera.get_screen_center_position().x - half_width


func get_visible_world_right() -> float:

	var half_width := get_visible_world_width() * 0.5

	return camera.get_screen_center_position().x + half_width


# =========================================================
# GENERACIÓN
# =========================================================

func generate_ahead():

	while next_platform_y > player.global_position.y - GENERATE_AHEAD:
		create_platform_level()

	while next_alien_y > player.global_position.y - GENERATE_AHEAD:
		create_alien()
		next_alien_y -= ALIEN_VERTICAL_GAP


# =========================================================
# ELEGIR TIPO DE PLATAFORMA
# =========================================================

func choose_platform_type(height: float) -> int:

	# ESPACIO: SOLAMENTE PLATAFORMAS ROCOSAS.
	# NO ES UN CAMBIO DE DIFICULTAD, SINO DE AMBIENTACIÓN.
	if height >= SPACE_START_HEIGHT:
		return TYPE_ROCK

	# INICIO: SOLO PLATAFORMAS NORMALES.
	if height < NORMAL_ONLY_HEIGHT:
		return TYPE_NORMAL

	# TIERRA: MEZCLA CONSTANTE DE PLATAFORMAS.
	var roll = randf()

	if roll < 0.45:
		return TYPE_NORMAL

	elif roll < 0.70:
		return TYPE_MOVING

	else:
		return TYPE_DISAPPEARING


# =========================================================
# SEPARACIÓN NECESARIA ENTRE PLATAFORMAS
# =========================================================

func get_required_separation(type_a: int, type_b: int) -> float:

	var separation = MIN_PLATFORM_SEPARATION

	var moving_count = 0

	if type_a == TYPE_MOVING:
		moving_count += 1

	if type_b == TYPE_MOVING:
		moving_count += 1

	if moving_count > 0:

		separation = (
			PLATFORM_HALF_WIDTH * 2.0
			+ MOVING_SAFE_MARGIN
			+ MOVING_DISTANCE * moving_count
		)

	return separation


# =========================================================
# COMPROBAR SI UNA POSICIÓN ES VÁLIDA
# =========================================================

func is_position_valid(
	candidate: float,
	platform_type: int,
	previous_positions: Array[float],
	current_platforms: Array[Dictionary]
) -> bool:

	# DEBE SER ALCANZABLE DESDE ALGUNA
	# PLATAFORMA DEL NIVEL ANTERIOR.
	var reachable = false

	for previous_x in previous_positions:

		var distance = abs(candidate - previous_x)

		if distance >= MIN_HORIZONTAL_STEP and distance <= MAX_HORIZONTAL_STEP:
			reachable = true
			break

	if not reachable:
		return false

	# EVITAR QUE SE ENCIME CON OTRAS
	# PLATAFORMAS DEL MISMO NIVEL.
	for existing in current_platforms:

		var existing_x: float = existing["x"]
		var existing_type: int = existing["type"]

		var required = get_required_separation(
			platform_type,
			existing_type
		)

		if abs(candidate - existing_x) < required:
			return false

	return true


# =========================================================
# CREAR UNA PLATAFORMA
# =========================================================

func spawn_platform(center_x: float, platform_type: int):

	var new_platform
	var can_have_spring = false

	match platform_type:

		TYPE_NORMAL:
			new_platform = PLATFORM_SCENE.instantiate()
			can_have_spring = true

		TYPE_MOVING:
			new_platform = MOVING_PLATFORM_SCENE.instantiate()

		TYPE_DISAPPEARING:
			new_platform = DISAPPEARING_PLATFORM_SCENE.instantiate()

		TYPE_ROCK:
			new_platform = ROCK_PLATFORM_SCENE.instantiate()
			can_have_spring = true

	# POSICIONAR LA PLATAFORMA
	new_platform.position = Vector2(
		center_x - PLATFORM_CENTER_X,
		next_platform_y - PLATFORM_TOP_OFFSET_Y
	)

	main.add_child.call_deferred(new_platform)

	# GENERAR RESORTE
	if can_have_spring and randf() < SPRING_CHANCE:

		var spring = SPRING_SCENE.instantiate()

		spring.position = Vector2(
			center_x,
			next_platform_y + SPRING_OFFSET_Y
		)

		main.add_child.call_deferred(spring)


# =========================================================
# CREAR UN NIVEL CON VARIAS RUTAS
# =========================================================

func create_platform_level():

	var screen_left = get_visible_world_left()
	var screen_right = get_visible_world_right()

	var min_x = screen_left + PLATFORM_HALF_WIDTH
	var max_x = screen_right - PLATFORM_HALF_WIDTH

	var current_level_platforms: Array[Dictionary] = []
	var current_level_positions: Array[float] = []

	# NORMALMENTE 2 PLATAFORMAS.
	# OCASIONALMENTE 3.
	var platform_count = 2

	if randf() < THREE_PLATFORM_CHANCE:
		platform_count = 3

	var height = start_y - next_platform_y

	# GENERAR LAS PLATAFORMAS DEL NIVEL.
	for platform_index in range(platform_count):

		var platform_type = choose_platform_type(height)

		var possible_positions: Array[float] = []

		for attempt in range(GENERATION_ATTEMPTS):

			var candidate = randf_range(min_x, max_x)

			if not is_position_valid(
				candidate,
				platform_type,
				previous_level_positions,
				current_level_platforms
			):
				continue

			# EVITAR REPETIR DEMASIADO LAS MISMAS
			# POSICIONES HORIZONTALES.
			var repetitive = false

			for recent_x in recent_positions:

				if abs(candidate - recent_x) < 75.0:
					repetitive = true
					break

			if repetitive and randf() < 0.75:
				continue

			possible_positions.append(candidate)

		# ELEGIR UNA POSICIÓN VÁLIDA.
		if possible_positions.size() > 0:

			var chosen_x = possible_positions[
				randi_range(0, possible_positions.size() - 1)
			]

			var platform_data = {
				"x": chosen_x,
				"type": platform_type
			}

			current_level_platforms.append(platform_data)
			current_level_positions.append(chosen_x)

			spawn_platform(chosen_x, platform_type)

			recent_positions.append(chosen_x)

			if recent_positions.size() > 8:
				recent_positions.pop_front()

	# SI NO SE GENERÓ NINGUNA PLATAFORMA,
	# INTENTAR CREAR UNA NORMAL DE RESPALDO.
	if current_level_positions.is_empty():

		for attempt in range(GENERATION_ATTEMPTS):

			var candidate = randf_range(min_x, max_x)

			if is_position_valid(
				candidate,
				TYPE_NORMAL,
				previous_level_positions,
				current_level_platforms
			):

				current_level_positions.append(candidate)

				spawn_platform(candidate, TYPE_NORMAL)

				recent_positions.append(candidate)

				break

	# GUARDAR LAS POSICIONES DEL NIVEL ACTUAL
	# PARA CONECTARLAS CON EL SIGUIENTE.
	if not current_level_positions.is_empty():
		previous_level_positions = current_level_positions.duplicate()

	next_platform_y -= VERTICAL_GAP


# =========================================================
# ALIENS
# =========================================================

func create_alien():

	var screen_left = get_visible_world_left()
	var screen_right = get_visible_world_right()

	var min_x = screen_left + 100.0
	var max_x = screen_right - 100.0

	var alien_x = randf_range(min_x, max_x)

	var alien = ALIEN_SCENE.instantiate()

	alien.global_position = Vector2(
		alien_x,
		next_alien_y
	)

	main.add_child.call_deferred(alien)
