
extends Control

@onready var grid: GridContainer = $MainContainer/AchievementsPanel/ScrollContainer/GridContainer
@onready var back_button: TextureButton = $BackButton

const ACHIEVEMENT_ICONS := {
	"first_game": preload("res://assets/achievement icon first game.png"),
	"score_500": preload("res://assets/achievement icon score 500.png"),
	"score_1000": preload("res://assets/achievement icon score 1000.png"),
	"score_2500": preload("res://assets/achievement icon score 2500.png"),
	"speedster": preload("res://assets/achievement icon speedster.png"),
	"survivor": preload("res://assets/achievement icon survivor.png"),
	"professional_bouncer": preload("res://assets/achievement icon professional bouncer.png"),
	"veteran": preload("res://assets/achievement icon veteran.png")
}

const ACHIEVEMENTS := [
	{
		"id": "first_game",
		"title": "¡Primer rebote!",
		"description": "Jugaste tu primera partida."
	},
	{
		"id": "score_500",
		"title": "¡500 puntos!",
		"description": "Alcanzaste 500 puntos."
	},
	{
		"id": "score_1000",
		"title": "¡1000 puntos!",
		"description": "Alcanzaste 1000 puntos."
	},
	{
		"id": "score_2500",
		"title": "¡Imparable!",
		"description": "Alcanzaste 2500 puntos."
	},
	{
		"id": "speedster",
		"title": "¡Velocista!",
		"description": "Conseguiste 500 puntos en menos de 60 segundos."
	},
	{
		"id": "survivor",
		"title": "¡Superviviente!",
		"description": "Esquivaste 10 aliens."
	},
	{
		"id": "professional_bouncer",
		"title": "¡Profesional del rebote!",
		"description": "Usaste 20 resortes."
	},
	{
		"id": "veteran",
		"title": "¡Veterano!",
		"description": "Jugaste 25 partidas."
	}
]


func _ready():
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)

	back_button.pressed.connect(_on_back_pressed)

	create_achievement_cards()

	print("Pantalla de logros cargada.")


func create_achievement_cards():

	for child in grid.get_children():
		child.queue_free()

	for achievement in ACHIEVEMENTS:
		create_achievement_card(achievement)


func create_achievement_card(achievement: Dictionary):

	var achievement_id: String = achievement["id"]
	var is_unlocked: bool = PlayerData.unlocked_achievements.has(achievement_id)

	# PANEL DE LA TARJETA
	var card := PanelContainer.new()

	card.custom_minimum_size = Vector2(370, 190)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var card_style := StyleBoxFlat.new()

	if is_unlocked:
		card_style.bg_color = Color("#433030")
		card_style.border_color = Color("#E6A8B0")
	else:
		card_style.bg_color = Color("#302727")
		card_style.border_color = Color("#665454")

	card_style.set_corner_radius_all(14)
	card_style.set_border_width_all(2)

	card.add_theme_stylebox_override("panel", card_style)

	grid.add_child(card)

	# MÁRGENES
	var margin := MarginContainer.new()

	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 14)

	card.add_child(margin)

	# CONTENIDO HORIZONTAL
	var content := HBoxContainer.new()
	content.add_theme_constant_override("separation", 14)

	margin.add_child(content)

	# ICONO
	var icon := TextureRect.new()

	icon.custom_minimum_size = Vector2(105, 105)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	icon.texture = ACHIEVEMENT_ICONS[achievement_id]

	if not is_unlocked:
		icon.modulate = Color(0.35, 0.35, 0.35, 1.0)

	content.add_child(icon)

	# INFORMACIÓN
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 7)

	content.add_child(info)

	# TÍTULO
	var title := Label.new()

	title.text = achievement["title"]
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override(
		"font_color",
		Color("#FFE4D8")
	)

	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	info.add_child(title)

	# DESCRIPCIÓN
	var description := Label.new()

	description.text = achievement["description"]
	description.add_theme_font_size_override("font_size", 19)
	description.add_theme_color_override(
		"font_color",
		Color("#E6A8B0")
	)

	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	info.add_child(description)

	# ESTADO
	var status := Label.new()

	if is_unlocked:
		status.text = "✓ DESBLOQUEADO"
		status.add_theme_color_override(
			"font_color",
			Color("#FFD77A")
		)
	else:
		status.text = "BLOQUEADO"
		status.add_theme_color_override(
			"font_color",
			Color("#A18C8C")
		)

	status.add_theme_font_size_override("font_size", 16)

	info.add_child(status)


func _on_back_pressed():
	get_tree().change_scene_to_file("res://escenas/menu.tscn")
