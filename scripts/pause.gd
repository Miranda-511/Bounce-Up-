extends TextureButton

var pausado := false

@onready var home_button: TextureButton = $"../HomeButton"


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	pressed.connect(_on_pressed)

	home_button.visible = false


func _on_pressed():
	pausado = !pausado

	home_button.visible = pausado
	get_tree().paused = pausado
