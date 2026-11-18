
extends Node2D

const BLINK_INTERVAL = 0.12
const BLINK_TIME = 1.2
const DISAPPEAR_TIME = 2.5

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var detection_area: Area2D = $DetectionArea
@onready var detection_collision: CollisionShape2D = $DetectionArea/CollisionShape2D

var disappearing := false
var blink_timer := 0.0
var total_timer := 0.0
var blink_state := false


func _ready():
	detection_area.body_entered.connect(_on_body_entered)


func _process(delta):
	if not disappearing:
		return

	blink_timer += delta
	total_timer += delta

	if blink_timer >= BLINK_INTERVAL:
		blink_timer = 0.0
		blink_state = !blink_state
		sprite.visible = blink_state

	if total_timer >= BLINK_TIME:
		finish_disappearing()


func _on_body_entered(body):
	if disappearing:
		return

	if body is CharacterBody2D:
		if body.velocity.y >= 0:
			disappearing = true
			blink_timer = 0.0
			total_timer = 0.0
			blink_state = true
			sprite.visible = true


func finish_disappearing():
	disappearing = false

	sprite.visible = false
	collision.set_deferred("disabled", true)
	detection_collision.set_deferred("disabled", true)

	await get_tree().create_timer(DISAPPEAR_TIME).timeout

	sprite.visible = true
	collision.set_deferred("disabled", false)
	detection_collision.set_deferred("disabled", false)

	blink_timer = 0.0
	total_timer = 0.0
	blink_state = false
