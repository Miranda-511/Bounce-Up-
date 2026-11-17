extends Node2D

const SPEED = 120.0
const MOVE_DISTANCE = 180.0

var start_x: float
var direction := 1.0

func _ready():
	start_x = global_position.x

func _process(delta):
	global_position.x += SPEED * direction * delta

	if global_position.x >= start_x + MOVE_DISTANCE:
		direction = -1.0

	elif global_position.x <= start_x - MOVE_DISTANCE:
		direction = 1.0
