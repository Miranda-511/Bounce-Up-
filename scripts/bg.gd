
extends Node2D

# TEXTURAS
const CLOUD_TEXTURE = preload("res://assets/cloud.webp")

# NUBES
const CLOUD_AHEAD = 1200.0
const CLOUDS_START_HEIGHT = 5500.0
const CLOUD_SPACING_MIN = 750.0
const CLOUD_SPACING_MAX = 1100.0
const CLOUD_FADE_START = 9000.0
const CLOUD_FADE_END = 15000.0

# ESTRELLAS
const STAR_AHEAD = 1500.0
const STAR_START_HEIGHT = 20000.0

# PLANETAS
const PLANET_AHEAD = 2500.0
const PLANET_START_HEIGHT = 30000.0
const PLANET_SPACING_MIN = 2800.0
const PLANET_SPACING_MAX = 4500.0

# OBJETOS ESPACIALES
const SPACE_OBJECT_AHEAD = 1800.0
const SPACE_OBJECT_START = 28000.0
const SPACE_OBJECT_SPACING_MIN = 450.0
const SPACE_OBJECT_SPACING_MAX = 800.0

# SUELO
const FLOOR_TOP_Y = 582.5

@onready var main = get_parent()

var player: CharacterBody2D
var start_y: float

var sky: ColorRect

var mountain_layer: Node2D
var cloud_layer: Node2D
var star_layer: Node2D
var planet_layer: Node2D
var space_layer: Node2D

var next_cloud_y: float
var next_star_y: float
var next_planet_y: float
var next_space_y: float


func _ready():

	# TODO EL FONDO DETRÁS DEL JUEGO
	z_index = -20

	await get_tree().process_frame

	# BUSCAR AL JUGADOR
	player = main.get_node_or_null("player") as CharacterBody2D

	if player == null:
		player = get_tree().current_scene.find_child(
			"player",
			true,
			false
		) as CharacterBody2D

	if player == null:
		push_error("No se encontró el nodo player.")
		set_process(false)
		return

	start_y = player.global_position.y

	# ELIMINAR EL FONDO ANTIGUO
	for child in get_children():

		if child.name == "ColorRect" or child.name == "CanvasLayer2":
			remove_child(child)
			child.queue_free()

	# CREAR ELEMENTOS
	create_sky()
	create_world_layers()
	create_mountains()

	# NUBES: EMPEZAR LEJOS DEL SUELO
	next_cloud_y = start_y - CLOUDS_START_HEIGHT
	generate_clouds_ahead()

	# ESTRELLAS
	next_star_y = start_y - STAR_START_HEIGHT
	generate_stars_ahead()

	# PLANETAS
	next_planet_y = start_y - PLANET_START_HEIGHT
	generate_planets_ahead()

	# OBJETOS ESPACIALES
	next_space_y = start_y - SPACE_OBJECT_START
	generate_space_objects_ahead()


func _process(_delta):

	if player == null:
		return

	var height = maxf(
		0.0,
		start_y - player.global_position.y
	)

	sky.color = get_sky_color(height)

	generate_clouds_ahead()
	generate_stars_ahead()
	generate_planets_ahead()
	generate_space_objects_ahead()

	cleanup_old_decorations()


# ==================================
# CIELO
# ==================================

func create_sky():

	var sky_canvas = CanvasLayer.new()
	sky_canvas.name = "SkyLayer"
	sky_canvas.layer = -1

	add_child(sky_canvas)

	sky = ColorRect.new()
	sky.name = "Sky"
	sky.color = Color("#8BD7F6")

	sky.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	sky.mouse_filter = Control.MOUSE_FILTER_IGNORE

	sky_canvas.add_child(sky)


func get_sky_color(height: float) -> Color:

	var sky_1 = Color("#8BD7F6")
	var sky_2 = Color("#4C9BD1")
	var sky_3 = Color("#344A81")
	var sky_4 = Color("#252047")
	var sky_5 = Color("#090F25")

	if height < 9000.0:

		return sky_1.lerp(
			sky_2,
			height / 9000.0
		)

	elif height < 15000.0:

		return sky_2.lerp(
			sky_3,
			(height - 9000.0) / 6000.0
		)

	elif height < 22000.0:

		return sky_3.lerp(
			sky_4,
			(height - 15000.0) / 7000.0
		)

	elif height < 30000.0:

		return sky_4.lerp(
			sky_5,
			(height - 22000.0) / 8000.0
		)

	return sky_5


# ==================================
# CAPAS DEL MUNDO
# ==================================

func create_world_layers():

	# MONTAÑAS
	mountain_layer = Node2D.new()
	mountain_layer.name = "Mountains"
	mountain_layer.z_index = -1
	add_child(mountain_layer)

	# NUBES
	cloud_layer = Node2D.new()
	cloud_layer.name = "Clouds"
	add_child(cloud_layer)

	# ESTRELLAS
	star_layer = Node2D.new()
	star_layer.name = "Stars"
	star_layer.z_index = 1
	add_child(star_layer)

	# PLANETAS
	planet_layer = Node2D.new()
	planet_layer.name = "Planets"
	planet_layer.z_index = 2
	add_child(planet_layer)

	# OBJETOS ESPACIALES
	space_layer = Node2D.new()
	space_layer.name = "SpaceObjects"
	space_layer.z_index = 3
	add_child(space_layer)


# ==================================
# PAISAJE TERRESTRE
# ==================================

func create_mountains():

	# COLINAS DEL FONDO
	var far_points = PackedVector2Array([
		Vector2(-100, 545),
		Vector2(40, 475),
		Vector2(190, 500),
		Vector2(350, 430),
		Vector2(510, 490),
		Vector2(680, 445),
		Vector2(850, 500),
		Vector2(1030, 435),
		Vector2(1260, 485)
	])

	add_terrain_layer(
		"FarGreenHills",
		far_points,
		Color("#739D48"),
		Color("#557E37"),
		Color("#B96B2C"),
		900.0,
		-3
	)

	# COLINAS INTERMEDIAS
	var middle_points = PackedVector2Array([
		Vector2(-100, 610),
		Vector2(30, 555),
		Vector2(180, 575),
		Vector2(340, 520),
		Vector2(500, 585),
		Vector2(660, 535),
		Vector2(825, 590),
		Vector2(990, 525),
		Vector2(1130, 570),
		Vector2(1260, 540)
	])

	add_terrain_layer(
		"MiddleDirtHills",
		middle_points,
		Color("#79B52B"),
		Color("#397C24"),
		Color("#B96B2C"),
		1000.0,
		-2
	)

	# COLINAS DELANTERAS
	var near_points = PackedVector2Array([
		Vector2(-100, 690),
		Vector2(40, 625),
		Vector2(190, 650),
		Vector2(350, 600),
		Vector2(520, 655),
		Vector2(690, 610),
		Vector2(850, 660),
		Vector2(1010, 605),
		Vector2(1160, 640),
		Vector2(1260, 620)
	])

	add_terrain_layer(
		"NearGrassDirtHills",
		near_points,
		Color("#8BCB28"),
		Color("#347A22"),
		Color("#C87532"),
		1100.0,
		-1
	)


func add_terrain_layer(
	layer_name: String,
	ridge_points: PackedVector2Array,
	grass_color: Color,
	edge_color: Color,
	dirt_color: Color,
	bottom_y: float,
	layer_z: int
):

	var layer = Node2D.new()
	layer.name = layer_name
	layer.z_index = layer_z
	mountain_layer.add_child(layer)

	# TIERRA
	var dirt = Polygon2D.new()
	dirt.name = "WarmSoil"

	var dirt_points = ridge_points.duplicate()
	dirt_points.append(Vector2(1260, bottom_y))
	dirt_points.append(Vector2(-100, bottom_y))

	dirt.polygon = dirt_points
	dirt.color = dirt_color

	layer.add_child(dirt)

	# BORDE REDONDEADO DEL CÉSPED
	var grass_edge = Polygon2D.new()
	grass_edge.name = "RoundedGrassEdge"

	var edge_points = PackedVector2Array()

	for point in ridge_points:
		edge_points.append(point + Vector2(0, 28))

	for i in range(ridge_points.size() - 1, -1, -1):
		edge_points.append(
			ridge_points[i] + Vector2(0, 54)
		)

	grass_edge.polygon = edge_points
	grass_edge.color = edge_color

	layer.add_child(grass_edge)

	# SUPERFICIE VERDE
	var grass = Polygon2D.new()
	grass.name = "BrightGrassTop"

	var grass_points = ridge_points.duplicate()

	for i in range(ridge_points.size() - 1, -1, -1):
		grass_points.append(
			ridge_points[i] + Vector2(0, 30)
		)

	grass.polygon = grass_points
	grass.color = grass_color

	layer.add_child(grass)

	# BRILLO SUPERIOR
	var highlight = Line2D.new()
	highlight.name = "GrassHighlight"
	highlight.points = ridge_points
	highlight.width = 5.0
	highlight.default_color = Color("#B6DF55")

	layer.add_child(highlight)

	# PEQUEÑOS MECHONES
	for i in range(1, ridge_points.size() - 1):

		var tuft = Polygon2D.new()

		tuft.polygon = PackedVector2Array([
			Vector2(-13, 8),
			Vector2(-9, -5),
			Vector2(-2, -10),
			Vector2(5, -7),
			Vector2(13, 8)
		])

		tuft.position = ridge_points[i] + Vector2(0, 23)
		tuft.color = grass_color.lightened(0.08)

		layer.add_child(tuft)


# ==================================
# NUBES
# ==================================

func create_cloud(cloud_y: float):

	var altitude = start_y - cloud_y

	var fade = clampf(
		(altitude - CLOUD_FADE_START) /
		(CLOUD_FADE_END - CLOUD_FADE_START),
		0.0,
		1.0
	)

	var alpha = 0.82 * (1.0 - fade)

	if alpha <= 0.02:
		return

	var cloud = Sprite2D.new()
	cloud.texture = CLOUD_TEXTURE

	cloud.position = Vector2(
		randf_range(40.0, 1112.0),
		cloud_y
	)

	var cloud_size = randf_range(0.7, 1.15)

	cloud.scale = Vector2(
		cloud_size,
		cloud_size
	)

	cloud.flip_h = randf() < 0.5
	cloud.modulate = Color(1, 1, 1, alpha)

	cloud_layer.add_child(cloud)


func generate_clouds_ahead():

	while next_cloud_y > player.global_position.y - CLOUD_AHEAD:

		create_cloud(next_cloud_y)

		if randf() < 0.15:

			create_cloud(
				next_cloud_y + randf_range(100.0, 180.0)
			)

		next_cloud_y -= randf_range(
			CLOUD_SPACING_MIN,
			CLOUD_SPACING_MAX
		)


# ==================================
# ESTRELLAS
# ==================================

func make_star(radius: float) -> PackedVector2Array:

	var points = PackedVector2Array()

	for i in range(8):

		var angle = -PI / 2.0 + TAU * i / 8.0
		var r = radius

		if i % 2 != 0:
			r *= 0.3

		points.append(
			Vector2(cos(angle), sin(angle)) * r
		)

	return points


func create_star(star_y: float):

	var star = Polygon2D.new()
	var radius = randf_range(2.0, 4.0)

	star.polygon = make_star(radius)

	star.color = Color(
		1.0,
		1.0,
		1.0,
		randf_range(0.45, 1.0)
	)

	star.position = Vector2(
		randf_range(20.0, 1132.0),
		star_y
	)

	star_layer.add_child(star)


func generate_stars_ahead():

	while next_star_y > player.global_position.y - STAR_AHEAD:

		for i in range(randi_range(3, 6)):

			create_star(
				next_star_y + randf_range(-100.0, 100.0)
			)

		next_star_y -= randf_range(100.0, 180.0)


# ==================================
# PLANETAS
# ==================================

func make_circle(
	radius: float,
	segments: int = 32
) -> PackedVector2Array:

	var points = PackedVector2Array()

	for i in range(segments):

		var angle = TAU * float(i) / float(segments)

		points.append(
			Vector2(cos(angle), sin(angle)) * radius
		)

	return points


func create_planet(planet_y: float):

	var planet = Node2D.new()
	planet.name = "Planet"

	planet.position = Vector2(
		randf_range(140.0, 1012.0),
		planet_y
	)

	var radius = randf_range(45.0, 85.0)

	var planet_colors = [
		Color("#D58B76"),
		Color("#B49ADB"),
		Color("#78A9B8"),
		Color("#D6B66D"),
		Color("#A6A6B8"),
		Color("#C77F9C")
	]

	var planet_color: Color = planet_colors[
		randi_range(0, planet_colors.size() - 1)
	]

	# ANILLOS
	if randf() < 0.55:

		var ring = Line2D.new()
		ring.width = randf_range(3.0, 6.0)
		ring.default_color = planet_color.lightened(0.35)

		var ring_points = PackedVector2Array()

		for i in range(49):

			var angle = TAU * float(i) / 48.0

			ring_points.append(
				Vector2(
					cos(angle) * radius * 1.65,
					sin(angle) * radius * 0.48
				)
			)

		ring.points = ring_points
		planet.add_child(ring)

	# BRILLO
	var halo = Polygon2D.new()
	halo.polygon = make_circle(radius * 1.12)
	halo.color = planet_color.lightened(0.35)
	halo.color.a = 0.16

	planet.add_child(halo)

	# CUERPO
	var body = Polygon2D.new()
	body.polygon = make_circle(radius, 48)
	body.color = planet_color

	planet.add_child(body)

	# CRÁTERES
	for i in range(randi_range(2, 4)):

		var crater = Polygon2D.new()
		var crater_radius = radius * randf_range(0.07, 0.15)

		crater.polygon = make_circle(crater_radius, 16)

		crater.position = Vector2(
			randf_range(-radius * 0.55, radius * 0.55),
			randf_range(-radius * 0.45, radius * 0.45)
		)

		crater.color = planet_color.darkened(0.22)

		planet.add_child(crater)

	planet_layer.add_child(planet)


func generate_planets_ahead():

	while next_planet_y > player.global_position.y - PLANET_AHEAD:

		create_planet(next_planet_y)

		if randf() < 0.25:

			create_planet(
				next_planet_y + randf_range(250.0, 500.0)
			)

		next_planet_y -= randf_range(
			PLANET_SPACING_MIN,
			PLANET_SPACING_MAX
		)


# ==================================
# ASTEROIDES
# ==================================

func create_asteroid(asteroid_y: float):

	var asteroid = Node2D.new()

	asteroid.position = Vector2(
		randf_range(40.0, 1112.0),
		asteroid_y
	)

	var radius = randf_range(12.0, 27.0)
	var points = PackedVector2Array()

	var segments = randi_range(7, 10)

	for i in range(segments):

		var angle = TAU * float(i) / float(segments)
		var variation = randf_range(0.75, 1.2)

		points.append(
			Vector2(
				cos(angle),
				sin(angle)
			) * radius * variation
		)

	var body = Polygon2D.new()
	body.polygon = points
	body.color = Color("#85818B")

	asteroid.add_child(body)

	var crater = Polygon2D.new()
	crater.polygon = make_circle(radius * 0.18, 12)
	crater.position = Vector2(radius * 0.3, -radius * 0.2)
	crater.color = Color("#55515E")

	asteroid.add_child(crater)

	space_layer.add_child(asteroid)


# ==================================
# SATÉLITES
# ==================================

func add_rectangle(
	parent: Node2D,
	center: Vector2,
	size: Vector2,
	color: Color
):

	var rect = Polygon2D.new()
	var half = size / 2.0

	rect.polygon = PackedVector2Array([
		Vector2(-half.x, -half.y),
		Vector2(half.x, -half.y),
		Vector2(half.x, half.y),
		Vector2(-half.x, half.y)
	])

	rect.position = center
	rect.color = color

	parent.add_child(rect)


func create_satellite(satellite_y: float):

	var satellite = Node2D.new()

	satellite.position = Vector2(
		randf_range(150.0, 1000.0),
		satellite_y
	)

	satellite.rotation = randf_range(-0.35, 0.35)

	var color = Color("#B8C4D8")

	add_rectangle(
		satellite,
		Vector2(-35, 0),
		Vector2(28, 15),
		Color("#567AA5")
	)

	add_rectangle(
		satellite,
		Vector2(35, 0),
		Vector2(28, 15),
		Color("#567AA5")
	)

	add_rectangle(
		satellite,
		Vector2.ZERO,
		Vector2(22, 22),
		color
	)

	var antenna = Line2D.new()

	antenna.points = PackedVector2Array([
		Vector2(0, -11),
		Vector2(0, -24),
		Vector2(10, -30)
	])

	antenna.width = 2.0
	antenna.default_color = color

	satellite.add_child(antenna)

	space_layer.add_child(satellite)


# ==================================
# ESTRELLAS FUGACES
# ==================================

func create_comet(comet_y: float):

	var comet = Node2D.new()

	comet.position = Vector2(
		randf_range(100.0, 1000.0),
		comet_y
	)

	var tail = Line2D.new()

	tail.points = PackedVector2Array([
		Vector2(-85, 65),
		Vector2(-35, 25),
		Vector2.ZERO
	])

	tail.width = 3.0
	tail.default_color = Color("#B8DFFF")

	comet.add_child(tail)

	var head = Polygon2D.new()
	head.polygon = make_star(5.0)
	head.color = Color.WHITE

	comet.add_child(head)

	space_layer.add_child(comet)


# ==================================
# GENERACIÓN DE OBJETOS ESPACIALES
# ==================================

func generate_space_objects_ahead():

	while next_space_y > player.global_position.y - SPACE_OBJECT_AHEAD:

		var type = randf()

		if type < 0.50:
			create_asteroid(next_space_y)

		elif type < 0.78:
			create_satellite(next_space_y)

		else:
			create_comet(next_space_y)

		next_space_y -= randf_range(
			SPACE_OBJECT_SPACING_MIN,
			SPACE_OBJECT_SPACING_MAX
		)


# ==================================
# LIMPIEZA
# ==================================

func cleanup_old_decorations():

	for cloud in cloud_layer.get_children():

		if cloud.global_position.y > player.global_position.y + 1300.0:
			cloud.queue_free()

	for star in star_layer.get_children():

		if star.global_position.y > player.global_position.y + 1500.0:
			star.queue_free()

	for planet in planet_layer.get_children():

		if planet.global_position.y > player.global_position.y + 8000.0:
			planet.queue_free()

	for object in space_layer.get_children():

		if object.global_position.y > player.global_position.y + 2500.0:
			object.queue_free()
