extends Node2D

@onready var spring_body: StaticBody2D = $StaticBody2D


func _ready():
	spring_body.add_to_group("spring_platforms")
