extends TextureButton

const MENU_SCENE = preload("res://escenas/menu.tscn")


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	pressed.connect(_on_pressed)


func _on_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_packed(MENU_SCENE)
