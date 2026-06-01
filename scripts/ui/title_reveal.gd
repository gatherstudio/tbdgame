extends Node2D

@onready var color_rect: ColorRect = $ColorRect
@onready var title_animation = $TitleAnimation
@onready var title_sound = $TitleSound

@onready var new_game_button: Button = $NewGameButton
@onready var continue_button: Button = $ContinueButton


func _ready() -> void:
	color_rect.visible = true
	color_rect.color = Color(0, 0, 0, 1)

	new_game_button.visible = false
	continue_button.visible = false

	new_game_button.text = "New Game"
	continue_button.text = "Continue"

	new_game_button.custom_minimum_size = Vector2(220, 48)
	continue_button.custom_minimum_size = Vector2(220, 48)
	new_game_button.size = Vector2(220, 48)
	continue_button.size = Vector2(220, 48)

	_position_buttons_under_title()

	if title_sound:
		title_sound.play()

	title_animation.play()

	await fade_in()
	await get_tree().create_timer(1.0).timeout

	continue_button.visible = GameState.has_save_file()
	new_game_button.visible = true

	continue_button.pressed.connect(_on_continue_pressed)
	new_game_button.pressed.connect(_on_new_game_pressed)


func _position_buttons_under_title() -> void:
	var button_width := 220
	var button_height := 48
	var button_gap := 18

	var title_center_x :float= title_animation.global_position.x
	var title_bottom_y :float = title_animation.global_position.y + 120

	continue_button.global_position = Vector2(
		title_center_x - button_width / 2,
		title_bottom_y + 50
	)

	new_game_button.global_position = Vector2(
		title_center_x - button_width / 2,
		title_bottom_y + button_height + button_gap + 40
	)


func fade_in() -> void:
	var tween = create_tween()
	tween.tween_property(color_rect, "color", Color(0.902, 0.812, 0.631, 1.0), 0.7)
	await tween.finished


func _on_continue_pressed() -> void:
	GameState.load_game()
	get_tree().change_scene_to_file("res://scenes/world/WorldSurface.tscn")


func _on_new_game_pressed() -> void:
	GameState.start_new_game()
	get_tree().change_scene_to_file("res://scenes/world/WorldSurface.tscn")
