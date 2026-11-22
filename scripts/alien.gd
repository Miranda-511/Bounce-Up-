extends Area2D

const SPEED = 300.0
const SCREEN_MARGIN = 120.0

var direction := 1.0
var fixed_y := 0.0


func _ready():

	body_entered.connect(_on_body_entered)

	# Guardar la altura original del alien.
	# El movimiento del alien solamente será horizontal.
	fixed_y = global_position.y

	# Dirección aleatoria.
	if randf() < 0.5:
		direction = -1.0


func _process(delta):

	# =====================================================
	# MOVIMIENTO HORIZONTAL
	# =====================================================

	global_position.x += SPEED * direction * delta

	# Mantener SIEMPRE la misma altura.
	global_position.y = fixed_y

	# =====================================================
	# OBTENER CÁMARA
	# =====================================================

	var camera := get_viewport().get_camera_2d()

	if camera == null:
		return

	# =====================================================
	# LÍMITES HORIZONTALES REALES
	# =====================================================

	var viewport_size := get_viewport_rect().size

	var world_width := viewport_size.x / camera.zoom.x

	var camera_center_x := camera.global_position.x

	var left_edge := camera_center_x - world_width * 0.5
	var right_edge := camera_center_x + world_width * 0.5

	# =====================================================
	# REAPARECER POR EL OTRO LADO
	# =====================================================

	if global_position.x < left_edge - SCREEN_MARGIN:

		global_position.x = right_edge + SCREEN_MARGIN

	elif global_position.x > right_edge + SCREEN_MARGIN:

		global_position.x = left_edge - SCREEN_MARGIN


func _on_body_entered(body):

	if body.name != "player":
		return

	# =====================================================
	# COMPROBAR INMUNIDAD
	# =====================================================

	if body.has_method("is_immune_from_aliens"):

		if body.is_immune_from_aliens():
			return

	# =====================================================
	# GAME OVER
	# =====================================================

	if body.has_method("show_game_over"):
		body.show_game_over()
