extends TextureButton

var pausado := false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	pressed.connect(_on_pressed)

func _on_pressed():
	pausado = !pausado
	get_tree().paused = pausado
