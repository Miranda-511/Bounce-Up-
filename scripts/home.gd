extends TextureButton

const MENU_SCENE = preload("res://escenas/menu.tscn")


func _pressed():
	get_tree().change_scene_to_packed(MENU_SCENE)
