
extends CanvasLayer

@onready var achievement_card: Panel = $NotificationContainer/AchievementNotification
@onready var icon: TextureRect = $NotificationContainer/AchievementNotification/Icon
@onready var title_label: Label = $NotificationContainer/AchievementNotification/Title
@onready var description_label: Label = $NotificationContainer/AchievementNotification/Description

const NOTIFICATION_DURATION := 3.5
const ANIMATION_DURATION := 0.4
const CARD_SIZE := Vector2(360, 110)
const CARD_MARGIN := Vector2(25, 25)

# ICONOS DE LOS LOGROS
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

var achievements := {
	"first_game": {
		"title": "¡Primer rebote!",
		"description": "Jugaste tu primera partida."
	},
	"score_500": {
		"title": "¡500 puntos!",
		"description": "Alcanzaste 500 puntos."
	},
	"score_1000": {
		"title": "¡1000 puntos!",
		"description": "Alcanzaste 1000 puntos."
	},
	"score_2500": {
		"title": "¡Imparable!",
		"description": "Alcanzaste 2500 puntos."
	},
	"speedster": {
		"title": "¡Velocista!",
		"description": "Conseguiste 500 puntos en menos de 60 segundos."
	},
	"veteran": {
		"title": "¡Veterano!",
		"description": "Jugaste 25 partidas."
	},
	"survivor": {
		"title": "¡Superviviente!",
		"description": "Esquivaste 10 aliens."
	},
	"professional_bouncer": {
		"title": "¡Profesional del rebote!",
		"description": "Usaste 20 resortes."
	}
}

var notification_queue: Array[String] = []
var is_showing := false
var current_tween: Tween

var visible_position := Vector2.ZERO
var hidden_position := Vector2.ZERO


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

	achievement_card.visible = false
	achievement_card.size = CARD_SIZE
	achievement_card.z_index = 100

	# ESTILO DEL PANEL
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("#433030")
	panel_style.set_corner_radius_all(14)
	panel_style.set_border_width_all(3)
	panel_style.border_color = Color("#E6A8B0")
	panel_style.shadow_color = Color(0, 0, 0, 0.3)
	panel_style.shadow_size = 8
	panel_style.shadow_offset = Vector2(3, 4)

	achievement_card.add_theme_stylebox_override("panel", panel_style)

	# COLORES DEL TEXTO
	title_label.add_theme_color_override(
		"font_color",
		Color("#FFE4D8")
	)

	description_label.add_theme_color_override(
		"font_color",
		Color("#E6A8B0")
	)

	# POSICIONES
	visible_position = Vector2(
		CARD_MARGIN.x,
		get_viewport().get_visible_rect().size.y - CARD_SIZE.y - CARD_MARGIN.y
	)

	hidden_position = Vector2(
		-CARD_SIZE.x - 20,
		visible_position.y
	)

	achievement_card.position = hidden_position

	# CONFIGURAR ICONO
	icon.position = Vector2(15, 23)
	icon.size = Vector2(64, 64)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED


	# CONECTAR SEÑAL DE LOGROS
	if not PlayerData.achievement_unlocked.is_connected(_on_achievement_unlocked):
		PlayerData.achievement_unlocked.connect(_on_achievement_unlocked)

	print("Sistema de notificaciones activo.")


func _on_achievement_unlocked(achievement_id: String):
	if not achievements.has(achievement_id):
		return

	notification_queue.append(achievement_id)
	show_next_notification()


func show_next_notification():
	if is_showing or notification_queue.is_empty():
		return

	is_showing = true

	var achievement_id = notification_queue.pop_front()
	var achievement = achievements[achievement_id]

	# ACTUALIZAR INFORMACIÓN
	title_label.text = achievement["title"]
	description_label.text = achievement["description"]

	# CARGAR EL ICONO CORRESPONDIENTE
	icon.texture = ACHIEVEMENT_ICONS.get(achievement_id)
	icon.visible = icon.texture != null

	# MOSTRAR PANEL
	achievement_card.position = hidden_position
	achievement_card.visible = true

	if current_tween and current_tween.is_running():
		current_tween.kill()

	current_tween = create_tween()

	current_tween.tween_property(
		achievement_card,
		"position",
		visible_position,
		ANIMATION_DURATION
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	current_tween.tween_interval(NOTIFICATION_DURATION)

	current_tween.tween_property(
		achievement_card,
		"position",
		hidden_position,
		ANIMATION_DURATION
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)

	current_tween.tween_callback(_on_notification_finished)


func _on_notification_finished():
	achievement_card.visible = false
	is_showing = false
	show_next_notification()
